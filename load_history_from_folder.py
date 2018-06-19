import os, glob, hashlib, sys
import argparse
import subprocess
#from datetime import datetime
#from cassandra.cluster import Cluster


timehash_depth = 10 # hashing power to eliminate duplicates using concurrent writes
sep = "," # csv separator
date_formatter = "%Y-%m-%d %H:%M:%S.%f"
host = "127.0.0.1"
user = "cassandra"
password = "cassandra"


def MD5(input):
    # returns MD5 in numeric form
    # https://github.com/bharatendra/ctools/blob/master/token.py
    m = hashlib.md5()
    m.update(input.encode('utf-8'))
    return m.hexdigest()
    # Calculate MD5 digest and convert it to hex format
    # digest = m.hexdigest()
    # # Convert the hash digest to 2's complement form 
    # token = int(digest, 16)
    # bits = 128
    # if ((token & (1 << (bits - 1))) != 0):
    #     token = token - (1 << bits)
    #check if reverse function holds true
    # checkback = hex(token)
    # Convert the resulting number to unsigned form
    # return abs(token)


def SHA1(input):
    m = hashlib.sha1()
    m.update(input.encode('utf-8'))
    return m.hexdigest()

# def write2Cassandra(cql):
#     res = True
#     try:
#         session.execute(cql, timeout=5)
#     except:
#          print("failed to write to Cassandra")
#          res = False
#     return res


if __name__ == '__main__':
    print("Loading CSV file(s) to Cassandra database")
    ap = argparse.ArgumentParser()
    ap.add_argument("-f", "--file", required=True, help="file name")
    args = vars(ap.parse_args())

    # print("Connecting to Cassandra instance...", end="", flush=False)
    # cluster = Cluster(contact_points=['127.0.0.1'], port=9042) #, auth_provider=auth_provider)
    # session = cluster.connect(keyspace='alpha')
    # print("Done.")
    
    file_in = os.getcwd() + "/" + args["file"].strip()
    # file_out = "temp_" + os.path.splitext(os.path.basename(file_in))[0] + ".csv"
    file_out = os.path.abspath(os.path.join(os.getcwd(), os.pardir)) + "/temp.csv"

    #for file in files:
    print("{} -> {}".format(os.path.basename(file_in), os.path.basename(file_out)))
    with open(file_out, 'w') as fo:
        fo.write('id,exchange,symbol,tdate,price,amount,side\n')
        with open(file_in, 'r') as fi:            
            last_hash = "" # here we init last_hash each time when loading file from CSV
            
            #id, exchange, symbol, tdate, price, amount, side
            for line in fi: # lines
                _, ts, _, exchange, symbol, price, amount, _, side = line[:-1].split(sep) # load values from current line
                md5 = MD5("{},{},{},{},{},{}".format(exchange, symbol, ts, price, amount, side))
                #sha1 = SHA1("{},{},{},{},{},{}".format(exchange, symbol, ts, price, amount, side))
                
                if last_hash == "":
                    # In main ccxt loader - get last hash and last date using following CQL: 
                    # SELECT id, tdate FROM history WHERE exchange='...' AND symbol='...' LIMIT 1
                    # then perform ccxt.fetch_trades(pair, since=tdate)
                    # then calculate next key using MD5(last_id + MD5(fetched_data))
                    key = md5
                else: 
                    # very important to keys uniqueness is to keep adding up to previous one (rolling hash)
                    key = MD5(last_hash + md5)
                last_hash = key # remember current hash

                fo.write("{},{},{},{},{},{},{}\n".format(key, exchange, symbol, ts, price, amount, side))

                # cql = "INSERT INTO beta.history (id, exchange, symbol, tdate, price, amount, side) " \
                #       "VALUES('{}', '{}', '{}', {}, {}, {}, '{}') IF NOT EXISTS".format(key, exchange, symbol, ts, price, amount, side)     
                # print(cql)
                # session.execute(cql, timeout=5)

    print("Running script in cqlsh:")
    cql = "COPY beta.history(id,exchange,symbol,tdate,price,amount,side) FROM '{}' WITH DELIMITER='{}' AND HEADER=TRUE".format(file_out, sep)
    cql = 'cqlsh -e "{}"'.format(cql)
    print("\t"+cql)
    
    process = subprocess.Popen(cql, shell=True)
    exitCode = process.wait()
    
    # if exitCode == 0:
    #     print("{} inserted to Cassandra.".format(os.path.basename(file_in)))
    # else:
    #     print("-- {} HAS NOT been inserted to Cassandra!".format(os.path.basename(file_in)))