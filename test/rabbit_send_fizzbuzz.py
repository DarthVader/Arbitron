# messaging server

import pika
import sys
from time import sleep

if __name__ == '__main__':
    cred = pika.credentials.PlainCredentials(username="mike", password="cawa")
    connection = pika.BlockingConnection(
            pika.ConnectionParameters('10.7.0.11', credentials=cred))
    
    channel = connection.channel()
    channel.queue_declare(queue="test", durable=False)

    # round-robin message send
    msg = "fizz"
    for i in range(1, 1000):
        try:
            
            channel.basic_publish(exchange="", 
                        routing_key=msg, 
                        body="{} - {}".format(msg, i),
                        properties=pika.BasicProperties(
                            delivery_mode=2,
                            expiration='333'
                        )
                    )
            print(" [x] Test message {} has been sent".format(i))
            # iterate through fizz-buzz-bang
            if msg=="fizz":
                msg = "buzz"
            elif msg=="buzz":
                msg = "bang"
            else:
                msg = "fizz"
            sleep(0.33)

        except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            connection.close()
            sys.exit()

        except Exception as e:
            connection.close()
            print(e)

    connection.close()