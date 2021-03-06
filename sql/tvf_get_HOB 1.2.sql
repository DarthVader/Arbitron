USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_get_HOB]    Script Date: 12.10.2018 10:56:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   FUNCTION [dbo].[tvf_get_HOB] (
-- tvf_get_HOB 1.3
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
			--,exchange
			--,pair
			,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			,bid_ask
			,cast(round([price], 10) as real) price
			,cast(round([amount], 10) as real) amount
			,cast(round(price * amount, 10) as real) volume
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validFrom) as datetime) validFrom
			,o.validTill
		from mem.order_book o
		cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
		--cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair)
		--inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
		--cross apply mem.get_exchange_pair_by_id(id_ex_pair)
	),

	ob_history as (
		select --top 100 percent
			 o.id_ex_pair
			--,exchange
			--,pair
			,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			,bid_ask
			,cast(round([price], 10) as real) price
			,cast(round([amount], 10) as real) amount
			,cast(round(price * amount, 10) as real) volume
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validFrom) as datetime) validFrom
			,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validTill) as datetime) validTill
		from dbo.order_book o
		cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
		--cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair)
		--inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
		--cross apply mem.get_exchange_pair_by_id(id_ex_pair)
	),

	history as (
		SELECT rownum
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			  ,[id_ex_pair]
			  --,exchange
			  --,pair
			  ,cast(round([price], 10) as real) price
			  ,cast(round([amount], 10) as real) amount
			  ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
			  ,iif([is_buy]=1, 'buy', 'sell') side
			  ,[id]
			  ,'memory' [location]
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
		  FROM [mem].[history] with (snapshot)
		  --cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
		  --cross apply mem.get_exchange_pair_by_id(id_ex_pair)
  
		UNION ALL
		SELECT 
			   null
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
			  ,[id_ex_pair]
			  --,exchange
			  --,pair
			  ,cast(round([price], 10) as real) price
			  ,cast(round([amount], 10) as real) amount
			  ,case [id_type] when 1 then 'limit' when 2 then 'market' else NULL end [type]
			  ,iif([is_buy]=1, 'buy', 'sell') side
			  ,[id]
			  ,'disk' [location]
			  ,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), [insert_date]) [insert_date]
		  FROM [dbo].[history]
		  --cross apply dbo.tvf_get_exchange_pair_by_id_ex_pair(id_ex_pair) p
		  --cross apply mem.get_exchange_pair_by_id(id_ex_pair)
	),

	unions as (
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

	select p.*, u.* from unions u
	cross apply mem.get_exchange_pair_by_id(id_ex_pair) p
)

/*

select * from tvf_get_HOB(19, '29.09.2018 0:00:00', '30.09.2018 0:00:00') order by dt, src --478303 rows
select * from tvf_get_HOB(19, dateadd(hour, -24, getdate()), getdate()) order by dt, src
select * from tvf_get_HOB(19, dateadd(hour, -48, getdate()), getdate()) order by dt, src

without exchange and pair:

Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 15 мс, истекшее время = 28 мс.

(725789 rows affected)
Таблица "history". Число просмотров 12, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 260745, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "history". Считано сегментов 130, пропущено 5.
Таблица "order_book". Число просмотров 13, логических чтений 7604, физических чтений 0, упреждающих чтений 0, lob логических чтений 336519, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "order_book". Считано сегментов 52, пропущено 14.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

(1 row affected)

 Время работы SQL Server:
   Время ЦП = 2407 мс, затраченное время = 499 мс. <<<<============

===========================================================================================================================================================================
with exchange and pair:

 время ЦП = 15 мс, истекшее время = 104 мс.

(727605 rows affected)
Таблица "order_book". Число просмотров 13, логических чтений 7877, физических чтений 0, упреждающих чтений 0, lob логических чтений 336519, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "order_book". Считано сегментов 52, пропущено 14.
Таблица "history". Число просмотров 12, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 260745, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "history". Считано сегментов 130, пропущено 5.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

(1 row affected)

 Время работы SQL Server:
   Время ЦП = 2733 мс, затраченное время = 1204 мс.
Время синтаксического анализа и компиляции SQL Server: 

===========================================================================================================================================================================
with exchange and pair using mem.get_exchange_pair_by_id:
 время ЦП = 47 мс, истекшее время = 217 мс.

(728995 rows affected)
Таблица "order_book". Число просмотров 13, логических чтений 8119, физических чтений 0, упреждающих чтений 0, lob логических чтений 336519, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "order_book". Считано сегментов 52, пропущено 14.
Таблица "history". Число просмотров 12, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 260737, lob физических чтений 0, lob упреждающих чтений 0.
Таблица "history". Считано сегментов 130, пропущено 5.
Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

(1 row affected)

 Время работы SQL Server:
   Время ЦП = 3157 мс, затраченное время = 1282 мс.

*/