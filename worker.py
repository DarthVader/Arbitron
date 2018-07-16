#!/usr/bin/python3.6

# worker
__version__ = '1.0.9'

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
from settings import Settings


cfg = Settings() # read settings from INI file

common_delay = 3000
exchange = 'Test exchange'
date_formatter = "%Y-%m-%d %H:%M:%S.%f"


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


def getTimestamp(dt):
    return int(dt.replace(tzinfo=timezone.utc).timestamp()*1000 + dt.microsecond/1000)
    #return int(time.mktime(d.timetuple())*1e3 + d.microsecond/1e3)


def getActiveWorkers():
    req = "http://{}:{}/api/consumers".format(cfg.rabbit_nodes[0], cfg.rabbit_port)
    consumers = requests.get(req, auth=HTTPBasicAuth(cfg.rabbit_user, cfg.rabbit_pass)).json()
    workers = [x['queue']['name'] for x in consumers]
    return workers


def callback(ch, method, properties, body):

    try:
        #print("- Received pace signal from {}".format(str(body)))
        #start = getCurrentTimestamp() # starting time

        batch = BatchStatement(consistency_level=ConsistencyLevel.ONE)
        timestamp = getCurrentTimestamp()
        last_run = timestamp
        # Fetch history, orderbook START
        # ---
        # Fetch history, orderbook END
        #exchange = 'Test'
        #worker_delay = 0
        #workers_count = len(getActiveWorkers())

        print(body.decode()) # need to be decoded in order to remove leading 'b' symbol

        # if you see "tuple index out of range" - it means that something is wrong with parameters, quotes or commas in the following cql
        ttl = int(common_delay/1000 * cfg.ttl_factor)
        cql = f"INSERT INTO {cfg.workers_table} (exchange, ip, last_run, common_delay, worker_name, worker_version) " \
            f"VALUES('{exchange}', '{ip}', {last_run}, {common_delay}, '{worker_name}', '{__version__}') USING TTL {ttl}"                

        #session.execute(cql, timeout=5)
        batch.add(cql)

        # insert to log
        message = "{}".format(host_name)
        cql = f"INSERT INTO {cfg.log_table} (id, ip, last_run, worker_version, message) " \
            f"VALUES(now(), '{ip}', {timestamp}, '{__version__}', '{message}')"
        
        #session.execute(cql, timeout=5)
        batch.add(cql) 
        
        #now = getCurrentTimestamp()
        session.execute(batch, timeout=common_delay)
        print("{} - {Fore.GREEN}{}{Fore.RESET} -> {Fore.CYAN}{}{Fore.RESET},  " \
            "last_run: {},  pace signal: {}".format(
                datetime.now(), ip, cfg.workers_table, last_run, body.decode('utf-8'), Fore=Fore))
    
    except Exception as e:
        print(e)


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

    print("Worker version {}".format(__version__))

    ##--------------- Message broker ------------------
    print("Connecting to pacemaker server...", end='', flush=False)
    try:
        cred = pika.credentials.PlainCredentials(username=cfg.rabbit_user, password=cfg.rabbit_pass)
        connection = pika.BlockingConnection(pika.ConnectionParameters(cfg.rabbit_nodes[0], credentials=cred))
        channel = connection.channel()
        channel.queue_declare(queue="{}".format(ip), durable=False)

    except Exception as e:
        print(Fore.RED+Style.BRIGHT+f"FAILED!{Style.RESET_ALL}\nCannot connect to pacemaker")
        sys.exit()

    print(Fore.GREEN+Style.BRIGHT+f"{cfg.rabbit_nodes[0]}"+Style.RESET_ALL)

    ##--------------- Database ------------------
    print("Connecting to Cassandra instance from IP={Fore.GREEN}{Style.BRIGHT}{} ({}){Style.RESET_ALL}".format(ip, host_name, Fore=Fore, Style=Style)) #, end="", flush=False)
    try:
        cluster = Cluster(contact_points=cfg.cassandra_nodes, port=9042)
        session = cluster.connect(keyspace='temp')

    except Exception as e: #OSError as e:
        print(Fore.RED+Style.BRIGHT+"{}{Style.RESET_ALL}".format(e.args[0], Style=Style))
        sys.exit()
    
    try:
        channel.basic_consume(callback, queue="{}".format(ip), no_ack=True)
        print("Waiting for pacemaker signals... To exit press Ctrl+C", end="\r", flush=True)
        channel.start_consuming()

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")
        connection.close()

    except Exception as e:
        print(e)
        connection.close()