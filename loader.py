# -*- coding: utf-8 -*-
"""
Created on Mon Apr 23 10:59:04 2018

@author: Dodov
"""
import asyncio
import random
#import argparse
from datetime import datetime
from time import sleep
import pytz
import os, json, csv, pickle
import ccxt.async as ccxt
from ccxt.async import Exchange
from utils.tail import tail

data_folder = "data"
csv_separator = ","

my_exchanges = [
    'binance',
    'bittrex',
    'cryptopia',
    'exmo',
    'hitbtc',
    'kraken',
    'okex',
    'poloniex',
    'yobit',
]


# fiat currencies
fiat = ['USD','EUR','JPY','UAH','USDT','RUB','CAD','NZDT']
low_fee_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH']
high_volume_tokens = ['BTC','ETH','BCH','LTC','ADA','XRP','XMR','ETC','NEO',
                      'EOS','ZEC','XLM','DASH','MIOTA','TRX','XEM','BTG',
                      'OMG','ICX','XVG','DOGE','SC','DCR']
# custom tokens
my_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH',
             'BTC','XMR','ETH','XLM','DASH','TRX','XEM','OMG','ICX','XVG','DCR','MIOTA','SC',
             'USD','USDT'
             ]


async def OrderBook(exchange, pair, last_fetch):
    #process_time = random.randint(1,5)
    while True:
        try:
            ts = last_fetch[exchange.name.lower()][pair]['history']
            if ts == None:
                orderbooks = await exchange.fetch_order_book(pair, limit=100)
            else:
                orderbooks = await exchange.fetch_order_book(pair, since=ts)        

            orderbook = await exchange.fetch_order_book(pair)
            
            #filename = "data/{}.{}.csv".format(exchange.name, pair.replace("/","-"))
            filename = "{}/{}/orderbook_log.csv".format(os.getcwd(), data_folder)
            with open(filename, "a") as file:
                line = "{};{};{};{};{};{};{};{};{}".format(datetime.now(),
                        orderbook['timestamp'], exchange.name, pair, 
                        orderbook['price'], orderbook['amount'], orderbook['type'], orderbook['side'], ts)
                file.write(line + "\n")

            #print("Fetch {} has completed after {} seconds".format(exchange_name, process_time))
            print("{:%d.%m.%Y %H:%M:%S} Orderbook: {}, {} bids={}, asks={}".format(
                    datetime.now(), exchange.name, pair, 
                    orderbook['bids'][0], orderbook['asks'][0]))

        except IOError:
            print("File access error")
        except:
            pass
        finally:
            await asyncio.sleep(exchange.rateLimit/1000)


async def History(exchange, pair, last_fetch):
    while True:
        try:
            ts = last_fetch[exchange.name.lower()][pair]['history']
            if ts == None:
                histories = await exchange.fetch_trades(pair, limit=100)
            else:
                histories = await exchange.fetch_trades(pair, since=ts)

            history = histories[-1]
            last_fetch[exchange.name.lower()][pair]['history'] = history['timestamp'] + 1
                        
            filename = "{}/{}/history/{}.{}.csv".format(os.getcwd(), data_folder, exchange.name, pair.replace("/","-"))
            with open(filename, "a") as file:
                for x in histories:
                    txt = "{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}{0}{7}{0}{8}{0}{9}".format(
                            csv_separator, datetime.now(),
                            x['timestamp'], x['datetime'], exchange.name, pair, 
                            x['price'], x['amount'], x['type'], x['side'])
                    file.write(txt + "\n")

            #filename = "data/{}.{}.csv".format(exchange.name, pair.replace("/","-"))
            filename = "{}/{}/history_log.csv".format(os.getcwd(), data_folder)
            with open(filename, "a") as file:
                line = "{};{};{};{};{};{};{};{};{}".format(datetime.now(),
                        history['timestamp'], exchange.name, pair, 
                        history['price'], history['amount'], history['type'], history['side'], ts)
                file.write(line + "\n")
            
            print("{:%d.%m.%Y %H:%M:%S} History  : {}, {} {} {} price={} amount={}".format(
                    datetime.now(), exchange.name, history['symbol'], history['side'], 
                    history['type'], history['price'], history['amount']))

        except IOError:
            print("File access error")
        except:
            pass
        finally:
            await asyncio.sleep(exchange.rateLimit/1000)


