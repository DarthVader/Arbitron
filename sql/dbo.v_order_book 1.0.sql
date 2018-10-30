-- dbo.v_order_book 1.0
create or alter view dbo.v_order_book as 
select --top 100 percent
	 o.id_ex_pair
	,exchange
	,pair
	,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
	,bid_ask
    ,cast(round([price], 10) as real) price
    ,cast(round([amount], 10) as real) amount
	,cast(round(price * amount, 10) as real) volume
from mem.order_book o
inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
--where exchange = 'binance' and pair='ETH/USDT'
--order by price
go
grant select on dbo.v_order_book to [Analysts]

SET STATISTICS IO ON
SET STATISTICS TIME ON
/*
-- dates and times when order book has changed
select distinct dt from dbo.order_book where 
id_ex_pair = (select id_ex_pair from mem.exchanges_pairs 
where exchange = 'binance' and pair='ETH/USDT')
*/

-- most recent order book
select * from (
select top 10 * from v_order_book where exchange = 'binance' and pair='ETH/USDT' and bid_ask='ask'
order by price) t order by price desc

select top 6 * from v_history where exchange = 'binance' and pair='ETH/USDT' and [location]='memory' order by dt desc

select top 10 * from v_order_book where exchange = 'binance' and pair='ETH/USDT' and bid_ask='bid'
order by price desc


SET STATISTICS IO OFF
SET STATISTICS TIME OFF

