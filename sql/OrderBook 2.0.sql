-- OrderBook 2.0

USE [Arbitron]
GO

/* -- WARNING!!! BACKUP before run!!! 
-- recreation of orderbook
IF OBJECT_ID('mem.order_book', 'U') IS NOT NULL 
BEGIN
	ALTER TABLE [mem].[order_book] SET (SYSTEM_VERSIONING = OFF)
	GO
	DROP TABLE IF EXISTS [mem].[order_book]
	GO
	DROP TABLE IF EXISTS dbo.[order_book]
END
GO
*/

CREATE TABLE [mem].[order_book]
(
	[id] bigint IDENTITY(1,1) NOT NULL,
	exchange_id INT NOT NULL,
	id_fsym INT NOT NULL,
	id_tsym INT NOT NULL,
	dt datetime NOT NULL,
	is_bid BIT NOT NULL,
	price decimal(38, 12) NOT NULL,
	amount decimal(38, 12) NOT NULL,
	validFrom datetime2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_ValidFrom DEFAULT DATEADD(second, -1, SYSUTCDATETIME()) ,
	validTill datetime2 (0) GENERATED ALWAYS AS ROW END	  HIDDEN CONSTRAINT DF_ValidTill DEFAULT '31.12.9999 23:59:59.99',
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTill),
	PRIMARY KEY NONCLUSTERED HASH ([id]) WITH (BUCKET_COUNT = 16777216)

) WITH ( 
	MEMORY_OPTIMIZED = ON , 
	DURABILITY = SCHEMA_AND_DATA ,
	SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book, DATA_CONSISTENCY_CHECK = ON)
)
GO

ALTER TABLE dbo.order_book REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
GO
--CREATE CLUSTERED COLUMNSTORE INDEX CCI_orderbook ON dbo.order_book WITH (DROP_EXISTING = ON, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE)

CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_order_book] ON [dbo].[order_book]
(
	[exchange_id],
	[id_fsym],
	[id_tsym],
	[dt],
	[is_bid]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE) ON [PRIMARY]
GO


/*
ALTER TABLE [mem].[orderbook] ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO
*/

