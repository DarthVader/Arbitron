-- exec mem.sp_orderbook_offload
select max(insert_date) insert_date from mem.orderbook 

select 'orderbook disk' info, count(*) qty from dbo.orderbook union all -- 113561050
select 'orderbook mem' info, count(*) ob_mem_qty from mem.orderbook union all -- 2221639
select 'history disk' info, count(*) qty from dbo.history union all -- 32233838
select 'history mem' info, count(*) ob_mem_qty from mem.history -- 33138600
order by info

select exchange, pair, max(insert_date) max_insert_date
from mem.orderbook WITH (SNAPSHOT)
group by exchange, pair


select 'dbo.orderbook' [table], max(insert_date) insert_date, count(*) qty from dbo.orderbook union all
select 'mem.orderbook' [table], max(insert_date) insert_date, count(*) qty from mem.orderbook 

/*
-- before offload
table			insert_date
dbo.orderbook	2018-09-12 23:13:58.7066667
mem.orderbook	2018-09-16 07:17:26.6733333

exec mem.sp_orderbook_offload '2018-09-14 0:00:00'
-- (6718200 rows affected)

dbo.orderbook	2018-09-13 23:59:53.1133333
mem.orderbook	2018-09-16 07:23:08.6400000

exec mem.sp_orderbook_offload '2018-09-15 0:00:00'
(10122000 rows affected)

dbo.orderbook	2018-09-14 23:59:57.0200000
mem.orderbook	2018-09-16 07:40:35.8933333

exec mem.sp_orderbook_offload '2018-09-16 0:00:00'
(12519200 rows affected)

mem.orderbook	2018-09-16 17:18:41.8433333
dbo.orderbook	2018-09-15 23:59:52.5366667

exec mem.sp_orderbook_offload '2018-09-17 0:00:00'
(11523400 rows affected)
-- 2 min 06 sec

mem.orderbook	2018-09-17 13:21:48.2200000	6372800
dbo.orderbook	2018-09-16 23:59:49.7500000	73116638
*/
