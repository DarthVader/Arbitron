-- dbo.v_history 1.0
USE [Arbitron]
GO
CREATE OR ALTER VIEW dbo.v_history AS
SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
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
SELECT DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
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
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON

select top 40 * from v_history where [location]='memory' and id_ex_pair=19 order by dt desc


SET STATISTICS IO OFF
SET STATISTICS TIME OFF