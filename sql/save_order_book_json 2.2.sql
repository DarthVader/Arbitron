USE [Arbitron]
GO

/****** Object:  StoredProcedure [dbo].[save_order_book_json]    Script Date: 21.09.2018 02:18:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER procedure [dbo].[save_order_book_json] (@json as varchar(max))
-- dbo.save_order_book_json 2.2
--with native_compilation, schemabinding   
as 
begin 
--	atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'russian')  
	SET LANGUAGE 'russian';
	begin tran 
		select 
			i.id_ex_pair,
			d.dt, 
			x.is_bid, 
			x.price, 
			x.amount 
		into #tmp
		from  
			OPENJSON(@json,'$')
			with (
				exchange varchar(12) '$.exchange',
				pair varchar(12) '$.pair',
				ts bigint '$.timestamp'
			) ep
			cross apply (
				select 1 is_bid, price, amount 
				from OPENJSON(@json,'$.orderbook.bids')  -- BIDS
						with (
							price  float '$[0]',
							amount float '$[1]'
							 )  t
				union all 
				select 0 is_bid, price, amount 
				from OPENJSON(@json,'$.orderbook.asks')  -- ASKS
						with (
							price  float '$[0]',
							amount float '$[1]'
							 )  t
			 ) x
			cross apply (select id_ex_pair, exchange, pair from mem.exchanges_pairs i with (snapshot) where ep.exchange=i.exchange and ep.pair=i.pair) i
			cross apply (SELECT DATEADD(second, ts, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
		;
		insert into mem.order_book (
					[id_ex_pair]
				   ,[dt]
				   ,[is_bid]
				   ,[price]
				   ,[amount])

		select		[id_ex_pair]
				   ,[dt]
				   ,[is_bid]
				   ,[price]
				   ,[amount]
		from #tmp i
		where not exists (	select 1 from mem.order_book o with (snapshot)
							where 1=1 
							and o.id_ex_pair=i.id_ex_pair
							and o.is_bid=i.is_bid
							and o.price=i.price 
							and o.amount=i.amount)
		;
		
		declare @id_ex_pair bigint
		select top 1 @id_ex_pair = id_ex_pair from #tmp

		delete mem.order_book with (snapshot)
		where mem.order_book.id_ex_pair = @id_ex_pair
		and not exists (	select 1 from #tmp i
							where 1=1 
							and mem.order_book.id_ex_pair=i.id_ex_pair
							and mem.order_book.is_bid=i.is_bid
							and mem.order_book.price=i.price 
							and mem.order_book.amount=i.amount)
	commit tran

end
GO


