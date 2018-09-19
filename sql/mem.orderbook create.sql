USE [Arbitron]
GO

/****** Object:  Table [mem].[orderbook]    Script Date: 06.09.2018 22:32:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [mem].[orderbook]
(
	id [bigint] IDENTITY(1,1) NOT NULL,
	[exchange] [varchar](25) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](25) COLLATE Cyrillic_General_CI_AS NOT NULL,
	ts [numeric](38, 0) NULL,
	dt [datetime] NOT NULL,
	[insert_date] [datetime2] NOT NULL,
	[side] [varchar](3) COLLATE Cyrillic_General_CI_AS NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	id
)WITH ( BUCKET_COUNT = 4194304)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO


ALTER TABLE [mem].[orderbook] ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO

/*
ALTER TABLE [mem].[orderbook]
 ADD CONSTRAINT constraintUnique_ex_pair_ts_side  
    UNIQUE NONCLUSTERED (exchange, pair, ts, side);
GO
*/