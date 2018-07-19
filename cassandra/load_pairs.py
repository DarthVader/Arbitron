#!/usr/bin/python3.6

# load_pairs
# Loads/updates meaningful pairs in Cassandra database
# must reside in /cassandra subpath
__version__ = '1.0.3'

import os, sys
import pandas as pd
from colorama import init, Fore, Back, Style # color printing

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
from markets.markets import Markets
from database.database import Database
from settings.settings import Settings


if __name__ == '__main__':
    init(convert=True) # colorama init  
    db = Database()
    db.get_exchanges()
    db.get_tokens()
    my_exchanges = db.exchanges_list
    my_tokens = db.tokens_list
    print("OK")

    print("Loading markets from WWW...")
    markets = Markets()
    markets.load_exchanges(exchanges_list=my_exchanges)
    #markets.load_pairs()
    markets.reload_pairs(my_tokens)
    print("OK")

    config = Settings()

    cql_list = []
    for ex in markets.exchanges_list:
        rateLimit = markets.exchanges[ex].rateLimit
        rateLimitMaxTokens = markets.exchanges[ex].rateLimitTokens
        countries = "{'" + "','".join(markets.exchanges[ex].countries) + "'}"
        cql_list.append(f"INSERT INTO {config.exchanges_table} (id, countries, ratelimit, ratelimitmaxtokens) " +
                        f"VALUES ('{ex}', {countries}, {rateLimit}, {rateLimitMaxTokens})")
    db.batch_insert(cql_list)

    #cql_list = [f'TRUNCATE TABLE {config.pairs_table}']
    cql_list = []
    for ex in markets.exchanges_list:
        for pair in markets.ex_pairs[ex]:
            fsym, tsym = pair.split("/")
            try:
                tsym_withdraw_fee = 'NULL'
                tsym_withdraw_fee = markets.exchanges[ex].fees['funding']['withdraw'][tsym]
            except:
                pass
            try:
                fsym_withdraw_fee = 'NULL'
                fsym_withdraw_fee = markets.exchanges[ex].fees['funding']['withdraw'][fsym]
            except:
                pass
            cql_list.append(f"INSERT INTO {config.pairs_table} (exchange, pair, fsym, tsym, tsym_withdraw_fee, fsym_withdraw_fee, enabled)"+
                            f"VALUES ('{ex}', '{pair}', '{fsym}', '{tsym}', {tsym_withdraw_fee}, {fsym_withdraw_fee}, true)")
    db.batch_insert(cql_list)

    #a = input("Press Enter...")
    print(f"SUCCESS! Table {config.pairs_table} has been updated.")