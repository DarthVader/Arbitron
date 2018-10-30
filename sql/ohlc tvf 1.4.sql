-- tvf.ohlc 1.4
-- 5-min intervals
--SET STATISTICS IO ON
--SET STATISTICS TIME ON

CREATE OR ALTER   FUNCTION [dbo].[ohlc]
(	
--declare 
		@lag as int = 86400,
		@interval_minutes as int = 5
)
RETURNS TABLE 
AS
RETURN 
	with open_close as (
		select 
			id_ex_pair,
			min(rownum) id_min, 
			max(rownum) id_max
		from mem.history
		where dt >= dateadd(SECOND, -@lag, getutcdate()) 
		group by id_ex_pair, cast(cast(dt as float) * 24 * 60 / @interval_minutes as int)
			--(datepart(minute, dt) / @interval_minutes)
	),
	low_high as (
		select --cast(cast(dt as float) * 24 * 12 as int) ts, 
			min(rownum) id_min,
			max(rownum) id_max,
			min(dt) dt, 
			h.id_ex_pair, exchange, pair, 
			max(h.price) [high],
			min(h.price) [low],
			count(1) trades,
			sum(amount) volume
		from  v_history h
		where [location]='memory' and dt >= dateadd(SECOND, -@lag, getdate()) 
		group by cast(cast(dt as float) * 24 * 60 / @interval_minutes as int), 
			--(datepart(minute, dt) / @interval_minutes),
			h.id_ex_pair, exchange, pair
	)
	-- select cast(getdate() as float) * 288
	select 
		dt [date], id_ex_pair, exchange, pair, opens.price [open], lh.high, lh.low, closes.price [close], volume, trades
	from low_high lh
	cross apply (
		select top 1 cast(round([price], 10) as real) price from mem.history o
		inner join open_close oc on o.id_ex_pair=lh.id_ex_pair and o.rownum = lh.id_min
		where dt >= dateadd(SECOND, -@lag, getutcdate()) 
	) opens
	cross apply (
		select top 1 cast(round([price], 10) as real) price from mem.history o
		inner join open_close oc on o.id_ex_pair=lh.id_ex_pair and o.rownum = lh.id_max
		where dt >= dateadd(SECOND, -@lag, getutcdate()) 
	) closes
	--order by lh.id_ex_pair, dt desc
	go

-- последние сутки с 5-минутным интервалом
-- select * from ohlc(86400, 5) order by id_ex_pair, dt
