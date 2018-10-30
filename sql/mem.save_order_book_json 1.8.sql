USE [Arbitron]
GO

/****** Object:  StoredProcedure [mem].[save_order_book_json]    Script Date: 21.09.2018 02:16:12 ******/
DROP PROCEDURE [mem].[save_order_book_json]
GO

/****** Object:  StoredProcedure [mem].[save_order_book_json]    Script Date: 21.09.2018 02:16:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [mem].[save_order_book_json] (@json as varchar(max))
with native_compilation, schemabinding   
as 
begin 
	atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'russian')  
	
-- delete from mem.order_book where id_ex_pair=212
-- ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = OFF); 
-- delete from dbo.order_book
-- ALTER TABLE mem.order_book SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.order_book, DATA_CONSISTENCY_CHECK = ON));
-- select * from dbo.order_book
-- select * from mem.order_book where id_ex_pair=212
	
	declare @tmp as dbo.order_book_type;

	INSERT INTO @tmp
			   ([id_ex_pair]
			   ,[dt]
			   ,[is_bid]
			   ,[price]
			   ,[amount])
/*
declare @json varchar(max) = '{"exchange": "poloniex", "pair": "DASH/USDT", "timestamp": 1536253335, "orderbook": {"bids": [[173.00000001, 90.518], [173.0, 8.13461502], [171.82525709, 231.50347075], [171.82525708, 47.13351837], [171.8252569,
34.116], [171.47134267, 331.16001], [171.47134266, 0.08570015], [171.44669499, 1.3210334], [170.63442695, 0.00586576], [170.0, 0.5], [169.94728905, 70.61012898], [168.78453788, 165.58], [166.03917752, 165.58], [165.9282142, 0.00614723], [165.52729956, 0.21158347], [165.0, 30.06060606], [164.072948, 165.58], [163.0, 6.2673838], [162.25314, 0.07488223], [162.0, 0.5617284], [160.50597999, 0.3], [160.0, 0.01425006], [159.75285, 0.07472053], [159.0, 0.12578616], [157.54318012, 0.06347466], [157.19817711, 0.26887287], [157.17147322, 1.08162122], [157.0, 1.27388535], [156.6, 0.06732151], [156.26, 3.66382204], [155.65095, 0.06129339], [155.50597999, 0.2], [155.2221, 1.0], [155.2, 0.11955898], [154.90761616, 0.50418729], [154.77992248, 82.45707582], [154.71420243, 0.14049847], [154.4085352, 2.39418232], [153.6542, 1.0], [153.40537615, 0.0076032], [152.23275576, 2.04035077], [152.0863, 1.0], [152.0, 0.07761742], [151.0, 0.09933775], [150.5184, 1.0], [150.50597999, 0.2], [150.32320632, 1.0], [150.0, 46.61850007], [148.96201, 4.51470175], [148.9505, 1.0]], "asks": [[174.41971528, 26.144], [174.41971529, 8.7858], [174.41979999, 10.656], [174.55758379, 2.7472008], [174.61151485, 30.16867208], [174.66493596, 89.40406725], [174.66493597, 33.116], [175.3, 20.0], [175.40902549, 0.08421019], [175.50614225, 0.05043588], [176.46620401, 228.73138551], [176.46620402, 331.16], [176.46620404, 0.09116731], [177.60197583, 0.19992], [177.7721, 0.00568559], [177.7997, 0.00569663], [177.8565, 0.00578149], [177.8733, 0.00578433], [177.9971, 0.00578689], [178.4920558, 156.44376], [178.72784, 0.07513253], [180.0, 0.68837516], [181.63234159, 1.1229335], [182.207, 0.00552918], [182.3071, 0.00552313], [182.40021, 2.0543863], [183.27246653, 0.00551092], [184.38293368, 0.56573565], [184.97237, 0.05678315], [185.01791859, 0.00545893], [185.2, 1.26134277], [186.7733, 0.00539892], [186.78176486, 0.19464134], [186.83214, 0.07546055], [187.63609668, 0.00538275], [187.77912486, 0.07170683], [188.0136, 0.00535549], [188.1927, 0.00535605], [188.3545, 0.00535702], [188.5065, 0.00536173], [190.0, 10.29646873], [190.5, 0.01364764], [190.99118007, 2.54453398], [191.12700081, 0.00528444], [192.0, 0.016], [192.57693716, 2.29559834], [192.62, 10.0], [192.99118007, 2.0], [193.56468317, 1.05370999], [194.0, 4.99500001]], "timestamp": null, "datetime": null, "nonce": null}}'
*/
	

	select --top 100 percent
		--(select eid from exchanges where id=exchange) exchange_id,
		--pair, 
		--(select sid from tokens where symbol=substring(pair, 1, CHARINDEX('/', pair)-1)) id_fsym,
		--(select sid from tokens where symbol=substring(pair, CHARINDEX('/', pair)+1, len(pair))) id_tsym,
		--fsym.sid id_fsym,
		--tsym.sid id_tsym,
		i.id_ex_pair,
		d.dt, 
		x.is_bid, --'bid' side, 
		x.price, 
		x.amount  --GETUTCDATE() insert_date, [timestamp], ts, @exchange, @pair, price, amount, [type]
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
		cross apply (select id_ex_pair, exchange, pair from mem.exchanges_pairs i where ep.exchange=i.exchange and ep.pair=i.pair) i
		cross apply (SELECT DATEADD(second, ts, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
		--cross apply (select sid from mem.tokens where symbol=substring(pair, 1, CHARINDEX('/', pair)-1) ) fsym
		--cross apply (select sid from mem.tokens where symbol=substring(pair, CHARINDEX('/', pair)+1, len(pair))) tsym
		
	;
	insert into mem.order_book(
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
	from @tmp i
	where not exists (	select 1 from mem.order_book o 
						where 1=1 
						and o.id_ex_pair=i.id_ex_pair
						and o.is_bid=i.is_bid
						and o.price=i.price 
						and o.amount=i.amount)
	;
	/*
	delete mem.order_book
	from mem.order_book 
	left join @tmp i on 1=1
						and mem.order_book.id_ex_pair=i.id_ex_pair
						and mem.order_book.is_bid=i.is_bid
						and mem.order_book.price=i.price 
						and mem.order_book.amount=i.amount
	where mem.order_book.id is null
	
	delete mem.order_book
	where not exists (	select 1 from mem.order_book o 
						where 1=1 
						and mem.order_book.id_ex_pair=i.id_ex_pair
						and mem.order_book.is_bid=i.is_bid
						and mem.order_book.price=i.price 
						and mem.order_book.amount=i.amount)
	*/

	return @@ROWCOUNT
end
GO


