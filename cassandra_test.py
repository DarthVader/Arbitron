import pandas as pd

from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthenticator
from cassandra.query import dict_factory

def pandas_factory(colnames, rows):
    return pd.DataFrame(rows, columns=colnames)

#auth_provider = PlainTextAuthenticator(username='', password='')
cluster = Cluster(contact_points=['10.7.0.10'], port=9042) #, auth_provider=auth_provider)

session = cluster.connect(keyspace='history')
session.row_factory = pandas_factory
session.default_fetch_size = None

cql = "SELECT id, name FROM test"

res = session.execute(cql, timeout=None)
df = res._current_rows

print(df)
