#!/usr/bin/python3.6

# Arbitron project database driver
__version__ = '1.0.0'

from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import sys, os
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
        #self.config = config # config instance from INI file
        self.config = Settings()
        print("Connecting to database...".format(), end="", flush=False)
        try:
            cluster = Cluster(contact_points=self.config.cassandra_nodes, 
                              port=self.config.cassandra_port)
            self.session = cluster.connect(keyspace=self.config.settings_keyspace)
            self.session.row_factory = self._pandas_factory
            self.session.default_fetch_size = self.config.default_fetch_size
        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))


    def get_exchanges(self):
        # Receiving exchanges data
        try:
            cql = f"select id, name, delay from {self.config.exchanges_table} where enabled=true allow filtering;"
            res = self.session.execute(cql, timeout=10)
            self.df_exchanges = res._current_rows
            self.exchanges_list = self.df_exchanges.id.tolist()

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))

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


    def batch_insert(self, cql_list):
        try:
            batch = BatchStatement(consistency_level=ConsistencyLevel.LOCAL_QUORUM)
            for cql in cql_list:
                batch.add(cql)
            self.session.execute(batch, timeout=30)

        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))


    def __del__(self):
        try:
            #self.session.close()
            pass
        except Exception as e:
            print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))
        