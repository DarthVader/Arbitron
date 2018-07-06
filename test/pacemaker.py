# messaging server

import pika
from cassandra.cluster import Cluster, BatchStatement, ConsistencyLevel
import sys
from time import sleep
from colorama import init, Fore, Back, Style # color printing
import requests, json
from requests.auth import HTTPBasicAuth

db_user = "cassandra"
db_password = "cassandra"
cassandra_nodes = ['127.0.0.1', '10.7.0.11', '10.7.0.20']
#cassandra_nodes = ['10.7.0.56']

pacemaker_version = '1.0.3'
rabbit_nodes = ['10.7.0.11']
rabbit_port = 15672  # for getActiveWorkers. It uses http api of rabbitmq_management plugin
rabbit_user= "rabbit"
rabbit_pass= "rabbit"
queue_name = "pacemaker"

workers_table = 'temp.workers'
common_delay = 3000


def getWorkers(session):
    cql = "select ip, worker_name, worker_version from {}".format(workers_table)
    workers = []
    try:
        for row in session.execute(cql, timeout=5):
            workers.append({'ip': row[0], 'name': row[1], 'version': row[2]})
    except Exception:
        return []
    finally:
        return workers


def getActiveWorkers():
    req = "http://{}:{}/api/consumers".format(rabbit_nodes[0], rabbit_port)
    consumers = requests.get(req, auth=HTTPBasicAuth(rabbit_user, rabbit_pass)).json()
    workers = [x['queue']['name'] for x in consumers]
    return workers


if __name__ == '__main__':
    init(convert=True) # colorama init      
    print("Pacemaker v.{}".format(pacemaker_version))

    ##--------------- Message broker ------------------
    print("Connecting to pacemaker...", end='', flush=False)
    try:
        cred = pika.credentials.PlainCredentials(username=rabbit_user, password=rabbit_pass)
        connection = pika.BlockingConnection(
                        pika.ConnectionParameters(rabbit_nodes[0], credentials=cred))
        channel = connection.channel()
        channel.queue_declare(queue=queue_name, durable=False)
        
    except Exception as e:
        print(Fore.RED+Style.BRIGHT+"FAILED!{Style.RESET_ALL}\nCannot connect to pacemaker".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()
    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)

    ##--------------- Database ------------------
    print("Connecting to database cluster...".format(), end="", flush=False)
    try:
        cluster = Cluster(contact_points=cassandra_nodes, port=9042)
        session = cluster.connect(keyspace='temp')

    except Exception as e:
        print(Fore.RED+Style.BRIGHT+"{} {Style.RESET_ALL}".format(e.args[0], Fore=Fore, Style=Style))
        sys.exit()

    print(Fore.GREEN+Style.BRIGHT+"SUCCESS."+Style.RESET_ALL)

    # round-robin message dispatching
    #msg = "fizz"
    #for i in range(1, 1000):
    i = 0
    while True:
        try:
            #workers = getWorkers(session) 
            workers = getActiveWorkers() # получаем кол-во активных соединений к RabbitMQ
            if len(workers) > 0:
                for worker in workers:
                    channel.basic_publish(exchange="", 
                                routing_key=worker, 
                                body="{} - {}".format(worker, i),
                                properties=pika.BasicProperties(
                                    delivery_mode=2,
                                    expiration='{}'.format(int(common_delay/len(workers)))
                                )
                            )
                    print(" Pace signal #{} has been sent to worker {}".format(i, worker), end="\r", flush=True)
                    i += 1
                    sleep(common_delay/len(workers)/1000)
            else:
                print("Waiting for workers...{0: <40}".format(""), end="\r", flush=True)
                sleep(1)

        except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            connection.close()
            sys.exit()

        except Exception as e:
            print(e)
            #connection.close()
            #sys.exit()
            
            