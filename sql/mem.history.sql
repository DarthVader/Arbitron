USE [Arbitron]
GO

ALTER TABLE [mem].[history] DROP CONSTRAINT [DF__history__insert___6442E2C9]
GO

/****** Object:  Table [mem].[history]    Script Date: 07.09.2018 02:00:42 ******/
DROP TABLE [mem].[history]
GO

/****** Object:  Table [mem].[history]    Script Date: 07.09.2018 02:00:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

drop table if exists [mem].[history]
go

CREATE TABLE [mem].[history]
(
	[rownum] [int] IDENTITY(1,1) NOT NULL,
	[exchange] [varchar](24) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](24) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[id] [varchar](50) COLLATE Cyrillic_General_CI_AS NULL,
	[insert_date] [datetime2](7) NOT NULL,
	[timestamp] [numeric](38, 0) NULL,
	[ts] [datetime] NOT NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,
	[type] [varchar](8) COLLATE Cyrillic_General_CI_AS NULL,
	[side] [varchar](8) COLLATE Cyrillic_General_CI_AS NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[rownum]
)WITH ( BUCKET_COUNT = 16777216)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO

ALTER TABLE [mem].[history] ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO

ALTER TABLE [mem].[history]
	ADD INDEX ix_mem_history NONCLUSTERED (exchange, pair, id)
GO