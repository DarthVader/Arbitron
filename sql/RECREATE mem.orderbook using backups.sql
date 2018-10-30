-- insert to mem.orderbook from backups
USE Arbitron
GO

ALTER DATABASE Arbitron
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = OFF); 
go
 
drop table if exists backups.order_book
select * into backups.order_book from mem.order_book
delete from mem.order_book
go

drop procedure if exists dbo.save_order_book_json 
go

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
	INDEX CCI_order_book CLUSTERED COLUMNSTORE,
	PRIMARY KEY NONCLUSTERED HASH ([id])WITH ( BUCKET_COUNT = 65536 ))

WITH (	MEMORY_OPTIMIZED = ON, 
		DURABILITY = SCHEMA_AND_DATA, 
		SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book)
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

SET IDENTITY_INSERT [mem].[order_book] OFF
GO


GO
CREATE OR ALTER procedure [dbo].[save_order_book_json] (@json as varchar(max))
-- dbo.save_order_book_json 2.2
--with native_compilation, schemabinding   
as 
begin 
--	atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'russian')  
	SET LANGUAGE 'russian';
	begin tran 
		select 
			i.id_ex_pair,
			d.dt, 
			x.is_bid, 
			x.price, 
			x.amount 
		into #tmp
		from  
			OPENJSON(@json,'$')
			with (
				exchange varchar(12) '$.exchange',
				pair varchar(12) '$.pair',
				ts bigint '$.timestamp'
			) ep
			cross apply (
				select 1 is_bid, price, amount 
				from OPENJSON(@json,'$.orderbook.bids')  -- BIDS
						with (
							price  float '$[0]',
							amount float '$[1]'
							 )  t
				union all 
				select 0 is_bid, price, amount 
				from OPENJSON(@json,'$.orderbook.asks')  -- ASKS
						with (
							price  float '$[0]',
							amount float '$[1]'
							 )  t
			 ) x
			cross apply (select id_ex_pair, exchange, pair from mem.exchanges_pairs i with (snapshot) where ep.exchange=i.exchange and ep.pair=i.pair) i
			cross apply (SELECT DATEADD(second, ts, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
		;
		insert into mem.order_book (
					[id_ex_pair]
				   ,[dt]
				   ,[is_bid]
				   ,[price]
				   ,[amount])

		select		[id_ex_pair]
				   ,[dt]
				   ,[is_bid]
				   ,[price]
				   ,[amount]
		from #tmp i
		where not exists (	select 1 from mem.order_book o with (snapshot)
							where 1=1 
							and o.id_ex_pair=i.id_ex_pair
							and o.is_bid=i.is_bid
							and o.price=i.price 
							and o.amount=i.amount)
		;
		
		declare @id_ex_pair bigint
		select top 1 @id_ex_pair = id_ex_pair from #tmp

		delete mem.order_book with (snapshot)
		where mem.order_book.id_ex_pair = @id_ex_pair
		and not exists (	select 1 from #tmp i
							where 1=1 
							and mem.order_book.id_ex_pair=i.id_ex_pair
							and mem.order_book.is_bid=i.is_bid
							and mem.order_book.price=i.price 
							and mem.order_book.amount=i.amount)
	commit tran

end
GO


--grant exec on mem.save_order_book_json to [Workers]
grant exec on dbo.save_order_book_json to [Workers]
GO

ALTER DATABASE Arbitron
SET READ_ONLY;
GO
ALTER DATABASE Arbitron
SET MULTI_USER;
GO
USE [master]
GO
ALTER DATABASE [Arbitron] SET  READ_WRITE WITH NO_WAIT
GO

