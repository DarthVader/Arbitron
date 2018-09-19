#!/bin/bash

sudo apt-get update

apt install rabbitmq-server=3.7.4-1 erlang-base=1:20.3-1 erlang-syntax-tools=1:20.3-1 erlang-asn1=1:20.3-1 erlang-crypto=1:20.3-1 erlang-mnesia=1:20.3-1 erlang-runtime-tools=1:2$
sudo service rabbitmq-server restart
rabbitmq-plugins enable rabbitmq_management

rabbitmqctl add_user admin C@wa1728
rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

rabbitmqctl add_user rabbit rabbit
rabbitmqctl set_user_tags rabbit monitoring
sudo rabbitmqctl set_permissions -p / rabbit ".*" ".*" ".*"

cd ~
mkdir Downloads
cd Downloads
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.6 get-pip.py

sudo apt install python3.6-venv
sudo pip3.6 install virtualenv

virtualenv ~/Arbitron/
cd Arbitron

sudo chown mike:mike -R /home/mike/Arbitron/lib

source bin/activate

pip3.6 install numpy
pip3.6 install pika
pip3.6 install cassandra-driver
pip3.6 install ipgetter
pip3.6 install colorama
pip3.6 install pytz
pip3.6 install requests
pip3.6 install pandas
pip3.6 install configparser

sudo apt-get -y install gcc
pip install cytoolz
pip install ccxt
easy_install lru_dict
sudo apt-get -y install python3.6-dev python3-dev python-dev
pip install ccxt --upgrade

chmod +x install_pacemaker_service.sh
sudo ./install_pacemaker_service.sh