# messaging server

import pika
import sys
from time import sleep

if __name__ == '__main__':
    cred = pika.credentials.PlainCredentials(username="rabbit", password="rabbit")
    connection = pika.BlockingConnection(
            pika.ConnectionParameters('10.7.0.11', credentials=cred))
    
    channel = connection.channel()
    #channel.exchange_declare(exchange="topic_logs", exchange_type="topic")
    channel.queue_declare(queue="test", durable=False)

    # round-robin message send
    msg = "fizz"
    for i in range(1, 100):
        try:
            
            channel.basic_publish(exchange="", 
                        routing_key=msg, 
                        body="{} - {}".format(msg, i),
                        properties=pika.BasicProperties(
                            delivery_mode=1,
                            expiration='1000'
                        )
                    )
            print(f" [x] Test message [{msg}] #{i} has been sent")

            # iterate through fizz-buzz-bang
            if msg=="fizz":
                msg = "buzz"
            elif msg=="buzz":
                msg = "bang"
            else:
                msg = "fizz"
            
            sleep(1)

        except KeyboardInterrupt:
            print("\nLeaving by CTRL-C")
            connection.close()
            sys.exit()

        except Exception as e:
            connection.close()
            print(e)

    connection.close()