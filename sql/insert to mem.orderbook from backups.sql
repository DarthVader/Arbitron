-- insert to mem.orderbook from backups

 ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = OFF); 
 go
 -- drop table if exists backups.order_book
 -- select * into backups.order_book from mem.order_book
 --delete from mem.order_book
 drop table if exists mem.order_book 
 go
	CREATE TABLE [mem].[order_book]
	(
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_ex_pair] [int] NOT NULL,
		[dt] [datetime] NOT NULL,
		[is_bid] [bit] NOT NULL,
		[price] [decimal](38, 12) NOT NULL,
		[amount] [decimal](38, 12) NOT NULL,
		[validFrom] [datetime2](0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL  DEFAULT (dateadd(second,(-1),sysutcdatetime())) ,
		[validTill] [datetime2](0) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL DEFAULT ('31.12.9999 23:59:59.99'),
		PERIOD FOR SYSTEM_TIME ([validFrom], [validTill]),

	 PRIMARY KEY NONCLUSTERED HASH 
	(
		[id]
	)WITH ( BUCKET_COUNT = 65536)
	)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA 
	,SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book)
	)
	GO

 --truncate table dbo.order_book
 --ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book, DATA_CONSISTENCY_CHECK = ON));
	
	SET IDENTITY_INSERT [mem].[order_book] ON


	INSERT INTO [mem].[order_book]
			   ([id]
			   ,[id_ex_pair]
			   ,[dt]
			   ,[is_bid]
			   ,[price]
			   ,[amount])
	select		[id]
			   ,[id_ex_pair]
			   ,[dt]
			   ,[is_bid]
			   ,[price]
			   ,[amount] 
	from backups.order_book b
    /* 
	select b.id, p.id_ex_pair,
		--p.exchange, p.pair, 
		b.dt, b.is_bid, b.price, b.amount
	from backups.order_book b
	inner join dbo.exchanges e on e.eid=b.exchange_id
	inner join mem.tokens t1 on t1.sid=b.id_fsym
	inner join mem.tokens t2 on t2.sid=b.id_tsym
	inner join mem.exchanges_pairs p on p.exchange=e.id and p.pair=t1.symbol + '/' + t2.symbol
	*/