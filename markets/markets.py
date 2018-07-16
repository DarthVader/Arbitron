import sys
import asyncio
import ccxt.async as ccxt
from ccxt.async import Exchange

class Markets:

    def __init__(self):
        self.exchanges = {}         #  exchanges - dict of ccxt objects
        self.exchanges_list = []    #  exchanges_list - custom list of exchanges to filter (lowercase)
        self.ex_pairs = {}          #  ex_pairs - dict of exchanges which contains corresponding trading pairs
        self.my_tokens = []         #  list of string values representing which token is allowed either on fsym or tsym


    def _init_metadata(self, exchanges_list):
        self.exchanges_list = exchanges_list
        for id in exchanges_list:
            exchange = getattr(ccxt, id)
            # this option enables the built-in rate limiter <<=============
            exchange.enableRateLimit = True, 
            self.exchanges[id] = exchange()        


    def __del__(self):
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