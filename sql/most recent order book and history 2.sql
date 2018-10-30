-- most recent order book
SET STATISTICS IO ON

select * from (
select top 10 * from v_order_book where exchange = 'binance' and pair='ETH/USDT' and bid_ask='ask'
order by price) t order by price desc

select top 6 * from v_history where exchange = 'binance' and pair='ETH/USDT' and [location]='memory' order by dt desc

select top 10 * from v_order_book where exchange = 'binance' and pair='ETH/USDT' and bid_ask='bid'
order by price desc


SET STATISTICS IO OFF
SET STATISTICS TIME OFF

select * from v_order_book for system_time as of '2018-09-21 19:05:00' where id_ex_pair=19