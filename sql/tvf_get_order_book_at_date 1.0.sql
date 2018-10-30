-- tvf_get_order_book_at_date 1.0

CREATE OR ALTER FUNCTION dbo.tvf_get_order_book_at_utc_date
(	
	@utc_date datetime2
)
RETURNS TABLE 
AS
RETURN 
(
	with p as (
		select DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @utc_date) dd
	)
	--set @date = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @date);
	select --top 100 percent
		 o.id_ex_pair
		,exchange
		,pair
		,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
		,bid_ask
		,cast(round([price], 10) as real) price
		,cast(round([amount], 10) as real) amount
		,cast(round(price * amount, 10) as real) volume
	from mem.order_book for system_time as of @utc_date o with (snapshot)
	inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side

)
GO
grant select on dbo.tvf_get_order_book_at_utc_date to [Analysts]
go

-- tvf_get_order_book_at_date 1.0
CREATE OR ALTER FUNCTION dbo.tvf_get_order_book_at_date (
	@date as datetime2
)
RETURNS TABLE 
AS
RETURN (
	select * from dbo.tvf_get_order_book_at_utc_date(DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @date)) 
)
GO
grant select on dbo.tvf_get_order_book_at_date to [Analysts]
go
-- select * from dbo.tvf_get_order_book_at_date ('04.10.2018 0:00:00') where exchange='binance'
GO

-- tvf_get_order_book_snapshots 1.0 
CREATE OR ALTER FUNCTION dbo.tvf_get_order_book_snapshots (
	@minutes_back as int
)
RETURNS TABLE 
AS
RETURN (
	with dates as (
		select distinct dt from v_order_book with(snapshot) where dt>DATEADD(minute, - @minutes_back, getdate())--'21.09.2018 01:30:00'
	)
	select dt, exchange, pair, bid_ask, price, amount, volume=price*amount from dates d
	cross apply (select exchange, pair, bid_ask, price, amount from tvf_get_order_book_at_date(d.dt)) x
	--order by dt desc
)
GO
grant select on dbo.tvf_get_order_book_snapshots to [Analysts]
go
-- tests:
-- get all snapshots of orderbook for last 15 minutes
select * from tvf_get_order_book_snapshots(5) where exchange='binance' and pair='ETH/USDT' order by dt
