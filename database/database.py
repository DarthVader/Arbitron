#!/usr/bin/python3.6

# Arbitron project database driver
__version__ = '1.0.2'

from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import sys, os, hashlib
import time
from datetime import datetime, timezone, timedelta
from colorama import init, Fore, Back, Style # color printing
import pandas as pd

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(root)
from settings.settings import Settings


class Database():
    
    def _pandas_factory(self, colnames, rows):
        return pd.DataFrame(rows, columns=colnames)


    def __init__(self):
        init(convert=True) # colorama init 
        self.ex_pairs = {} # special hierarchical structure which will contain exchanges and their pairs
        #self.config = config # config instance from INI file
        self.config = Settings()
        print("Connecting to database...".format(), end="", flush=False)
        try:
            cluster = Cluster(contact_points=self.config.cassandra_nodes, 
                              port=self.config.cassandra_port)
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
            
            #for _, row in self.df_pairs.iterrows():
            #    ex, pair = row[0], row[1]
            #    self.ex_pairs[ex] = pair
            
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
        

    def get_last_access(self, exchange, pair):
        try:
            cql = f"""SELECT ts FROM {self.config.data_keyspace}.{self.config.history_table} 
                      WHERE exchange='{exchange}' and pair='{pair}' LIMIT 1"""
            res = self.session.execute(cql, timeout=5)
            return None

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))


if __name__ == '__main__':
    print("This file is not intened for direct execution")