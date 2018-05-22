# -*- coding: utf-8 -*-
"""
Created on Mon Apr 23 10:59:04 2018

@author: Dodov
"""
import os
import glob
from os import listdir
from os.path import isfile, join

data_folder = "data"
history_path = "{}/{}/history".format(os.getcwd(), data_folder)
#filename = "{}/{}/history/Bittrex.BCH-BTC.csv".format(os.getcwd(), data_folder)

#files = [f for f in listdir(history_path) if isfile(join(history_path, f))]
files = glob.glob("{}/{}/history/*.csv".format(os.getcwd(), data_folder))
for file in files:
    #try:
    command = 'tr < {0} -d "\\000" > {0}.txt'.format(file)
    _ = os.system(command)
    size1 = os.stat("{}".format(file)).st_size
    size2 = os.stat("{}.txt".format(file)).st_size
    if size1 != size2:
        print("Fixing {}".format(file))
        os.system("rm {}".format(file))
        os.system("mv {0}.txt {0}".format(file))
    else:
        os.system("rm {}.txt".format(file))

    #except Exception:
    #    pass
        #print("You have to install 'tail' utility. For Windows check UnxUtils from \n" +
        #        "https://sourceforge.net/projects/unxutils")
