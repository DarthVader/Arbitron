-- ohlc 1.1
-- 5-min intervals
SET STATISTICS IO ON
SET STATISTICS TIME ON

declare @lag as int = 86400;

with 
low_high as (
	select --cast(cast(dt as float) * 24 * 12 as int) ts, 
		min(rownum) id_min,
		max(rownum) id_max,
		min(dt) dt, 
		h.id_ex_pair, exchange, pair, 
		max(h.price) [high],
		min(h.price) [low],
		sum(amount) volume
	from  v_history h
	where [location]='memory' and dt >= dateadd(SECOND, -@lag, getdate()) 
	group by cast(cast(dt as float) * 24 * 12 as int), h.id_ex_pair, exchange, pair
)

select 
	dt, lh.id_ex_pair, exchange, pair, opens.price [open], lh.high, lh.low, closes.price [close]
from low_high lh
cross apply (
	select 
		id_ex_pair,
		min(rownum) id_min, 
		max(rownum) id_max
	from mem.history h
	where dt >= dateadd(SECOND, -@lag, getdate())
	and lh.id_ex_pair = h.id_ex_pair
	and lh.dt = cast(cast(h.dt as float) * 24 * 12 as int)
	group by id_ex_pair, cast(cast(dt as float) * 24 * 12 as int)
) open_close
cross apply (
	select top 1 price from mem.history o
	where dt >= dateadd(SECOND, -@lag, getdate()) 
	and o.id_ex_pair=open_close.id_ex_pair and o.rownum = open_close.id_min
) opens
cross apply (
	select top 1 price from mem.history o
	where dt >= dateadd(SECOND, -@lag, getdate()) 
	and o.id_ex_pair=open_close.id_ex_pair and o.rownum = open_close.id_max
) closes
order by lh.id_ex_pair, dt desc
go

-- ohlc 1.0
-- 5-min intervals
declare @lag as int = 86400;

with bounds as (
	select distinct
		id_ex_pair,
		cast(cast(dt as float) * 24 * 12 as int) ts,
		FIRST_VALUE(price) over (partition by id_ex_pair, cast(cast(dt as float) * 24 * 12 as int) order by dt, id) [open],
		FIRST_VALUE(price) over (partition by id_ex_pair, cast(cast(dt as float) * 24 * 12 as int) order by dt desc, id desc) [close]
	from v_history
	where [location]='memory' and dt >= dateadd(SECOND, -@lag, getdate()) 
)
select --cast(cast(dt as float) * 24 * 12 as int) ts, 
	min(dt) dt, 
	--max(dt) dt_to,
	h.id_ex_pair, exchange, pair, 
	--min(opens.price) [open],
	--FIRST_VALUE(price) over (partition by id_ex_pair order by dt, id) [open],
	min(b.[open]) [open],
	max(h.price) [high],
	min(h.price) [low],
	min(b.[close]) [close],
	--min(closes.price) [close],
	sum(amount) volume
from  v_history h
inner join bounds b on b.id_ex_pair=h.id_ex_pair and b.ts = cast(cast(dt as float) * 24 * 12 as int)
where [location]='memory' and dt >= dateadd(SECOND, -@lag, getdate()) 
group by cast(cast(dt as float) * 24 * 12 as int), h.id_ex_pair, exchange, pair
order by h.id_ex_pair, dt desc