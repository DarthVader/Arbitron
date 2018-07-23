#!/usr/bin/python3.6

# markets.py
# High-level class for Markets data loading and management
__version__ = "1.0.4"

import os, sys
import asyncio
import ccxt as ccxt_s
import ccxt.async as ccxt
from ccxt.async import Exchange
from colorama import init, Fore, Back, Style # color printing

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
#from settings.settings import Settings
from settings.settings import Settings
from database.database import Database


class Markets:

    fiat = ['USD','EUR','JPY','UAH','USDT','RUB','CAD','NZDT']
    allowed_tsyms = ['USD', 'USDT', 'BTC', 'ETH', 'DOGE', 'LTC', 'EUR', 'RUB'] # allowed symbols for convertion to

    def __init__(self, db_context):
        self.exchanges = {}          #  exchanges - dict of ccxt objects
        self.exchanges_list = []     #  exchanges_list - custom list of exchanges to filter (lowercase)
        self.ex_pairs = {}           #  ex_pairs - dict of exchanges which contains corresponding trading pairs
        self.my_tokens = []          #  list of string values representing which token is allowed either on fsym or tsym
        self.last_fetch = {}         #  init dict with last fetches
        self.db_context = db_context #  database context
        self._cache = {}             #  local cache for storing last access times to exchanges and pairs
        self.config = Settings()

        init(convert=True) # colorama init  
        print(f"CCXT version: {Fore.GREEN+Style.BRIGHT+ccxt.__version__+Style.RESET_ALL}")
        

    def _init_metadata(self, exchanges_list):
        self.exchanges_list = exchanges_list
        for id in exchanges_list:
            exchange = getattr(ccxt, id)
            # this option enables the built-in rate limiter <<=============
            exchange.enableRateLimit = True, 
            self.exchanges[id] = exchange()        


    def __del__(self):
        if self.exchanges != {}:
            loop = asyncio.get_event_loop()
            loop.run_until_complete(self._shutdown())


    async def _shutdown(self):
        #assert(self.exchanges != {}, "exchanges are not loaded!")
        for ex in self.exchanges.items():
            print("Closing {}".format(ex[0]))
            await ex[1].close()


    async def _load_exchange(self, exchange):
        #assert(self.exchanges != {}, "exchanges are not loaded!")
        await exchange.load_markets()
        print("{} market metadata loaded".format(exchange.name))


    async def _run_tasks(self, exchanges):
        #assert(self.exchanges != {}, "exchanges are not loaded!")
        tasks = []
        for ex in exchanges.items():
            tasks.append(asyncio.ensure_future(self._load_exchange(ex[1])))
        await asyncio.gather(*tasks)

    
    def load_exchanges(self, exchanges_list):
        if self.exchanges_list == []:
            self._init_metadata(exchanges_list) # init by exchanges list from settings.exchanges table
        loop = asyncio.get_event_loop()
        try:
            loop.run_until_complete(self._run_tasks(self.exchanges))
        except KeyboardInterrupt:
            print("Leaving by Ctrl-C...")
            sys.exit()      


    def reload_pairs(self, my_tokens):
        """
        Returns dict of exchanges, corresponding pairs.
            exchanges - dict of ccxt objects
            exchanges_list - custom list of exchanges to filter (lowercase)
            my_tokens - list of string values representing which token is allowed either on fsym or tsym
        """
        self.my_tokens = my_tokens
        for ex in self.exchanges_list:
            my_pairs = [sym.split('/') for sym in self.exchanges[ex].symbols 
                        if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
            my_pairs = [x[0]+'/'+x[1] for x in my_pairs]
            self.ex_pairs[ex] = my_pairs


    def fetch_trades(self, exchange, pair, limit=100):
        ex_obj = getattr(ccxt_s, exchange)
        ex = ex_obj()
        ex.load_markets()
        ex.enableRateLimit = True,
        histories = None
        try:
            if limit==None:
                histories = ex.fetch_trades(symbol=pair)
            else:
                histories = ex.fetch_trades(symbol=pair, limit=100)
        except Exception as e:
            print(f"Error in {__file__}.fetch_trades(). {Fore.YELLOW}{e}{Fore.RESET}")

        return histories


    async def _get_history(self, exchange, pairs):
        """ Get historic data for ONE single pair from ONE exchange """
        for pair in pairs:
            try:
                print(f"\tfetching {Fore.YELLOW}{exchange}{Style.RESET_ALL}: {Fore.GREEN}{pair}{Style.RESET_ALL}")
                #rateLimit = self.exchanges[exchange].rateLimit
                since = self._cache[exchange][pair]

                if since == None:
                    histories = await self.exchanges[exchange].fetch_trades(pair, limit=50)
                else:
                    histories = await self.exchanges[exchange].fetch_trades(pair, since=since)

                ## SAVING LAST ACCESS TIME TO CACHE...
                if histories != []:
                    self._cache[exchange][pair] = histories[-1]['timestamp'] + 1
                    ##  SAVING TO DATABASE...
                    batch_cql = []
                    for x in histories:
                        batch_cql.append(f"INSERT INTO {self.config.data_keyspace}.{self.config.history_table} (exchange, pair, ts, id, price, amount, type, side) VALUES " +
                        f"('{exchange}', '{pair}', {x['timestamp']}, '{x['id']}', {x['price']}, {x['amount']}, '{x['type']}', '{x['side']}')")
                        #print(batch_cql)
                    self.db_context.batch_insert(batch_cql)

            except Exception as e:
                print(f"Error in {__file__}._get_history(). {Fore.YELLOW}{e}{Fore.RESET}")

            finally:
                await asyncio.sleep(self.exchanges[exchange].rateLimit/1000)
                    #sleep(rateLimit/1000)

    
    async def _get_histories(self, job):
        """ fetches history via parallel fibers """
        try:
            exchanges = job.keys()
            tasks = []
            for exchange in exchanges:
                pairs = list(job[exchange]["pairs"])
                tasks.append(asyncio.ensure_future(self._get_history(exchange, pairs)))

        except Exception as e:
            print(f"Error in {__file__}._get_histories(). {Fore.YELLOW}{e}{Fore.RESET}")
                
        finally:
            await asyncio.gather(*tasks)
            

    def _fill_last_access_times(self, job):
        """ fills job structure with last access times from database or from cache """
        exchanges = job.keys()
        for exchange in exchanges:
            if exchange not in self._cache:
                self._cache[exchange] = {}

            pairs = list(job[exchange]["pairs"])
            for pair in pairs:
                if pair not in self._cache[exchange]:
                    self._cache[exchange][pair] = self.db_context.get_last_access(exchange, pair)
                


    def process_job(self, job, db_context):
        """
        Method collects historic and orderbook data from exchanges 
        and saves it to database given by context parameter db_context

         - job parameter must contain json dictionary with the follownig structure:
         - returns large chunk of collected data by each requested pair
        
        # input (job structure): 
        {
            "exchange1": {
                "ratelimit": 3000,
                "pairs": ["BTC/USD", "BTC/ETH", "ETH/USD"],
            }
            "exchange2_id": {
                "ratelimit": 2000,
                "pairs": ["BTC/OMG", "BTC/ETH"],
            },...
        }

        # output json object:
        {
            "exchange1": {
                "BTC/USD": {
                    "history": [[1234567, 12.34], [1234568, 12.33], [1234569, 12.32],...],
                    "orderbook": {                        
                        "bids": [1,2,3,4,...],
                        "asks": [2,3,4,5,...],
                    }
                },...
            },...
        }
        """
        try:
            if self.exchanges_list == {}:
                raise ValueError("Markets instance is not properly initialized! load_exchanges() must be called first!")
            
            self._fill_last_access_times(job) ## <-- commented!

            #db_context.get_exchanges()
            #df = db_context.df_exchanges
            #print(df.name.tolist())
            #exchanges = job.keys()
            
            #delay = 350 # initialize delay with some non-zero value
            
            loop = asyncio.get_event_loop()
            loop.run_until_complete(self._get_histories(job))
            
            #for exchange in exchanges:
            #    pairs = list(job[exchange]["pairs"])
            #    loop.run_until_complete(self._get_history(exchange, pairs))
                #asyncio.ensure_future(self._get_history(exchange, pairs))
                #for pair in pairs:
                #    loop.run_until_complete(self._get_history(exchange, pair))
                    #self._get_history(exchange, pair, None)
                #ratelimit = job[exchange]["ratelimit"]
                #delay = max(delay, ratelimit) # calculate maximum time
                #print(f"\t{exchange} ({ratelimit} ms): {pairs}")

        except Exception as e:
            init(convert=True) # colorama init  
            print(f"{Fore.RED}{e}{Fore.RESET}")
        

if __name__ == '__main__':
    print("This file is not intened for direct execution")