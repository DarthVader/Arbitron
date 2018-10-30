USE [Arbitron]
GO

/****** Object:  View [dbo].[v_history]    Script Date: 12.10.2018 16:31:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER     VIEW mem.v_history AS
-- mem.v_history v.1.0
-- быстрая укороченная весрия истории без UNION и JOIN
SELECT [id]
	  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
      ,[id_ex_pair]
	  --,exchange
	  --,pair
      ,id_type
	  ,[is_buy]
      ,cast(round([price], 10) as real) price
      ,cast(round([amount], 10) as real) amount
	  --,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
      --,iif([is_buy]=1, 'buy', 'sell') side
	  --,'memory' [location]
	  --,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
  FROM [mem].[history] with (snapshot)
  --cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
/*  
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
*/
-- select * from mem.v_history
GO


