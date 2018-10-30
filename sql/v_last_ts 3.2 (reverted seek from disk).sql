USE [Arbitron]
GO

/****** Object:  View [dbo].[v_last_ts]    Script Date: 29.10.2018 19:58:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- v_last_ts 3.2 (reverted seek from disk)

-- select * from [dbo].[v_last_ts] where pair='ETH/USDT' order by ts desc
-- select timestamp, from_id from dbo.v_last_ts where exchange='binance' and pair='ETH/USDT'

ALTER        view [dbo].[v_last_ts] as


with histories as (
 SELECT --[rownum]
       id_ex_pair
      ,max(insert_date) insert_date
      ,max(dt) dt
	  ,max(id) from_id
	  ,count(1) qty
	  ,location='memory'
  FROM [mem].[history] --WITH (SNAPSHOT) 
  group by id_ex_pair
  /*
UNION ALL
 SELECT 
       id_ex_pair
      ,max(insert_date) insert_date
      ,max(dt) dt
	  ,null from_id
	  ,count(1) qty
	  ,location='disk'
  FROM dbo.history
  group by id_ex_pair
  */
)

select 
	 histories.id_ex_pair
	,exchange
	--(select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) ex_id,
	,pair
	,max(qty) qty
	,max(dt) ts
	,DATEDIFF(second,{d '1970-01-01'}, max(dt)) [timestamp]
	,max(from_id) from_id
	--,max(price) price
	,max(0+ep.[enabled]) [enabled]
from histories --WITH (SNAPSHOT)
inner join mem.exchanges_pairs ep on ep.id_ex_pair = histories.id_ex_pair --and ep.enabled=1
/*
cross apply (
	select top 1 price 
	from mem.history h1 
	where histories.id_ex_pair = h1.id_ex_pair
	order by dt desc
) prices
*/
group by histories.id_ex_pair, exchange, pair

--order by exchange, pair
GO


