#!/usr/bin/python3.6

# pacemaker
# dispatching server
__version__ = '1.1.4'

import pika # RabbitMQ library
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import sys, os
import time
from time import sleep
from datetime import datetime, timezone, timedelta
from colorama import init, Fore, Back, Style # color printing
import requests, json
from requests.auth import HTTPBasicAuth
import pandas as pd
from pprint import pprint 
from markets.markets import Markets
from settings import Settings
from database import Database

cfg = Settings() # read settings from INI file
common_delay = 3000 ## stub !!!


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


def getActiveWorkers():
    req = "http://{}:{}/api/consumers".format(cfg.rabbit_nodes[0], cfg.rabbit_port)
    consumers = requests.get(req, auth=HTTPBasicAuth(cfg.rabbit_user, cfg.rabbit_pass)).json()
    workers = [x['queue']['name'] for x in consumers]
    return workers


if __name__ == '__main__':
    init(convert=True) # colorama init    
    print(f"Pacemaker {__version__}")
    print(f"pika version: {pika.__version__}")
    ##--------------- Message broker ------------------
    print("Connecting to pacemaker server...", end='', flush=False)
    try:
        cred = pika.credentials.PlainCredentials(username=cfg.rabbit_user, password=cfg.rabbit_pass)
        connection = pika.BlockingConnection(pika.ConnectionParameters(cfg.rabbit_nodes[0], credentials=cred))
        channel = connection.channel()
        channel.queue_declare(queue=cfg.queue_name, durable=False)
        
    except Exception as e:
        print(Fore.RED+Style.BRIGHT+f"FAILED!{Style.RESET_ALL}\nCannot connect to pacemaker")
        sys.exit()
    print(Fore.GREEN+Style.BRIGHT+f"{cfg.rabbit_nodes[0]}"+Style.RESET_ALL)

    ##--------------- Database ------------------
    db = Database()
    db.get_exchanges()
    db.get_tokens()
    db.get_pairs()
    my_exchanges = db.exchanges_list
    my_tokens = db.tokens_list
    print(Fore.GREEN+Style.BRIGHT+f"{cfg.cassandra_nodes}"+Style.RESET_ALL)

    ##------------------- CCXT ---------------------
    print("Connecting to exchanges...".format(), end="\n", flush=False)
    markets = Markets()
    markets.load_exchanges(exchanges_list=my_exchanges)
    print(Fore.GREEN+Style.BRIGHT+"READY."+Style.RESET_ALL)
    
    # Code for dispatching jobs to workers. (round-robin)
    while True:
        # There should be a code for creating and scheduling jobs for workers
        # Job must contains list of exchanges and pairs that should be queried and saved to database
        job = { 
            "version": f"{__version__}",
            "exchanges": {
                "yobit": {
                        "ratelimit": 3000,
                        "pairs": ["BCH/BTC"]
                },
                "binance": {
                        "ratelimit": 500,
                        "pairs": ["ADA/BTC","ADA/ETH","ADA/USDT","BCH/BTC","BCH/ETH","BCH/USDT"]
                },
                "okex": {
                        "ratelimit": 1000,
                        "pairs": ["BCH/BTC","BCH/ETH","BCH/USD"]
                },                
                "hitbtc2": {
                        "ratelimit": 1500,
                        "pairs": ["BCH/BTC", "BCH/ETH"]
                }
            },
            "timestamp": datetime.now().strftime("%d.%m.%Y %H:%M:%S.%f")
        }

        # calculating common delay

        try:
            workers = getActiveWorkers() # get active RabbitMQ connections
            if len(workers) > 0:
                for worker in workers:
                    channel.basic_publish(exchange="", 
                                routing_key=worker, 
                                body=json.dumps(job), # <<== assigning job to worker
                                properties=pika.BasicProperties(
                                    delivery_mode=2,
                                    expiration='{}'.format(int(common_delay))
                                )
                            )
                    print("{} - Active workers: {}. Pace signal has been sent to worker {}".format(
                            datetime.now(), len(workers), worker))
                    #i += 1
                    sleep(common_delay/len(workers)/1000)
                    #_ = input("Press ENTER to send next job...") ## - for testing purposes only! ## 
            else:
                print("Waiting for workers...{0: <35}".format(" "), end="\r", flush=True)
                sleep(0.5)

        except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            sys.exit()

        except Exception as e:
            print(e)

        