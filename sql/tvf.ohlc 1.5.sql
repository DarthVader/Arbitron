USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[ohlc]    Script Date: 04.10.2018 12:11:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- tvf.ohlc 1.5
-- 1.5 -- lag_minutes
-- 5-min intervals
--SET STATISTICS IO ON
--SET STATISTICS TIME ON

ALTER     FUNCTION [dbo].[ohlc]
(	
--declare 
		@lag_minutes as int = 1440,
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
		where dt >= dateadd(MINUTE, -@lag_minutes, getutcdate()) 
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
		where [location]='memory' and dt >= dateadd(MINUTE, -@lag_minutes, getdate()) 
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
		where dt >= dateadd(MINUTE, -@lag_minutes, getutcdate()) 
	) opens
	cross apply (
		select top 1 cast(round([price], 10) as real) price from mem.history o
		inner join open_close oc on o.id_ex_pair=lh.id_ex_pair and o.rownum = lh.id_max
		where dt >= dateadd(MINUTE, -@lag_minutes, getutcdate()) 
	) closes
	--order by lh.id_ex_pair, dt desc
