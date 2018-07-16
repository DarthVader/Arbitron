#!/usr/bin/python3.6
# Class that holds settings for the project
from configparser import ConfigParser

class Settings():
    __version__ = "1.0.0"

    def __init__(self):
        self.config = ConfigParser()
        self.config.read('settings.ini')
 
        # database settings
        self.db_user = self.config['database']['user']
        self.db_password = self.config['database']['password']
        self.cassandra_port = int(self.config['database']['port'])
        self.cassandra_nodes = self.config['database']['nodes'].replace(" ","").split(",")
        #cassandra_nodes = ['10.7.0.56']

        # pacemaker settings
        self.rabbit_nodes= self.config['pacemaker']['nodes'].replace(" ","").split(",")
        self.rabbit_port = int(self.config['pacemaker']['port']) #15672 
        self.rabbit_user = self.config['pacemaker']['user']
        self.rabbit_pass = self.config['pacemaker']['password']
        self.queue_name  = self.config['pacemaker']['queue_name']

        # logic
        self.settings_keyspace = self.config['logic']['settings_keyspace']
        self.workers_table = self.config['logic']['workers']
        self.tokens_table = self.config['logic']['tokens']
        self.pairs_table = self.config['logic']['pairs']
        self.exchanges_table = self.config['logic']['exchanges']
        self.log_table = self.config['logic']['log']
        self.ttl_factor = self.config['logic']['ttl_factor']