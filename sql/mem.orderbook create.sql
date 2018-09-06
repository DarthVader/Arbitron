USE [Arbitron]
GO

/****** Object:  Table [mem].[history]    Script Date: 06.09.2018 20:09:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [mem].orderbook
(
	[rownum] bigint IDENTITY(1,1) NOT NULL,
	[exchange] [varchar](12) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](12) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[timestamp] [numeric](38, 0) NULL,
	[ts] [datetime] NOT NULL,
	[side] [varchar](3) COLLATE Cyrillic_General_CI_AS NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[rownum]
)WITH ( BUCKET_COUNT = 4194304)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO

--ALTER TABLE [mem].orderbook ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO


