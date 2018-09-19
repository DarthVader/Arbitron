USE [Arbitron]
GO

/****** Object:  Table [dbo].[orderbook]    Script Date: 07.09.2018 00:29:30 ******/
DROP TABLE [dbo].[orderbook]
GO

/****** Object:  Table [dbo].[orderbook]    Script Date: 07.09.2018 00:29:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[orderbook](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[exchange] [varchar](12) NOT NULL,
	[pair] [varchar](12) NOT NULL,
	[ts] [numeric](38, 0) NOT NULL,
	[dt] [datetime] NOT NULL,
	[insert_date] [datetime2](7) NOT NULL,
	[side] [varchar](3) NOT NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[orderbook] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = PAGE
)


CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orderbook] ON [dbo].[orderbook] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION = COLUMNSTORE_ARCHIVE) ON [PRIMARY]
GO
/*
ALTER TABLE [dbo].[orderbook] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = COLUMNSTORE_ARCHIVE
)
*/