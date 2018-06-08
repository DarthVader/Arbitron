import os, uuid, glob, hashlib
import collections
from cassandra.cluster import Cluster


timehash_depth = 5 # hashing power to eliminate duplicates using concurrent writes
sep = "," # csv separator


def MD5(input):
    m = hashlib.md5()
    m.update(input.encode('utf-8'))
    return m.hexdigest()


def write2Cassandra(cql):
    res = True
    try:
        session.execute(cql, timeout=5)
    except:
         print("failed to write to Cassandra")
         res = False
    return res


if __name__ == '__main__':
    cluster = Cluster(contact_points=['127.0.0.1'], port=9042) #, auth_provider=auth_provider)
    session = cluster.connect(keyspace='alpha')

    folder = os.getcwd() + "/data/history_ETH/*.csv"
    files = list([f for f in glob.glob(folder)])

    for file in files:
        print(os.path.basename(file))
        with open(file, 'r') as f:
            lines = f.readlines()
            deq = collections.deque(maxlen=timehash_depth)

            for line in lines:
                data = line[:-1].split(sep)
                deq.append(data)
                hash = ""
                # we should use something more reliable for id - running Hash (Rabin-Karp?) for computing hash using previous N rows
                for s in deq:
                    _, tdate, _, exchange, symbol, price, amount, _, side = s
                    hash += "'{}' '{}' {} {} {} '{}' ".format(exchange, symbol, tdate, price, amount, side)

                hash = MD5(hash)
                cql = "INSERT INTO alpha.history (id, exchange, symbol, tdate, price, amount, side) VALUES('{}', '{}', '{}', {}, {}, {}, '{}')".format(hash, exchange, symbol, tdate, price, amount, side)
                #print(cql)
                session.execute(cql, timeout=5)
                #write2Cassandra(cql)
