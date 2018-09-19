USE [Arbitron]
GO

CREATE TYPE [dbo].[order_book_type] AS TABLE(
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[id_ex_pair] [int] NOT NULL,
	[dt] [datetime] NOT NULL,
	[is_bid] [bit] NOT NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,
	 PRIMARY KEY NONCLUSTERED ([id] ASC)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO


