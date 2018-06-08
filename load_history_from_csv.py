import os, uuid, glob, hashlib
import collections
import argparse
#from datetime import datetime
from cassandra.cluster import Cluster


timehash_depth = 10 # hashing power to eliminate duplicates using concurrent writes
sep = "," # csv separator
date_formatter = "%Y-%m-%d %H:%M:%S.%f"


def MD5(input):
    m = hashlib.md5()
    m.update(input.encode('utf-8'))
    return m.hexdigest()


def deq_MD5(deq):
    """
    MD5 hash of double-ended queue
    """
    text = ""
    for s in deq:
        _, tdate, _, exchange, symbol, price, amount, _, side = s
        text += "{},{},{},{},{},{},".format(exchange, symbol, tdate, price, amount, side)
    return MD5(text)


def write2Cassandra(cql):
    res = True
    try:
        session.execute(cql, timeout=5)
    except:
         print("failed to write to Cassandra")
         res = False
    return res


if __name__ == '__main__':
    print("Preparing CSV file(s) for Cassandra database")
    ap = argparse.ArgumentParser()
    ap.add_argument("-f", "--file", required=True, help="file name")
    args = vars(ap.parse_args())
    file_in = os.getcwd() + "/" + args["file"].strip()
    file_out = os.path.dirname(file_in) + "/upload_" + os.path.splitext(os.path.basename(file_in))[0] + ".csv"

    cluster = Cluster(contact_points=['127.0.0.1'], port=9042) #, auth_provider=auth_provider)
    session = cluster.connect(keyspace='alpha')

    #folder = os.getcwd() + "/data/history_ETH/*.csv"
    #files = list([f for f in glob.glob(folder)])

    #for file in files:
    print("{} -> {}".format(os.path.basename(file_in), os.path.basename(file_out)))
    with open(file_out, 'w') as fo:
        fo.write('id,exchange,symbol,tdate,price,amount,side\n')
        with open(file_in, 'r') as fi:
            #lines = fi.readline()
            deq = collections.deque(maxlen=timehash_depth)
            
            #id, exchange, symbol, tdate, price, amount, side
            for line in fi: #lines:
                data = line[:-1].split(sep)
                deq.append(data)
                key = deq_MD5(deq)

                _, ts, _, exchange, symbol, price, amount, _, side = data
                #sts = ts[:-3] + "." + ts[-3:] # insert delimiter into string representation of timestamp
                #tdate = datetime.utcfromtimestamp(float(sts)).strftime("%Y-%m-%d %H:%M:%S.%f") # tdate - formatted timestamp
                md5 = MD5("{},{},{},{},{},{},".format(exchange, symbol, ts, price, amount, side))
                #fo.write("'{}','{}','{}',{},{},{},'{}'\n".format(key, exchange, symbol, ts, price, amount, side))
                fo.write("{},{},{},{},{},{},{}\n".format(key, exchange, symbol, ts, price, amount, side))

                # cql = "INSERT INTO alpha.history (id, exchange, symbol, tdate, price, amount, side) " \
                #       "VALUES('{}', '{}', '{}', {}, {}, {}, '{}') IF NOT EXISTS".format(key, exchange, symbol, ts, price, amount, side)     
                # print(cql)
                # session.execute(cql, timeout=5)

    print("Done. Run following script in cqlsh:\n")
    print("COPY alpha.history(id,exchange,symbol,tdate,price,amount,side) FROM '{}' WITH DELIMITER='{}' AND HEADER=TRUE AND DATETIMEFORMAT='{}';\n".format(
        os.path.basename(file_out), sep, date_formatter))
