USE [Arbitron]
GO

/****** Object:  UserDefinedTableType [dbo].[orderbook_type]    Script Date: 06.09.2018 19:49:03 ******/
CREATE TYPE [dbo].[orderbook_type] AS TABLE(
	[ix] [int] IDENTITY(1,1) NOT NULL,
	[insert_date] [datetime2](7) NOT NULL DEFAULT (getutcdate()),

	[timestamp] [numeric](38, 0) NOT NULL,
	[ts] [datetime] NOT NULL,
	[exchange] [varchar](20) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](10) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[type] [varchar](3) COLLATE Cyrillic_General_CI_AS NULL,

	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,
	 PRIMARY KEY NONCLUSTERED 
(
	[ix] ASC
)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO


