USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_get_order_book_at_utc_date]    Script Date: 12.10.2018 11:33:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- tvf_get_order_book_at_date 1.1

CREATE OR ALTER   FUNCTION mem.tvf_get_order_book_at_utc_date
(	
	@utc_date datetime2
)
RETURNS TABLE 
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS
RETURN 
(
	with p as (
		select DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @utc_date) dd
	)
	--set @date = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @date);
	select --top 100 percent
		 o.id_ex_pair
		,exchange
		,pair
		,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
		,bid_ask
		,cast(round([price], 10) as real) price
		,cast(round([amount], 10) as real) amount
		,cast(round(price * amount, 10) as real) volume
	from mem.order_book for system_time as of @utc_date o with (snapshot)
	inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side

)
