-- last_history_cache (in-memory cache)
USE [Arbitron]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Add memory optimized filegroup and a file 
ALTER DATABASE [Arbitron] ADD FILEGROUP InMemory_FG CONTAINS MEMORY_OPTIMIZED_DATA 
GO 

ALTER DATABASE [Arbitron] ADD FILE ( NAME = N'InMemory_Data', FILENAME = N'C:\DATA\InMemory_Data.ndf') TO FILEGROUP InMemory_FG 
GO 

CREATE TABLE [dbo].[last_history_cache](
	[exchange] [varchar](12) NOT NULL,
	[pair] [varchar](10) NOT NULL,
	[qty] [int] NULL,
	[timestamp] [numeric](38, 0) NULL,
	[ts] [datetime] NULL
	primary key nonclustered hash (exchange, pair) with (bucket_count=100000)
) with (memory_optimized=on, durability=schema_only)
GO


