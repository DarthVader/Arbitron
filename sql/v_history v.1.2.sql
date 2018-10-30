USE [Arbitron]
GO

/****** Object:  View [dbo].[v_history]    Script Date: 10.10.2018 19:19:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER     VIEW [dbo].[v_history] AS
-- v_history v.1.2
SELECT rownum
	  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
      ,[id_ex_pair]
	  ,exchange
	  ,pair
      ,cast(round([price], 10) as real) price
      ,cast(round([amount], 10) as real) amount
      ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
      ,iif([is_buy]=1, 'buy', 'sell') side
      ,[id]
	  ,'memory' [location]
	  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
  FROM [mem].[history] with (snapshot)
  cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
  
UNION ALL
SELECT 
	   null
	  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
      ,[id_ex_pair]
	  ,exchange
	  ,pair
      ,cast(round([price], 10) as real) price
      ,cast(round([amount], 10) as real) amount
      ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
      ,iif([is_buy]=1, 'buy', 'sell') side
      ,[id]
	  ,'disk' [location]
	  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
  FROM [dbo].[history]
  cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
  --where dt>DATEADD(MONTH, -1, GETUTCDATE())
GO

-- select DATEDIFF(mi, GETUTCDATE(), GETDATE())
 --
 select * from v_history where exchange='binance' and pair='ETH/USDT' and dt>'23.09.2018 0:00:00'