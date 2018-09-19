select * from arbitron.history PER PARTITION LIMIT 1;

select count(*) from arbitron.history where exchange='Binance' and pair='BTC/USDT'