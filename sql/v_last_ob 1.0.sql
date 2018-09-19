-- v_last_ob 1.0

USE [Arbitron]
GO

 --create  or alter    view [dbo].[v_last_ob] as

with orderbook as (

SELECT [id]
      ,[exchange]
      ,[pair]
      ,[ts]
      ,[dt]
      ,[insert_date]
      ,[side]
      ,[price]
      ,[amount]
  FROM [mem].orderbook WITH (SNAPSHOT)
UNION ALL
SELECT [id]
      ,[exchange]
      ,[pair]
      ,[ts]
      ,[dt]
      ,[insert_date]
      ,[side]
      ,[price]
      ,[amount]
 FROM dbo.orderbook
)

select exchange, 
	--(select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) ex_id,
	pair
	,count(id) qty
	,max(ts) timestamp
	,max(insert_date) ts
from dbo.orderbook
group by exchange, pair
--order by exchange, pair
select exchange, 
	--(select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) ex_id,
	pair
	,count(id) qty
	,max(ts) timestamp
	,max(insert_date) ts
from mem.orderbook
group by exchange, pair

