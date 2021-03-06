USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_get_history_seconds_ago]    Script Date: 25.09.2018 01:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- tvf_get_history_seconds_ago 1.0

CREATE OR ALTER   FUNCTION [dbo].[tvf_get_history_seconds_ago]
(	
	@seconds int
)
RETURNS TABLE 
AS
RETURN 
(
	select id, dt, id_ex_pair, exchange, pair, price, amount, side 
	from v_history 
	where [location]='memory' 
	and dt >= dateadd(SECOND, -@seconds, getdate()) 
	--order by dt, id
)

-- select * from tvf_get_history_seconds_ago(7200) where id_ex_pair=19 order by dt, id