async def LoadMarkets(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


async def main():

    # create exchanges objects
    print("Initialize exchange objects...", end="", flush=True)
    exchanges = {}
    for id in my_exchanges:
        exchange = getattr(ccxt, id)
        exchange.enableRateLimit = True, # this option enables the built-in rate limiter <<=============
        exchanges[id] = exchange()
    print("Done.")

    print("Checking folder structure and loading last access time for each commodity...", end="", flush=True)
    folders = ['history', 'orderbook']
    for folder in folders:
        os.makedirs(os.path.join(os.getcwd()) + "/" + data_folder + "/" + folder, exist_ok=True)
    print("Done.")

    print("Loading exchanges...")
    
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(LoadMarkets(ex[1])))
    await asyncio.gather(*tasks)

    # saving to exchange cache
    #with open("{}/{}/exchanges.dat".format(os.getcwd(), data_folder), "wb") as handle:
    #    pickle.dump(exchanges, handle, protocol=pickle.HIGHEST_PROTOCOL)
    #print("Done.")

    print("Detecting active symbols and generating pairs...", end="", flush=True)
    ex_pairs = {}
    for ex in my_exchanges:
        my_pairs = [sym.split('/') for sym in exchanges[ex].symbols 
                    if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
        my_pairs = [x[0]+'/'+x[1] for x in my_pairs]
        ex_pairs[ex] = my_pairs
        #symbols = symbols + [x.replac e('USDT','USD') for x in exchanges[ex].symbols]
    #symbols = list(set(symbols))
    #allowed_pairs = [sym.split('/') for sym in symbols if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
    #my_pairs = [x[0]+'/'+x[1] for x in allowed_pairs]
    print("Done.")

    print("Fetching last access time for each pair...", end="", flush=True)
    last_fetch = {} # init dict with last fetches
    try:
        for ex in my_exchanges:
            last_fetch[ex] = { 'access': datetime.now() }
            for pair in ex_pairs[ex]:

                fileHistory = "{}/history/{}.{}.csv".format(data_folder, exchanges[ex].name, pair.replace("/","-"))
                fileOrderbook = "{}/orderbook/{}.{}.csv".format(data_folder, exchanges[ex].name, pair.replace("/","-"))
                accessHistory = int(tail(fileHistory, 1)[0].split(csv_separator)[1])+1 if os.path.isfile(fileHistory) == True else None
                accessOrderbook = int(tail(fileOrderbook, 1)[0].split(csv_separator)[1])+1 if os.path.isfile(fileOrderbook) == True else None

                last_fetch[ex][pair] = {
                                        'history': None, #accessHistory+1,
                                        'orderbook': None #accessOrderbook+1,
                                        } # pair
                last_fetch[ex][pair]['history'] = accessHistory
                last_fetch[ex][pair]['orderbook'] = accessOrderbook
                
    except Exception:
        pass
    print("Done.")


    try:
        tasks = []
        #product = 'ETH/BTC'
        for ex in exchanges.items(): # running concurrent tasks to fetch data
            ex_obj, exchange = ex[1], ex[0]
            for pair in ex_pairs[exchange]:
                #tasks.append(asyncio.ensure_future(OrderBook(ex_obj, pair, last_fetch)))
                tasks.append(asyncio.ensure_future(History(ex_obj, pair, last_fetch)))
    except Exception:
        pass
    finally:
        await asyncio.gather(*tasks)


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    try:
        asyncio.ensure_future(main()) # forever
        #loop.run_until_complete(main())
        loop.run_forever()

    except KeyboardInterrupt:
        pass

    finally:
        print("Done.\n\n")
        loop.close()
