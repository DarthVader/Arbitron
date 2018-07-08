#!/usr/bin/python3.6

# -*- coding: utf-8 -*-
"""
Created on Mon Apr 23 10:59:04 2018

@author: Dodov
"""
import asyncio
import random
#import argparse
from datetime import datetime, timezone, timedelta
import time
from time import sleep
import pytz, glob
import os, json, requests
from requests.auth import HTTPBasicAuth
import ccxt.async as ccxt
from ccxt.async import Exchange
import pika
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
from colorama import init, Fore, Back, Style # color printing
import numpy as np
import ipgetter

__version__ = '1.1.0'

date_formatter = "%Y-%m-%d %H:%M:%S.%f"
host = "127.0.0.1"
user = "cassandra"
password = "cassandra"
nodes = ['127.0.0.1', '10.7.0.11', '10.7.0.10', '10.7.0.20']

rabbit_nodes = ['10.7.0.1', '10.7.0.11']
rabbit_port = 15672  # for getActiveWorkers. It uses http api of rabbitmq_management plugin
rabbit_user= "rabbit"
rabbit_pass= "rabbit"

my_exchanges = [
    'binance',
    'bittrex',
    'cryptopia',
    'exmo',
    #'hitbtc2',
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

# allowed symbols to convert TO
allowed_tsyms = ['USD', 'USDT', 'BTC', 'ETH', 'DOGE', 'LTC', 'EUR', 'RUB']




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
                            csv_separator, datetime.utcnow(),
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


def Init(exchanges_list):
    """
    Returns list of ccxt objects according exchanges list
        exchanges - empty dict. 
        exchanges_list - list of exchanges (lowercase)

        example: 
            exchange = {}
            exchanges_list = ['binance', 'bittrex', 'poloniex' ...]
    """
    exchanges = {}
    for id in exchanges_list:
        exchange = getattr(ccxt, id)
        exchange.enableRateLimit = True, # this option enables the built-in rate limiter <<=============
        exchanges[id] = exchange()
        
    return exchanges


def GetLastAccessTimes(exchanges, exchanges_list, tokens):
    """
    Returns dict of exchanges, corresponding pairs and last access time from cached files.
    Parameters:
        exchanges - dict of ccxt objects
        exchanges_list - custom list of exchanges to filter (lowercase)
        tokens - list of string values representing which token is allowed either on fsym or tsym
    """
    ex_pairs = {}
    for ex in exchanges_list:
        my_pairs = [sym.split('/') for sym in exchanges[ex].symbols 
                    if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
        my_pairs = [x[0]+'/'+x[1] for x in my_pairs]
        ex_pairs[ex] = my_pairs
        #symbols = symbols + [x.replace('USDT','USD') for x in exchanges[ex].symbols]
    #symbols = list(set(symbols))
    #allowed_pairs = [sym.split('/') for sym in symbols if sym.split('/')[0] in my_tokens and sym.split('/')[1] in my_tokens]
    #my_pairs = [x[0]+'/'+x[1] for x in allowed_pairs]

    last_fetch = {} # init dict with last fetches
    for ex in my_exchanges:
        
        last_fetch[ex] = { 'access': datetime.utcnow() }
        for pair in ex_pairs[ex]:
            accessHistory = None
            accessOrderbook = None

            last_fetch[ex][pair] = {
                                    'history': None, #accessHistory+1,
                                    'orderbook': None #accessOrderbook+1,
                                    } # pair

            try:
                fileHistory = "{}/{}/history/{}.{}.csv".format(os.getcwd(), data_folder, 
                                                            exchanges[ex].name, pair.replace("/","-"))
                if os.path.isfile(fileHistory) == True:
                    accessHistory = int(tail(fileHistory, 1)[0].split(csv_separator)[1])+1

            except IOError:
                FixNullBytes(fileHistory)   
                            
            except Exception:
                pass
            
            try:
                fileOrderbook = "{}/{}/orderbook/{}.{}.csv".format(os.getcwd(), data_folder, 
                                                            exchanges[ex].name, pair.replace("/","-"))
                if os.path.isfile(fileOrderbook) == True:
                    lastline = tail(fileOrderbook, 1)[0].split(csv_separator)
                    #accessOrderbook = pd.Timestamp(lastline[0]) #.tz_localize('UTC')
                    dt = datetime.strptime(lastline[0], "%Y-%m-%d %H:%M:%S.%f")
                    accessOrderbook = int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)

            except IOError:
                FixNullBytes(fileOrderbook)            

            except Exception:
                pass

            last_fetch[ex][pair]['history'] = accessHistory
            last_fetch[ex][pair]['orderbook'] = accessOrderbook        
        
    return last_fetch, ex_pairs


async def LoadMarkets(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


async def main():

    # create exchanges objects
    print("Initialize objects...", end="", flush=True)
    exchanges = Init(my_exchanges)
    print("Done.")

    print("Loading exchanges...")    
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(LoadMarkets(ex[1])))
    await asyncio.gather(*tasks)

    print("Fetching last access time for each pair...", end="", flush=True)
    last_fetch, ex_pairs = GetLastAccessTimes(exchanges, my_exchanges, my_tokens) # init dict with last fetches
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
