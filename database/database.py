#!/usr/bin/python3.6

# Arbitron project database driver
__version__ = '1.0.4'

from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel, DCAwareRoundRobinPolicy
import sys, os, hashlib
import asyncio
import time
from datetime import datetime, timezone, timedelta
from colorama import init, Fore, Back, Style # color printing
import pandas as pd
import numpy as np
import logging

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
from settings.settings import Settings


class Timer:
    def __init__(self):
        self.start = time.time()

    def tic(self):
        return "%2.2f" % (time.time() - self.start)


class Database():
    
    def _pandas_factory(self, colnames, rows):
        return pd.DataFrame(rows, columns=colnames)


    def __init__(self):
        init(convert=True)  # colorama init 
        self.exchanges = {} # hierarchical dict which will contain exchanges and corresponding pairs
        self.pairs = {}     # hierarchical dict which will contain pairs and corresponding exchanges
        self.config = Settings()    # config instance from INI file
        self._cache = {}            #  local cache for storing last access times to exchanges and pairs

        logging.basicConfig(filename=self.config.log_file, level=logging.INFO, format=u'%(filename)s:%(lineno)d %(levelname)-8s [%(asctime)s]  %(message)s')

        print("Connecting to database...".format(), end="", flush=False)
        try:
            cluster = Cluster(contact_points=self.config.cassandra_nodes, 
                              port=self.config.cassandra_port,
                              load_balancing_policy=DCAwareRoundRobinPolicy()
                              )
            self.session = cluster.connect(keyspace=self.config.settings_keyspace)
            self.session.row_factory = self._pandas_factory
            self.session.default_fetch_size = self.config.default_fetch_size
            cql = f'''CREATE TABLE IF NOT EXISTS 
                {self.config.data_keyspace}.{self.config.history_table} ( 
                exchange text,  
                pair text, 
                ts timestamp, 
                id text, 
                amount double, 
                price double, 
                side text,
                type text, 
                PRIMARY KEY (( exchange, pair ), ts, id) 
            ) WITH CLUSTERING ORDER BY ( ts DESC, id ASC )'''
            _ = self.session.execute(cql, timeout=10)
            self.get_exchanges()    
            self.get_last_access()
            #my_exchanges = db.exchanges_list            
            print("OK")

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e, Fore=Fore, Style=Style))


    def MD5(self, input):
        m = hashlib.md5()
        m.update(input.encode('utf-8'))
        return m.hexdigest()


    def SHA1(self, input):
        m = hashlib.sha1()
        m.update(input.encode('utf-8'))
        return m.hexdigest()


    def get_exchanges(self):
        # Receiving exchanges data
        try:
            cql = f"select * from {self.config.exchanges_table} where enabled=true allow filtering;"
            res = self.session.execute(cql, timeout=10)
            self.df_exchanges = res._current_rows
            self.exchanges_list = self.df_exchanges.id.tolist()

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"Error in {__file__}.get_exchanges(). {} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))

    def get_tokens(self):
        # tokens
        try:
            cql = f"select * from {self.config.tokens_table} where enabled=true allow filtering;"
            res = self.session.execute(cql, timeout=10)
            self.df_tokens = res._current_rows
            self.tokens_list = self.df_tokens.symbol.tolist()
            self.low_fee_tokens = self.df_tokens[self.df_tokens.low_fee==1].symbol.tolist()
            self.high_volume_tokens = self.df_tokens[self.df_tokens.high_volume==1].symbol.tolist()

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))        


    def get_pairs(self):
        # tokens
        try:
            cql = f"select * from {self.config.pairs_table} where enabled=true allow filtering"
            res = self.session.execute(cql, timeout=10)
            self.df_pairs = res._current_rows
            self.pairs = pd.DataFrame(self.df_pairs.groupby(['pair'])['exchange'].apply(list)).exchange.to_dict()
            self.exchanges = self.df_pairs.groupby(['exchange'])['pair'].apply(list).to_dict()
            
        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))        


    def batch_insert(self, cql_list):
        try:
            batch = BatchStatement(consistency_level=ConsistencyLevel.LOCAL_QUORUM)
            for cql in cql_list:
                batch.add(cql)
            self.session.execute(batch, timeout=30)

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"Error in {__file__}.batch_insert(). {} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))


    def __del__(self):
        try:
            #self.session.close()
            pass
        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))
        

    # async def _get_last_access(self, exchange, pair):
    #     await asyncio.sleep(0)
    #     cql = f"""SELECT ts FROM {self.config.data_keyspace}.{self.config.history_table} 
    #                         WHERE exchange='{exchange}' and pair='{pair}' LIMIT 1"""
    #     res = self.session.execute(cql, timeout=5)
    #     df = res._current_rows
    #     if len(df)>0:
    #         self._cache[exchange][pair] = int(df.iloc[0].values[0].astype(np.uint64)/1e6)
    #     else:
    #         self._cache[exchange][pair] = None
    #     logging.info(f"{exchange}, {pair} fetched {self._cache[exchange][pair]}")


    #def get_last_access(self, exchange, pair):
    def get_last_access(self):
        try:
            timer = Timer()
            logging.info("Starting async get_last_access")
            self.get_pairs()
            # loop = asyncio.get_event_loop()
            # tasks = []
            # for exchange in self.exchanges_list:
            #     self._cache[exchange] = {}
            #     for pair in self.exchanges[exchange]:
            #         tasks.append(self._get_last_access(exchange, pair))

            # loop.run_until_complete(asyncio.wait(tasks))

            # Using cool C* PER PARTITION trick for fetching last access times in single pass
            cql = "select * from arbitron.history per partition limit 1"
            res = self.session.execute(cql, timeout=5)
            df = res._current_rows
            
            # getting tuples of (exchange, pair, timestamp) from dataframe:
            ex_pair_ts = [(ex, pair, int(ts/1e6)) for ex, pair, ts in zip(df.exchange.values, df.pair.values, df.ts.values.astype(np.uint64))]

            # converting all this to dict
            self._cache = {}
            for ex, p, ts in ex_pair_ts:
                if ex not in self._cache:
                    self._cache[ex] = {}
                if p not in self._cache[ex]:
                    self._cache[ex][p] = {}
                self._cache[ex][p] = ts

            logging.info(f"Finished get_last_access for {timer.tic()} seconds")

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))


if __name__ == '__main__':
    print("This file is not intened for direct execution")