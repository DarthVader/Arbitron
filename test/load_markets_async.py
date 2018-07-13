# -*- coding: utf-8 -*-
"""
Created on Mon Apr 23 10:59:04 2018

@author: Dodov
"""
import asyncio
import random

from datetime import datetime
import time
from time import sleep
import pytz, glob
import os, json, csv, pickle
import ccxt.async as ccxt
from ccxt.async import Exchange

my_exchanges = [
    'binance',
    'bittrex',
    'cryptopia',
    'exmo',
    'hitbtc2',
    'kraken',
    'okex',
    'poloniex',
    'yobit',
]


async def LoadMarkets(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


def Init(exchanges_list):
    exchanges = {}
    for id in exchanges_list:
        exchange = getattr(ccxt, id)
        # this option enables the built-in rate limiter <<=============
        exchange.enableRateLimit = True, 
        exchanges[id] = exchange()        
    return exchanges


async def Shutdown(exchanges):
    for ex in exchanges.items():
        print("Closing {}".format(ex[0]))
        await ex[1].close()


async def main():
    print("Loading exchanges...")    
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(LoadMarkets(ex[1])))
    await asyncio.gather(*tasks)   


if __name__ == '__main__':
    print("Initialize objects...", end="", flush=True)
    exchanges = Init(my_exchanges)
    print("Done.")

    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(main())
    except KeyboardInterrupt:
        print("Leaving by Ctrl-C...")
        pass

    finally:
        loop.run_until_complete(Shutdown(exchanges))
        print("Done.\n")