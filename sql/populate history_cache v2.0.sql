USE [Arbitron]
GO
/****** Object:  StoredProcedure [dbo].[populate_history_cache]    Script Date: 02.09.2018 16:06:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- populate_history_cache 2.0

-- exec dbo.populate_history_cache

ALTER   procedure [dbo].[populate_history_cache] as
begin
	--truncate table [dbo].[history_cache];
	delete from mem.[history_cache];

	INSERT INTO mem.[history_cache]
			   ([exchange]
			   ,[pair]
			   ,[qty]
			   ,[timestamp]
			   ,[ts]
			   )
	select ex_id exchange, pair
		,count(ts) qty
		,max(timestamp) timestamp
		,max(ts) ts
	from dbo.v_last_ts
	group by ex_id, pair
	
end

