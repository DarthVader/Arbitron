#!/usr/bin/python3.6

# worker
# collects historic/orderbook data from exchanges using ccxt library
__version__ = '1.1.7'

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
from database import Database
from markets.markets import Markets


print(f"Worker: {__version__}")
cfg = Settings()      # read settings from INI file (singleton)
#db = Database()       # connecting to database (singleton)
#markets = Markets(db) # Markets library instance (singleton)

common_delay = 3000   # stub !!!
exchange = 'RabbitMQ' # stub !!!
date_formatter = "%Y-%m-%d %H:%M:%S.%f"


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


# def getTimestamp(dt):
#     return int(dt.replace(tzinfo=timezone.utc).timestamp()*1000 + dt.microsecond/1000)
#     #return int(time.mktime(d.timetuple())*1e3 + d.microsecond/1e3)


# def getActiveWorkers():
#     req = "http://{}:{}/api/consumers".format(cfg.rabbit_nodes[0], cfg.rabbit_port)
#     consumers = requests.get(req, auth=HTTPBasicAuth(cfg.rabbit_user, cfg.rabbit_pass)).json()
#     workers = [x['queue']['name'] for x in consumers]
#     return workers


def callback(ch, method, properties, body):

    try:
        #print("- Received pace signal from {}".format(str(body)))
        #start = getCurrentTimestamp() # starting time
        batch = BatchStatement(consistency_level=ConsistencyLevel.LOCAL_QUORUM)
        timestamp = getCurrentTimestamp()
        last_run = timestamp

        # Parsing body to fetch exchanges, pairs and rate limits
        #body = body.decode() # string values need to be decoded in order to remove leading 'b' symbol
        body = json.loads(body)

        job                 = body['job']
        pacemaker_version   = body['version']
        pacemaker_time      = body['timestamp']

        # Fetch history, orderbook START
        markets.process_job(body, db) # <== pass job to Markets class which fetches history and orderbook then saves them to database
        # Fetch history, orderbook END

        # if you see "tuple index out of range" - it means that something is wrong with parameters, quotes or commas in the following cql
        ttl = int(common_delay/1000 * int(cfg.ttl_factor))
        cql = f"INSERT INTO {cfg.workers_table} (exchange, ip, last_run, common_delay, worker_name, worker_version) " \
            f"VALUES('{exchange}', '{ip}', {last_run}, {common_delay}, '{worker_name}', '{__version__}') USING TTL {ttl}"                
        batch.add(cql)

        # insert to log
        # message = "{}".format(host_name)
        log_message = ""
        for ex in job.keys():
            log_message += f"{ex}: ["
            for pair in job[ex]['pairs']:
                log_message += f"{pair},"
            log_message += "]\n"


        cql = f"INSERT INTO {cfg.log_table} (id, ip, job, pacemaker, worker) VALUES(now(), \
            '{ip}', '{log_message}', '{pacemaker_version}', '{__version__}')"
        
        batch.add(cql)
        
        #now = getCurrentTimestamp()
        db.session.execute(batch, timeout=common_delay)
        print(f"{datetime.now()}, [{Fore.GREEN}{ip}{Fore.RESET}] monitoring: {Fore.CYAN}{cfg.workers_table}{Fore.RESET}, " \
            f"last_run: {last_run}, pacemaker {pacemaker_version} ts: {pacemaker_time} ".format(Fore=Fore))
        
        #channel.basic_ack()
        #print(f"Waiting {delay/1000} seconds...", end="\r", flush=True)

    except Exception as e:
        print(f"Error in {__file__}.callback(). {Fore.RED}{e}{Fore.RESET}")



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
        ip = ipgetter.myip() # This bug sometimes returns google address 8.8.8.8 instead of the real one
    host_name = socket.gethostname()
    print(Fore.GREEN+Style.BRIGHT+f"Worker IP={ip}, host name={host_name})"+Style.RESET_ALL)

    ##--------------- Message broker ------------------
    print("Connecting to pacemaker...", end='', flush=False)
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
    db = Database()
    #db.get_exchanges()
    #my_exchanges = db.exchanges_list
    #db.get_last_access()

    print(Fore.GREEN+Style.BRIGHT+f"{cfg.cassandra_nodes}"+Style.RESET_ALL)

    ##------------------- CCXT ---------------------
    print("Connecting to exchanges...".format(), end="\n", flush=False)
    markets = Markets(db)
    markets.load_exchanges(exchanges_list=db.exchanges_list)
    print(Fore.GREEN+Style.BRIGHT+"READY."+Style.RESET_ALL)

    
    try:
        channel.basic_qos(prefetch_count=1)
        channel.basic_consume(callback, queue="{}".format(ip), no_ack=True)
        print("Waiting for jobs... To exit press Ctrl+C", end="\r", flush=True)
        channel.start_consuming()

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")
        connection.close()

    except Exception as e:
        print(e)
        connection.close()