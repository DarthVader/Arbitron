USE [Arbitron]
GO

/****** Object:  Table [dbo].[history]    Script Date: 06.09.2018 19:10:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[orderbook](
	[id] bigint identity(1,1) NOT NULL,
	[timestamp] [numeric](38, 0) NOT NULL,
	[ts] [datetime] NOT NULL,
	[exchange] [varchar](50) NULL,
	[pair] [varchar](10) NOT NULL,
	[side] [varchar](12) NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,
) ON [PRIMARY]
GO

CREATE CLUSTERED COLUMNSTORE INDEX [CCI_orderbook] ON [dbo].[orderbook] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO


