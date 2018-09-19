USE [Arbitron]
GO

/****** Object:  View [dbo].[v_last_ts]    Script Date: 02.09.2018 16:13:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- v_last_ts 2.0

-- select timestamp from v_last_ts where exchange='binance' and pair='ETH/USDT'
-- select * from dbo.history where timestamp=1529978398546

create or alter    view [dbo].[v_last_ts] as

with histories as (
SELECT --[rownum]
       [exchange]
      ,[pair]
      ,[id]
      ,[insert_date]
      ,[timestamp]
      ,[ts]
      ,[price]
      ,[amount]
      ,[type]
      ,[side]
  FROM [mem].[history] WITH (SNAPSHOT)
UNION ALL
SELECT 
       [exchange]
      ,[pair]
      ,[id]
      ,[insert_date]
      ,[timestamp]
      ,[ts]
      ,[price]
      ,[amount]
      ,[type]
      ,[side]
  FROM dbo.[history]
)

select exchange, 
	--(select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) ex_id,
	pair
	,count(ts) qty
	,max(timestamp) timestamp
	,max(ts) ts
from histories
group by exchange, pair
--order by exchange, pair
GO


