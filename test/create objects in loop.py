import ccxt #.async as ccxt
from datetime import datetime

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

exchanges = {}

for id in my_exchanges:
    exchange = getattr(ccxt, id)
    exchanges[id] = exchange()
    print("{} object created".format(id))

print("\n")

orderbook = exchanges['binance'].fetch_order_book('ETH/USDT')
print('{:%d.%m.%Y %H:%M:%S} binance ETH/USDT bids={}, asks={}'.format(
                datetime.now(), orderbook['bids'][0], orderbook['asks'][0]))