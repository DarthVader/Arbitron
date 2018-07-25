# fizz message client

import pika


def callback(ch, method, properties, body):
    print(f" [x] Received {body}")
    ch.basic_ack(delivery_tag=method.delivery_tag)


if __name__ == '__main__':
    try:
        cred = pika.credentials.PlainCredentials(username="rabbit", password="rabbit")
        connection = pika.BlockingConnection(pika.ConnectionParameters('10.7.0.11', credentials=cred))
        channel = connection.channel()

        channel.queue_declare(queue="fizz")
        
        # channel.exchange_declare(exchange="test", exchange_type="topic")
        # result = channel.queue_declare(exclusive=True)
        # queue_name = result.method.queue
        # channel.queue_bind(exchange='test', queue=queue_name, routing_key="fizz")
        
        channel.basic_consume(callback, queue="fizz", no_ack=False)

        print(" [*] Waiting for messages. To exit press Ctrl+C")

        channel.start_consuming()

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")

    except Exception as e:
        print(e)