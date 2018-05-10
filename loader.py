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
import json, csv
import ccxt.async as ccxt
from ccxt.async import Exchange

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


# фиатные валюты
fiat = ['USD','EUR','JPY','UAH','USDT','RUB','CAD','NZDT']
# токены с низкими комиссиями
low_fee_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH']
# токены с большим объёмом
high_volume_tokens = ['BTC','ETH','BCH','LTC','ADA','XRP','XMR','ETC','NEO',
                      'EOS','ZEC','XLM','DASH','MIOTA','TRX','XEM','BTG',
                      'OMG','ICX','XVG','DOGE','SC','DCR']
my_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH',
             'BTC','XMR','ETH','XLM','DASH','TRX','XEM','OMG','ICX','XVG','DCR','MIOTA','SC',
             'USD','USDT'
             ]


async def OrderBook(exchange, product):
    #process_time = random.randint(1,5)
    while True:
        orderbook = await exchange.fetch_order_book(product)
        
        #print("Fetch {} has completed after {} seconds".format(exchange_name, process_time))
        print("{:%d.%m.%Y %H:%M:%S} Orderbook: {}, {} bids={}, asks={}".format(
                datetime.now(), exchange.name, product, 
                orderbook['bids'][0], orderbook['asks'][0]))
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
                        
            filename = "csv/{}.{}.csv".format(exchange.name, pair.replace("/","-"))
            with open(filename, "a") as file:
                for x in histories:
                    txt = "{};{};{};{};{};{};{};{};{}".format(datetime.now(),
                            x['timestamp'], x['datetime'], exchange.name, pair, 
                            x['price'], x['amount'], x['type'], x['side'])
                    file.write(txt + "\n")

            #filename = "data/{}.{}.csv".format(exchange.name, pair.replace("/","-"))
            # filename = "data/history.csv"
            # with open(filename, "a") as file:
            #     line = "{};{};{};{};{};{};{};{};{}".format(datetime.now(),
            #             history['timestamp'], exchange.name, pair, 
            #             history['price'], history['amount'], history['type'], history['side'], ts)
            #     file.write(line + "\n")
            
            print("{:%d.%m.%Y %H:%M:%S} History  : {}, {} {} {} price={} amount={}".format(
                    datetime.now(), exchange.name, history['symbol'], history['side'], 
                    history['type'], history['price'], history['amount']))

        except IOError:
            print("File access error")
        except:
            pass
        await asyncio.sleep(exchange.rateLimit/1000)


async def LoadMarkets(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


async def main():
    # create exchanges objects
    exchanges = {}
    for id in my_exchanges:
        exchange = getattr(ccxt, id)
        exchange.enableRateLimit = True, # this option enables the built-in rate limiter <<=============
        exchanges[id] = exchange()

    print("Loading exchanges...")
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(LoadMarkets(ex[1])))
    await asyncio.gather(*tasks)
    print("Done.\n")

    print("Detecting active symbols and generating pairs...")
    ex_pairs = {}
    for ex in my_exchanges:
        my_pairs = [sym.split('/') for sym in exchanges[ex].symbols if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
        my_pairs = [x[0]+'/'+x[1] for x in my_pairs]
        ex_pairs[ex] = my_pairs
        #symbols = symbols + [x.replac e('USDT','USD') for x in exchanges[ex].symbols]
    #symbols = list(set(symbols))
    #allowed_pairs = [sym.split('/') for sym in symbols if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
    #my_pairs = [x[0]+'/'+x[1] for x in allowed_pairs]
    print("Done.\n")

    last_fetch = {} # init dict with last fetches
    for ex in my_exchanges:
        last_fetch[ex] = { 'access': datetime.now() }
        for pair in ex_pairs[ex]:
            last_fetch[ex][pair] = {
                                    'history': None, 
                                    'orderbook': None,
                                    } # pair

    try:
        tasks = []
        #product = 'ETH/BTC'
        for ex in exchanges.items(): # running concurrent tasks to fetch data
            ex_obj, exchange = ex[1], ex[0]
            for pair in ex_pairs[exchange]:
                #tasks.append(asyncio.ensure_future(OrderBook(ex_obj, pairs)))
                #tasks.append(asyncio.ensure_future(History(ex_obj, pairs)))
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
