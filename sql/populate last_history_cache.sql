-- populate last_history_cache
USE [Arbitron]
GO

INSERT INTO [dbo].[last_history_cache]
           ([exchange]
           ,[pair]
           ,[qty]
           ,[timestamp]
           ,[ts])

	select 
			[exchange]
           ,[pair]
		   ,count(*) qty
           ,max([timestamp]) [timestamp]
           ,max(ts) [ts]
	from [dbo].[history]
	group by exchange, pair