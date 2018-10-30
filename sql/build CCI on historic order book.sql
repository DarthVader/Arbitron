-- build CCI on historic order book
USE Arbitron
GO

ALTER DATABASE Arbitron SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
/*
drop table if exists backups.order_book
select * into backups.order_book from mem.order_book
delete from mem.order_book
go
*/
drop procedure if exists dbo.save_order_book_json 
go
SET IDENTITY_INSERT [mem].[order_book] ON
GO

ALTER TABLE Arbitron.mem.order_book SET (SYSTEM_VERSIONING = OFF); 
go
 
drop table if exists mem.order_book 
go

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
GO
SET IDENTITY_INSERT [mem].[order_book] OFF
GO
--ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = OFF); 
--go
 
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_order_book_history] ON [dbo].[order_book] 
WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE) ON [PRIMARY]

--CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orderbook] ON [dbo].[orderbook] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE) ON [PRIMARY]
ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book))
go



ALTER DATABASE Arbitron SET READ_ONLY;
GO
ALTER DATABASE Arbitron SET MULTI_USER;
GO
USE [master]
GO
ALTER DATABASE [Arbitron] SET  READ_WRITE WITH NO_WAIT
GO


/****** Object:  Index [CCI_order_book]    Script Date: 04.10.2018 23:41:39 ******/
ALTER TABLE Arbitron.[mem].[order_book] DROP INDEX [CCI_order_book]
GO
