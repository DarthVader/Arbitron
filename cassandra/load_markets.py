#!/usr/bin/python3.6

import asyncio, sys
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
exchanges = {}


async def LoadMarkets(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


async def main():
    print("Loading exchanges...")    
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(LoadMarkets(ex[1])))
    await asyncio.gather(*tasks)
    print("Complete.\n")


if __name__ == '__main__':
    # create exchanges objects
    print("Initialize objects...", end="", flush=True)    
    for id in my_exchanges:
        exchange = getattr(ccxt, id)
        exchange.enableRateLimit = True, # this option enables the built-in rate limiter <<=============
        exchanges[id] = exchange()
    print("Done.")

    loop = asyncio.get_event_loop()
    try:
        #asyncio.ensure_future(main()) # forever
        loop.run_until_complete(main())
        #loop.run_forever()

    except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            loop.close()
            sys.exit()

    finally:
        print("\nDone.\n")
        loop.close()