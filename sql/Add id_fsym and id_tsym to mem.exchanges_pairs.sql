-- Add id_fsym and id_tsym to mem.exchanges_pairs
USE [Arbitron]
GO

SELECT [exchange]
      ,[pair]
	  ,(select sid from tokens where symbol=fsym) id_fsym
	  ,(select sid from tokens where symbol=tsym) id_tsym
      ,[enabled]
      ,[fsym]
      ,[fsym_withdraw_fee]
      ,[tsym]
      ,[tsym_withdraw_fee]
      ,[volume24h]
      ,[delay]
      ,[timestamp]
      ,[ts]
into clone.[exchanges_pairs]
  FROM [Arbitron].[mem].[exchanges_pairs] WITH (SNAPSHOT)


drop table if exists [mem].[exchanges_pairs]
go

CREATE TABLE [mem].[exchanges_pairs]
(
	[exchange] [varchar](12) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](10) COLLATE Cyrillic_General_CI_AS NOT NULL,
	id_fsym int not null,
	id_tsym int not null,
	[enabled] [bit] NOT NULL,
	[fsym] [varchar](6) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[fsym_withdraw_fee] [decimal](38, 12) NULL,
	[tsym] [varchar](6) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[tsym_withdraw_fee] [decimal](38, 12) NULL,
	[volume24h] [decimal](38, 6) NULL,
	[delay] [bigint] NULL,
	[timestamp] [numeric](38, 0) NULL,
	[ts] [datetime] NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[exchange],
	[pair]
) WITH ( BUCKET_COUNT = 16384) 
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO


insert [mem].[exchanges_pairs]
	  ([exchange]
      ,[pair]
      ,[id_fsym]
      ,[id_tsym]
      ,[enabled]
      ,[fsym]
      ,[fsym_withdraw_fee]
      ,[tsym]
      ,[tsym_withdraw_fee]
      ,[volume24h]
      ,[delay]
      ,[timestamp]
      ,[ts])

SELECT [exchange]
      ,[pair]
      ,[id_fsym]
      ,[id_tsym]
      ,[enabled]
      ,[fsym]
      ,[fsym_withdraw_fee]
      ,[tsym]
      ,[tsym_withdraw_fee]
      ,[volume24h]
      ,[delay]
      ,[timestamp]
      ,[ts]
  FROM [clone].[exchanges_pairs]
GO

