import pika
import os, sys, argparse, time, socket, ipgetter
import numpy as np
from ipaddress import ip_address
from colorama import init, Fore, Back, Style # color printing
from time import sleep
from datetime import datetime, timezone, timedelta
from pytz import utc
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import requests, json
from requests.auth import HTTPBasicAuth
from pprint import pprint

worker_version = '1.0.7'

date_formatter = "%Y-%m-%d %H:%M:%S.%f"
host = "127.0.0.1"
user = "cassandra"
password = "cassandra"
nodes = ['127.0.0.1', '10.7.0.11', '10.7.0.10', '10.7.0.20']

rabbit_nodes = ['10.7.0.11']
rabbit_port = 15672  # for getActiveWorkers. It uses http api of rabbitmq_management plugin
rabbit_user= "rabbit"
rabbit_pass= "rabbit"
queue_name = "pacemaker"

common_delay = 3000
workers_table = 'temp.workers'
log_table = 'temp.log'
exchange = 'Test exchange'
ttl_factor = 6 # time to live. Worker is assumed to be dead after expiration time, defined as [common_delay * ttl_factor].


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


def getTimestamp(dt):
    return int(dt.replace(tzinfo=timezone.utc).timestamp()*1000 + dt.microsecond/1000)
    #return int(time.mktime(d.timetuple())*1e3 + d.microsecond/1e3)


def getActiveWorkers():
    req = "http://{}:{}/api/consumers".format(rabbit_nodes[0], rabbit_port)
    consumers = requests.get(req, auth=HTTPBasicAuth(rabbit_user, rabbit_pass)).json()
    workers = [x['queue']['name'] for x in consumers]
    return workers


def callback(ch, method, properties, body):

    try:
        #print("- Received pace signal from {}".format(str(body)))
        start = getCurrentTimestamp() # starting time

        batch = BatchStatement(consistency_level=ConsistencyLevel.ONE)
        timestamp = getCurrentTimestamp()
        last_run = timestamp
        # Fetch history, orderbook START
        # ---
        # Fetch history, orderbook END
        exchange = 'Test'
        worker_delay = 0
        #workers_count = len(getActiveWorkers())

        pprint(body.decode()) # need to be decoded in order to remove leading 'b' symbol

        # if you see "tuple index out of range" - it means that something is wrong with parameters, quotes or commas in the following cql
        cql = "INSERT INTO {} (exchange, ip, last_run, common_delay, worker_name, worker_version) " \
                "VALUES('{}', '{}', {}, {}, '{}', '{}') USING TTL {}".format(workers_table, 
                exchange, ip, last_run, common_delay, worker_name, worker_version, 
                int(common_delay/1000 * ttl_factor))

        #session.execute(cql, timeout=5)
        batch.add(cql)

        # insert to log
        message = "{}".format(host_name)
        cql = "INSERT INTO {0} (id, ip, last_run, worker_version, message) " \
            "VALUES(now(), '{1}', {2}, '{3}', '{4}')".format(log_table, 
                            ip, timestamp, worker_version, message)
        
        #session.execute(cql, timeout=5)
        batch.add(cql) 
        
        #now = getCurrentTimestamp()
        session.execute(batch, timeout=common_delay)
        print("{} - {Fore.GREEN}{}{Fore.RESET} -> {Fore.CYAN}{}{Fore.RESET},  " \
            "last_run: {},  pace signal: {}".format(
                datetime.now(), ip, workers_table, last_run, body.decode('utf-8'), Fore=Fore))
    
    except Exception as e:
        print("\n".format(e))


if __name__ == '__main__':
    init(convert=True) # colorama init  
    worker_name = os.path.basename(__file__)

    init(convert=True) # color printing
    # ap = argparse.ArgumentParser()
    # ap.add_argument("--ip", nargs="?", type=ip_address, dest='ip', required=True, help="ip address")
    # args = vars(ap.parse_args())
    # ip = args['ip']
    ip = "8.8.8.8"
    while ip == "8.8.8.8":   # Ugly workaround to overcome bug in ipgetter!
        ip = ipgetter.myip() # Sometimes it returns google address 8.8.8.8

    host_name = socket.gethostname()

    print("Worker v.{}".format(worker_version))

    ##--------------- Message broker ------------------
    print("Connecting to pacemaker server...", end='', flush=False)
    try:
        cred = pika.credentials.PlainCredentials(username=rabbit_user, password=rabbit_pass)
        connection = pika.BlockingConnection(pika.ConnectionParameters(rabbit_nodes[0], credentials=cred))
        channel = connection.channel()
        channel.queue_declare(queue="{}".format(ip), durable=False)

    except Exception as e:
        print(Fore.RED+Style.BRIGHT+"FAILED!{Style.RESET_ALL}\nCannot connect to pacemaker".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()

    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)

    ##--------------- Database ------------------
    print("Connecting to Cassandra instance from IP={Fore.GREEN}{Style.BRIGHT}{} ({}){Style.RESET_ALL}".format(ip, host_name, Fore=Fore, Style=Style)) #, end="", flush=False)
    try:
        cluster = Cluster(contact_points=nodes, port=9042) #, auth_provider=auth_provider)
        session = cluster.connect(keyspace='temp')

    except Exception as e: #OSError as e:
        print(Fore.RED+Style.BRIGHT+"{}{Style.RESET_ALL}".format(e.args[0], Style=Style))
        sys.exit()
    
    try:
        # cred = pika.credentials.PlainCredentials(username="mike", password="cawa")
        # connection = pika.BlockingConnection(pika.ConnectionParameters('10.7.0.11', credentials=cred))
        # channel = connection.channel()
        # channel.basic_consume(callback, queue="{}".format(ip), no_ack=True)

        channel.basic_consume(callback, queue="{}".format(ip), no_ack=True)
        print("Waiting for pacemaker signal... To exit press Ctrl+C", end="\r", flush=True)
        channel.start_consuming()

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")
        connection.close()

    except Exception as e:
        print("\n".format(e))
        connection.close()
    
        
