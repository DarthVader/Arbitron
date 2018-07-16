# load_pairs 1.0.1
# Loads meaningful pairs to Cassandra database
# must reside in /utils path in order to see ../markets module
__version__ = '1.0.1'

import os, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
from markets.markets import Markets
from configparser import ConfigParser
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel


config = ConfigParser()
config.read('config.ini')

db_user = config['database']['user']
db_password = config['database']['password']
cassandra_port = int(config['database']['port'])
cassandra_nodes = config['database']['nodes'].replace(" ","").split(",")

# custom exchanges list
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



if __name__ == '__main__':
    markets = Markets()
    markets.load_exchanges(exchanges_list=my_exchanges)
    markets.reload_pairs(my_tokens)

    a = input("Press Enter...")