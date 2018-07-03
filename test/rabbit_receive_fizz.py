# fizz message client

import pika


def callback(ch, method, properties, body):
    print(" [x] Received '{}'".format(body))


if __name__ == '__main__':
    try:
        cred = pika.credentials.PlainCredentials(username="mike", password="cawa")
        connection = pika.BlockingConnection(pika.ConnectionParameters('10.7.0.11', credentials=cred))
        channel = connection.channel()

        channel.queue_declare(queue="fizz")
        channel.basic_consume(callback, queue="fizz", no_ack=True)

        print(" [*] Waiting for messages. To exit press Ctrl+C")

        channel.start_consuming()

    except KeyboardInterrupt:
        print("\nLeaving by CTRL-C")

    except Exception as e:
        print(e)