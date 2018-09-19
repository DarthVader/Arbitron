USE [Arbitron]
GO

create schema clone
go
create schema backups
go

drop table if exists clone.history
go

SELECT
	   [insert_date]
      ,[timestamp]
      ,[ts]
      ,(select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) [exchange]
      ,[pair]
      ,[price]
      ,[amount]
      ,[type]
      ,[side]
      ,[id]
into clone.history
  FROM [dbo].[history]
GO
/*
with cte as (
select distinct exchange from history
)
select *, (select top 1 iif(id='hitbtc','hitbtc2',id) id from exchanges where name=exchange) ex_id
from cte
*/
--select * from history2

BEGIN TRY
  BEGIN TRANSACTION
  ALTER SCHEMA backups TRANSFER dbo.history
  ALTER SCHEMA dbo TRANSFER clone.history
  COMMIT TRANSACTION
END TRY
BEGIN CATCH
  SELECT ERROR_MESSAGE() -- add more info here if necessary
  ROLLBACK TRANSACTION
END CATCH

-- compress table
ALTER TABLE [dbo].[history] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
go

-- create Clustere Columnstore Index
--DROP INDEX if exists [CCI_history] ON [backups].[history]
DROP table if exists backups.history
go

CREATE CLUSTERED COLUMNSTORE INDEX [CCI_history] ON [dbo].[history] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
go

