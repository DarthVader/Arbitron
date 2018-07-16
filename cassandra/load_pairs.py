# load_pairs 1.0.1
# Loads meaningful pairs to Cassandra database
# must reside in /cassandra path in order to see ../markets module
__version__ = '1.0.1'

import os, sys
import pandas as pd

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
from markets.markets import Markets
from database.database import Database
from settings.settings import Settings


if __name__ == '__main__':
    ##--------------- Database ------------------
    print("Connecting to database...".format(), end="", flush=False)
    db = Database()
    db.get_exchanges()
    db.get_tokens()
    my_exchanges = db.exchanges_list
    my_tokens = db.tokens_list
    print("OK")

    print("Loading markets from WWW...")
    markets = Markets()
    markets.load_exchanges(exchanges_list=my_exchanges)
    markets.reload_pairs(my_tokens)
    print("OK")

    config = Settings()

    cql_list = []
    for ex in markets.exchanges_list:
        for pair in markets.ex_pairs[ex]:
            cql_list.append(f"INSERT INTO {config.pairs_table} (exchange, pair) VALUES ('{ex}', '{pair}')")
    
    db.batch_insert(cql_list)

    #a = input("Press Enter...")
    print(f"SUCCESS! Table {config.pairs_table} has been updated.")