#!/usr/bin/python3.6

import pandas as pd
import numpy as np
from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
from cassandra.query import dict_factory
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
from colorama import init, Fore, Back, Style # color printing

my_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH',
             'BTC','XMR','ETH','XLM','DASH','TRX','XEM','OMG','ICX','XVG','DCR','MIOTA','SC',
             'USD','USDT'
             ]
fiats = ['USD','EUR','JPY','UAH','USDT','RUB','CAD','NZDT']
low_fee_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH']
high_volume_tokens = ['BTC','ETH','BCH','LTC','ADA','XRP','XMR','ETC','NEO',
                      'EOS','ZEC','XLM','DASH','MIOTA','TRX','XEM','BTG',
                      'OMG','ICX','XVG','DOGE','SC','DCR']
my_tokens = ['ADA','ZEC','ETC','EOS','DOGE','XDG','XRP','BTG','NEO','LTC','BCH',
             'BTC','XMR','ETH','XLM','DASH','TRX','XEM','OMG','ICX','XVG','DCR','MIOTA','SC',
             'USD','USDT'
             ]
allowed_tsyms = ['USD', 'USDT', 'BTC', 'ETH', 'DOGE', 'LTC', 'EUR', 'RUB']



def pandas_factory(colnames, rows):
    return pd.DataFrame(rows, columns=colnames)

seeds = ['127.0.0.1', '10.7.0.10', '10.7.0.21']

if __name__ == '__main__':
    cluster = Cluster(contact_points=seeds, port=9042)

    session = cluster.connect(keyspace='settings')
    #session.row_factory = pandas_factory
    session.default_fetch_size = 50

    batch = BatchStatement(consistency_level=ConsistencyLevel.ONE)
    for token in my_tokens:
        #cql = f"INSERT INTO settings.tokens (symbol, enabled) VALUES ('{token}', true);"
        fiat    = 'true' if token in fiats              else 'false'
        low_fee = 'true' if token in low_fee_tokens     else 'false'
        high_vol= 'true' if token in high_volume_tokens else 'false'
        #allowed = 'true' if token in allowed_tsyms      else 'false'
        cql = f"UPDATE settings.tokens SET fiat={fiat}, low_fee={low_fee}, high_volume={high_vol} WHERE symbol='{token}'"
        batch.add(cql)
    
    res = session.execute(batch, timeout=5)