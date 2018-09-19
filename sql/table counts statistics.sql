-- table counts statistics
USE [Arbitron]
GO


select 'dbo.history' [table], min(insert_date) min_insert_date, max(insert_date) max_insert_date, count(*) [count]  from dbo.history union all
select 'mem.history' [table], min(insert_date) min_insert_date, max(insert_date) max_insert_date, count(*) [count]  from mem.history 

select 'dbo.order_book' [table], min(validFrom) min_insert_date, max(validFrom) max_insert_date, count(*) [count] from dbo.order_book union all
select 'mem.order_book' [table], min(validFrom) min_insert_date, max(validFrom) max_insert_date, count(*) [count]  from mem.order_book 


;with 
mem as (
	select o.id_ex_pair, exchange, pair, count(*) [in-memory count]
	from mem.order_book o
	inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	group by o.id_ex_pair, exchange, pair
)
,dsk as (
	select o.id_ex_pair, exchange, pair, count(*) [disk count]
	from dbo.order_book o
	inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	group by o.id_ex_pair, exchange, pair
)
select mem.exchange, mem.pair, mem.[in-memory count], dsk.[disk count]
from mem inner join dsk on mem.id_ex_pair = dsk.id_ex_pair