import pandas as pd

from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthenticator
from cassandra.query import dict_factory

def pandas_factory(colnames, rows):
    return pd.DataFrame(rows, columns=colnames)

#auth_provider = PlainTextAuthenticator(username='cassandra', password='cassandra')
cluster = Cluster(contact_points=['127.0.0.1'], port=9042) #, auth_provider=auth_provider)
#cluster = Cluster(contact_points=['10.7.0.21'], port=9042)

session = cluster.connect(keyspace='history')
session.row_factory = pandas_factory
session.default_fetch_size = 10

cql = "SELECT * FROM alpha.history LIMIT 20"

res = session.execute(cql, timeout=5)
df = res._current_rows

print(df)
