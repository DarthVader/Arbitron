import os, sys, argparse, time, socket, ipgetter
import numpy as np
from ipaddress import ip_address
from colorama import init, Fore, Back, Style # color printing
from time import sleep
from datetime import datetime, timezone, timedelta
from pytz import utc
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel


date_formatter = "%Y-%m-%d %H:%M:%S.%f"
host = "127.0.0.1"
user = "cassandra"
password = "cassandra"
nodes = ['127.0.0.1', '10.7.0.10', '10.7.0.20']
common_delay = 3000
worker_version = '1.0.1'
workers_table = 'temp.workers'
log_table = 'temp.log'
exchange = 'Test exchange'
ttl_factor = 6 # time to live. Worker is assumed to be dead after expiration time, defined as [common_delay * ttl_factor].


def Select(cql):
    #print(cql)
    rows = session.execute(cql, timeout=5)
    # cols = ""
    # for col in rows.column_names:
    #     cols += "{}\t".format(col)
    # print(cols)

    for row in rows:
        r = ""
        for i in range(len(row._fields)):
            r = r + "{}\t".format(row[i])
        print(r)


def Insert(cql):
    print(cql)
    session.execute(cql, timeout=5)


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


def getTimestamp(dt):
    return int(dt.replace(tzinfo=timezone.utc).timestamp()*1000 + dt.microsecond/1000)
    #return int(time.mktime(d.timetuple())*1e3 + d.microsecond/1e3)


def getWorkersCount():
    cql = "select count(*) from {} limit 1".format(workers_table)
    try:
        for row in session.execute(cql, timeout=5):
            total_workers = row[0]     
    except Exception as e:
        total_workers = None
    finally:
        return total_workers


if __name__ == '__main__':
    worker_name = os.path.basename(__file__)

    init(convert=True) # color printing
    # ap = argparse.ArgumentParser()
    # ap.add_argument("--ip", nargs="?", type=ip_address, dest='ip', required=True, help="ip address")
    # args = vars(ap.parse_args())
    # ip = args['ip']
    ip = ipgetter.myip()
    host_name = socket.gethostname()

    print("Connecting to Cassandra instance from IP={Fore.GREEN}{}{Fore.RESET}, HOST={}".format(ip, host_name, Fore=Fore)) #, end="", flush=False)
    try:
        cluster = Cluster(contact_points=nodes, port=9042) #, auth_provider=auth_provider)
        session = cluster.connect(keyspace='temp')
        
    except Exception as e: #OSError as e:
        print("{Fore.RED} {} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()
    
    try:
        while True:
            start = getCurrentTimestamp() # starting time
            total_workers = getWorkersCount()
            #cql = "select * from {} where ip='{}' and exchange='{}' limit 1".format(workers_table, ip, exchange)
            cql = "select * from {} where exchange='{}' limit 1".format(workers_table, exchange)
            res = session.execute(cql)
            if len(res.current_rows) == 0: # empty workers table
                # insert initial rows to workers table
                last_run = None
                worker_last_run = None
                worker_delay = 0
                workers_count = total_workers + 1
                message = "newbie"
            else:
                for row in res:
                    last_run = row.last_run
                    worker_last_run = row.worker_last_run
                    worker_delay = row.worker_delay
                    worker_name = row.worker_name
                    workers_count = row.workers_count
                    break
                #message = exchange
                # Insert synchronization delay calculation...
                if workers_count != total_workers and total_workers != 0:
                    #print(last_run)
                    #worker_delay = int(datetime.utcnow() - last_run + timedelta(milliseconds = (common_delay / workers_count + common_delay)))
                    #worker_delay = last_run + timedelta(milliseconds=common_delay / workers_count) - datetime.now()
                    #print(worker_delay)
                    #sleep(worker_delay / 1000)
                    pass
                else:
                    worker_delay = 0
                # Synchronization delay calculation ends

            batch = BatchStatement(consistency_level=ConsistencyLevel.ONE)
            timestamp = getCurrentTimestamp()
            # Fetch history, orderbook START
            # ---
            # Fetch history, orderbook END
            cql = "INSERT INTO {} (exchange, ip, last_run, worker_last_run, common_delay, worker_delay, worker_name, worker_version, workers_count) " \
                    "VALUES('{}', '{}', {}, {}, {}, {}, '{}', '{}', {}) USING TTL {}".format(workers_table, exchange,
                    ip, timestamp, timestamp, common_delay, worker_delay, worker_name, worker_version, workers_count, int(common_delay/1000 * ttl_factor))
            #session.execute(cql, timeout=5)
            batch.add(cql)

            # insert to log
            message = "worker={}, delay={}".format(host_name, common_delay + worker_delay)
            cql = "INSERT INTO {} (id, ip, last_run, worker_last_run, worker_version, workers_count, message) " \
                "VALUES(now(), '{}', {}, {}, '{}', {}, '{}')".format(log_table, ip, timestamp, timestamp, worker_version, workers_count, message)
            
            #session.execute(cql, timeout=5)
            batch.add(cql)
            
            now = getCurrentTimestamp()
            
            lag = 0
            if last_run != None:
                ts = getTimestamp(last_run)
                lag = (now - start)
                delay = np.max(common_delay - (now - ts)/1000, 0) - lag  # the last lag/2 - is approximate time for session to execute batch query
            else: 
                delay = common_delay
            
            #lag = timedelta(days=0, seconds=tdelta.seconds, microseconds=tdelta.microseconds)
            #time.sleep(np.max((common_delay-lag),0) / 1000)
            time.sleep(delay / 1000)
            session.execute(batch, timeout=common_delay)

            print("{} - {Fore.GREEN}{}{Fore.RESET} -> {Fore.CYAN}{}{Fore.RESET},  active workers: {Fore.YELLOW}{}{Fore.RESET},  last_run: {},  inner lag: {} ms,  delay: {} ms".format(
                    datetime.now(), ip, workers_table, workers_count, last_run, lag, delay, Fore=Fore))           

            

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")

    except Exception as e:
        print(e)
        



    #print("Done.")