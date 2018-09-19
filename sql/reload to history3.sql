USE [Arbitron]
GO
/*
create schema clone
go
create schema backups
go
*/
drop table if exists clone.history
go

-- 2 744,953 MB
-- 113561050 rows
select distinct type from dbo.history
select distinct side from dbo.history
/*
select * into dbo.order_types from (
select 1 id_type, 'limit' name
union all 
select 2, 'market' name
) t
go
*/
select distinct exchange from dbo.history h where not exists (select id from exchanges e where e.id=h.exchange) -- empty
select distinct exchange, pair from dbo.history h where not exists (select 1 from dbo.exchanges_pairs p where p.exchange=h.exchange and p.pair=h.pair) -- empty

SELECT --top 100000
	   [insert_date]
      --,[timestamp]
      ,h.[ts] dt
      --,[exchange]
      --,[pair]
	  --,(select eid from exchanges e where e.id=h.exchange) id_exchange
	  --,(select id_ex_pair from dbo.exchanges_pairs ep where h.exchange=ep.exchange and h.pair=ep.pair) id_ex_pair
	  ,ep.id_ex_pair
      ,[price]
      ,[amount]
      ,cast((case [type]
				when 'limit' then 1
				when 'market' then 2 else NULL end) as smallint) id_type
      ,cast((case [side]
				when 'sell' then 0
				when 'buy' then 1 else NULL end) as bit) is_buy
      --,[id]
into clone.history
  FROM [dbo].[history] h
  inner join dbo.exchanges_pairs ep on h.exchange=ep.exchange and h.pair=ep.pair

-- (113561050 rows affected)
-- 7 272,156 MB uncompressed
-- 1 126,711 MB compressed CCI

GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_hist] ON [clone].[history] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE) ON [PRIMARY]

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

-- IN_MEMORY

USE [Arbitron]
GO

-- ALTER TABLE [mem].[history] DROP CONSTRAINT [DF__history__insert___17C286CF]
DROP TABLE IF EXISTS [mem].[history]
GO


CREATE TABLE [mem].[history]
(
	rownum int PRIMARY KEY NONCLUSTERED HASH IDENTITY(1,1) NOT NULL,
	insert_date datetime2 NOT NULL DEFAULT (getutcdate()),
	dt [datetime] NOT NULL,
	id_ex_pair int NOT NULL,
	price decimal(38, 12) NOT NULL,
	amount decimal(38, 12) NOT NULL,
	id_type smallint NULL,
	is_buy bit NULL,
	[id] decimal(38,0) NULL,
	--INDEX CCI_history CLUSTERED COLUMNSTORE
	INDEX PK_history_rownum NONCLUSTERED HASH (rownum) WITH (BUCKET_COUNT = 16777216)
/*
INDEX [ix_mtm_history] NONCLUSTERED 
(
	id_ex_pair ASC,
	[id] ASC
)
, PRIMARY KEY NONCLUSTERED HASH 
(
	[rownum]
)WITH ( BUCKET_COUNT = 16777216)
*/
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/*
ALTER TABLE [mem].[history] ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO
*/

ALTER TABLE [mem].[history] 
	ADD INDEX PK_history_rownum NONCLUSTERED HASH (rownum) WITH (BUCKET_COUNT = 16777216)
GO

ALTER TABLE [mem].[history] 
	ALTER INDEX PK_history_rownum
		REBUILD WITH (BUCKET_COUNT = 16777216)
GO

ALTER TABLE [mem].[history] ADD  PRIMARY KEY NONCLUSTERED ([rownum] ASC)
GO

--ALTER TABLE [mem].[history] DROP INDEX [CCI_history]
GO

ALTER TABLE [mem].[history] ADD INDEX ix_mem_history_id_ex_pair_dt NONCLUSTERED (id_ex_pair, dt)
GO

select distinct exchange from mem.history h where not exists (select id from exchanges e where e.id=h.exchange) -- empty
select distinct exchange, pair from mem.history h where not exists (select 1 from dbo.exchanges_pairs p where p.exchange=h.exchange and p.pair=h.pair) -- empty



INSERT INTO [mem].[history]
           ([insert_date]
           ,[dt]
           ,[id_ex_pair]
           ,[price]
           ,[amount]
           ,[id_type]
           ,[is_buy]
           ,[id])
     
SELECT --top 100
	   [insert_date]
      --,[timestamp]
      ,h.[ts]
      --,[exchange]
      --,[pair]
	  --,(select eid from exchanges e where e.id=h.exchange) id_exchange
	  --,(select id_ex_pair from dbo.exchanges_pairs ep where h.exchange=ep.exchange and h.pair=ep.pair) id_ex_pair
	  ,ep.id_ex_pair
      ,[price]
      ,[amount]
      ,cast((case [type]
				when 'limit' then 1
				when 'market' then 2 else NULL end) as smallint) id_type
      ,cast((case [side]
				when 'sell' then 0
				when 'buy' then 1 else NULL end) as bit) is_buy
      ,[id]
  FROM mem.[history_bak] h
  inner join dbo.exchanges_pairs ep on h.exchange=ep.exchange and h.pair=ep.pair

--CREATE NONCLUSTERED INDEX ix_hisotry_id_ex_pair ON [mem].[history] ([id_ex_pair])
--ALTER TABLE [mem].[history] ADD INDEX ix_hisotry_id_ex_pair (id_ex_pair) -- WITH (BUCKET_COUNT=16777216);  

select distinct id_ex_pair from mem.history
