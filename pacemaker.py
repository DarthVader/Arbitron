#!/usr/bin/python3.6

# messaging server

import pika
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import sys
from time import sleep
from datetime import datetime, timezone, timedelta
from colorama import init, Fore, Back, Style # color printing
import requests, json
from requests.auth import HTTPBasicAuth
import pandas as pd
from pprint import pprint
import asyncio
import ccxt.async as ccxt
from ccxt.async import Exchange


db_user = "cassandra"
db_password = "cassandra"
cassandra_port = 9042
cassandra_nodes = ['127.0.0.1', '10.7.0.11', '10.7.0.20']
#cassandra_nodes = ['10.7.0.56']

__version__ = '1.1.0'
rabbit_nodes = ['10.7.0.11', '127.0.0.1']
rabbit_port = 15672  # for getActiveWorkers. It uses http api of rabbitmq_management plugin
rabbit_user= "rabbit"
rabbit_pass= "rabbit"
queue_name = "pacemaker"

workers_table = 'temp.workers'
common_delay = 3000 ## stub !!!

# globals (BAD, I know)
fiat = ['USD','EUR','JPY','UAH','USDT','RUB','CAD','NZDT']
allowed_tsyms = ['USD', 'USDT', 'BTC', 'ETH', 'DOGE', 'LTC', 'EUR', 'RUB'] # allowed symbols for convertion to
low_fee_tokens = []
high_volume_tokens = []


def pandas_factory(colnames, rows):
    return pd.DataFrame(rows, columns=colnames)


def getCurrentTimestamp():
    fmt = "%Y-%m-%d %H:%M:%S.%f"
    dt = datetime.strptime(datetime.now().strftime(fmt), fmt)
    return int(time.mktime(dt.timetuple())*1000 + dt.microsecond/1000)


def getActiveWorkers():
    req = "http://{}:{}/api/consumers".format(rabbit_nodes[0], rabbit_port)
    consumers = requests.get(req, auth=HTTPBasicAuth(rabbit_user, rabbit_pass)).json()
    workers = [x['queue']['name'] for x in consumers]
    return workers



def Exchanges_Init(exchanges_list):
    exchanges = {}
    for id in exchanges_list:
        exchange = getattr(ccxt, id)
        # this option enables the built-in rate limiter <<=============
        exchange.enableRateLimit = True, 
        exchanges[id] = exchange()        
    return exchanges


async def Get_Exchange(exchange):
    await exchange.load_markets()
    print("{} market metadata loaded".format(exchange.name))


async def Exchanges_Load(exchanges):
    tasks = []
    for ex in exchanges.items():
        tasks.append(asyncio.ensure_future(Get_Exchange(ex[1])))
    await asyncio.gather(*tasks) 


async def Exchanges_Shutdown(exchanges):
    for ex in exchanges.items():
        print("Closing {}".format(ex[0]))
        await ex[1].close()




if __name__ == '__main__':
    init(convert=True) # colorama init
    print(f"Pacemaker v.{__version__}")

    ##--------------- Message broker ------------------
    print("Connecting to pacemaker...", end='', flush=False)
    try:
        cred = pika.credentials.PlainCredentials(username=rabbit_user, password=rabbit_pass)
        connection = pika.BlockingConnection(pika.ConnectionParameters(rabbit_nodes[0], credentials=cred))
        channel = connection.channel()
        channel.queue_declare(queue=queue_name, durable=False)
        
    except Exception as e:
        print(Fore.RED+Style.BRIGHT+"FAILED!{Style.RESET_ALL}\nCannot connect to pacemaker".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()
    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)

    ##--------------- Database ------------------
    print("Connecting to database cluster...".format(), end="", flush=False)
    try:
        cluster = Cluster(contact_points=cassandra_nodes, port=cassandra_port)
        session = cluster.connect(keyspace='settings')
        session.row_factory = pandas_factory
        session.default_fetch_size = 200
        
        # Receiving exchanges data
        cql = "select id, name, delay from settings.exchanges where enabled=true allow filtering;"
        res = session.execute(cql, timeout=10)
        df_exchanges = res._current_rows
        
        # tokens
        cql = "select * from tokens where enabled=true allow filtering;"
        res = session.execute(cql, timeout=10)
        df_tokens = res._current_rows

        low_fee_tokens = df_tokens[df_tokens.low_fee==1].symbol.tolist()
        high_volume_tokens = df_tokens[df_tokens.high_volume==1].symbol.tolist()

    except Exception as e:
        print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()
    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)

    ##------------------- CCXT ---------------------
    print("Connecting to exchanges...".format(), end="\n", flush=False)
    exchanges = Exchanges_Init(df_exchanges.id.values) # init by exchanges list from settings.exchanges table
    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(Exchanges_Load(exchanges))
    except KeyboardInterrupt:
        print("Leaving by Ctrl-C...")
        loop.run_until_complete(Exchanges_Shutdown(exchanges))
        sys.exit()

    #loop.run_until_complete(Exchanges_Shutdown(exchanges))
    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)


    # round-robin message dispatching
    while True:
        try:
            workers = getActiveWorkers() # get active RabbitMQ connections
            if len(workers) > 0:
                for worker in workers:
                    channel.basic_publish(exchange="", 
                                routing_key=worker, 
                                body="{}, pacemaker version: {}".format(worker, __version__),
                                properties=pika.BasicProperties(
                                    delivery_mode=2,
                                    expiration='{}'.format(int(common_delay))
                                )
                            )
                    print("{} - Active workers: {}. Pace signal has been sent to worker {}".format(
                            datetime.now(), len(workers), worker))
                    #i += 1
                    sleep(common_delay/len(workers)/1000)
            else:
                print("Waiting for workers...{0: <35}".format(" "), end="\r", flush=True)
                sleep(1)

        except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            loop.run_until_complete(Exchanges_Shutdown(exchanges))
            #connection.close()
            sys.exit()

        except Exception as e:
            loop.run_until_complete(Exchanges_Shutdown(exchanges))
            print(e)
            #connection.close()
            sys.exit()
