# read in.csv adding one column for UUID

import csv
import uuid

fin = open('data/history/Binance.ETH-USDT.csv', 'r')
fout = open('data/out.csv', 'w', newline='')

reader = csv.reader(fin, delimiter=',', quotechar='"')
writer = csv.writer(fout, delimiter=',', quotechar='"')

firstrow = True
for row in reader:
    row.append(uuid.uuid4())
    writer.writerow(row)