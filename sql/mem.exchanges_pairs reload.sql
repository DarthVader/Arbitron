-- mem.exchanges_pairs reload

USE [Arbitron]
GO


ALTER TABLE [mem].[exchanges_pairs] DROP INDEX [CCI_exchanges_pairs]
GO

ALTER TABLE [mem].[exchanges_pairs] SET (SYSTEM_VERSIONING = OFF); 
GO

DROP TABLE [mem].[exchanges_pairs]
GO

CREATE TABLE [mem].[exchanges_pairs]
(
	id_ex_pair int PRIMARY KEY NONCLUSTERED IDENTITY(1,1) NOT NULL,
	[exchange] [varchar](12) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[pair] [varchar](10) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[id_fsym] [int] NOT NULL,
	[id_tsym] [int] NOT NULL,
	[enabled] [bit] NOT NULL,
	[fsym] [varchar](6) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[fsym_withdraw_fee] [decimal](38, 12) NULL,
	[tsym] [varchar](6) COLLATE Cyrillic_General_CI_AS NOT NULL,
	[tsym_withdraw_fee] [decimal](38, 12) NULL,
	[volume24h] [decimal](38, 6) NULL,
	[delay] [bigint] NULL,
	[timestamp] [numeric](38, 0) NULL,
	[ts] [datetime] NULL,

	ValidFrom datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTill datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL DEFAULT '31.12.9999 23:59:59',

	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTill),

    INDEX CCI_exchanges_pairs CLUSTERED COLUMNSTORE

)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA
      ,SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.exchanges_pairs_history)
   ) 
GO

--ALTER TABLE [mem].[exchanges_pairs] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.exchanges_pairs_history, DATA_CONSISTENCY_CHECK = ON));


SET IDENTITY_INSERT [mem].[exchanges_pairs] ON

INSERT INTO [mem].[exchanges_pairs]
           ([id_ex_pair]
		   ,[exchange]
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
     
SELECT [id_ex_pair]
      ,[exchange]
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
  FROM [dbo].[exchanges_pairs]
GO
SET IDENTITY_INSERT [mem].[exchanges_pairs] OFF



select * into backups.exchanges_pairs from mem.exchanges_pairs

ALTER TABLE [mem].[exchanges_pairs] DROP INDEX [CCI_exchanges_pairs]
GO

-- add system-versioned columns ValidFrom and ValidTill
GO
ALTER TABLE [mem].[exchanges_pairs]	ADD
	ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT SYSUTCDATETIME(),
	ValidTill datetime2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT '31.12.9999 23:59:59',
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTill)


ALTER TABLE [mem].[exchanges_pairs] ADD INDEX [CCI_exchanges_pairs] CLUSTERED COLUMNSTORE

SET IDENTITY_INSERT mem.[exchanges_pairs] ON

INSERT INTO mem.[exchanges_pairs]
           ([id_ex_pair]
		   ,[exchange]
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
     
SELECT [id_ex_pair]
      ,[exchange]
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
  FROM backups.[exchanges_pairs]
GO
SET IDENTITY_INSERT backups.[exchanges_pairs] OFF