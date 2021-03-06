USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_get_HOB]    Script Date: 12.10.2018 10:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   FUNCTION [dbo].[tvf_get_HOB] (
-- tvf_get_HOB 1.1
	@id_ex_pair int,
	@start_date as datetime,
	@end_date  as datetime 
)
RETURNS TABLE 
AS
RETURN (

	with ob_mem as (
		select 
			 o.id_ex_pair
			,exchange
			,pair
			,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			,bid_ask
			,cast(round([price], 10) as real) price
			,cast(round([amount], 10) as real) amount
			,cast(round(price * amount, 10) as real) volume
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validFrom) as datetime) validFrom
			,o.validTill
		from mem.order_book o
		cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
		cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair)
		--inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	),

	ob_history as (
		select --top 100 percent
			 o.id_ex_pair
			,exchange
			,pair
			,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			,bid_ask
			,cast(round([price], 10) as real) price
			,cast(round([amount], 10) as real) amount
			,cast(round(price * amount, 10) as real) volume
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validFrom) as datetime) validFrom
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validTill) as datetime) validTill
		from dbo.order_book o
		cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
		cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair)
		--inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
	),

	history as (
		SELECT rownum
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			  ,[id_ex_pair]
			  ,exchange
			  ,pair
			  ,cast(round([price], 10) as real) price
			  ,cast(round([amount], 10) as real) amount
			  ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
			  ,iif([is_buy]=1, 'buy', 'sell') side
			  ,[id]
			  ,'memory' [location]
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
		  FROM [mem].[history] with (snapshot)
		  cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
  
		UNION ALL
		SELECT 
			   null
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			  ,[id_ex_pair]
			  ,exchange
			  ,pair
			  ,cast(round([price], 10) as real) price
			  ,cast(round([amount], 10) as real) amount
			  ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
			  ,iif([is_buy]=1, 'buy', 'sell') side
			  ,[id]
			  ,'disk' [location]
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
		  FROM [dbo].[history]
		  cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
	)

	select dt, id_ex_pair, --exchange, pair, 
		price, amount, bid_ask side, 1 src, validFrom, validTill
	from ob_mem --v_order_book
	where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date
	union all 
		select dt, id_ex_pair, --exchange, pair, 
			price, amount, bid_ask side, 2 src, ValidFrom, validTill
	from ob_history --v_order_book_history
	where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date
	union all
	select dt, id_ex_pair, --exchange, pair, 
		h.price, h.amount, h.side, 3 src, dt, dt
	FROM history h--v_history h
	where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date

)

/*

select * from tvf_get_HOB(19, '29.09.2018 0:00:00', '30.09.2018 0:00:00') order by dt, src --478303 rows
select * from tvf_get_HOB(19, dateadd(hour, -24, getdate()), getdate()) order by dt, src

*/