USE [Arbitron]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [mem].[history_bak]
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

INDEX [ix_mtm_history] NONCLUSTERED 
(
	[exchange] ASC,
	[pair] ASC,
	[id] ASC
),
 PRIMARY KEY NONCLUSTERED HASH 
(
	[rownum]
)WITH ( BUCKET_COUNT = 1048576)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO

ALTER TABLE [mem].[history_bak] ADD  DEFAULT (getutcdate()) FOR [insert_date]
GO


