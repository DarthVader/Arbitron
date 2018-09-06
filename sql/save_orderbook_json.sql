USE [Arbitron]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- select top 100 * from orderbook
-- truncate table orderbook_test
-- select * from [dbo].[orderbook_test] order by insert_date desc, ts desc

/*
declare @json as varchar(max); set @json = ''
exec dbo.save_orderbook_json @json
go
select * from [dbo].[orderbook_test] order by ts desc


-- see: https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/faster-temp-table-and-table-variable-by-using-memory-optimization?view=sql-server-2017
drop type if exists dbo.orderbook_type
go
CREATE TYPE dbo.orderbook_type
AS TABLE  
    (  
		ix int NOT NULL IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		insert_date datetime2 NOT NULL DEFAULT GETUTCDATE(),
		[timestamp] numeric(38, 0) NOT NULL, 
		ts datetime NOT NULL, 
		exchange varchar(20) NOT NULL,
		pair varchar(10) NOT NULL, 
		price decimal(38, 12) NOT NULL, 
		amount decimal(38, 12) NOT NULL, 
		[type] varchar(10) NOT NULL, 
		side varchar(10), 
		[id] varchar(32) NOT NULL
		--INDEX (exchange, pair, [id]) HASH WITH (BUCKET_COUNT=10000)
    )  
    WITH  (MEMORY_OPTIMIZED = ON)
	--WITH INDEX ix HASH (ix) WITH (BUCKET_COUNT=10000)
GO
*/

--CREATE   procedure [dbo].[save_orderbook_json](@json as varchar(max)) as begin

	declare @exchange varchar(50)=NULL, @pair varchar(10)=NULL;
	declare @timestamp numeric(38, 0);
	declare @temp_orderbook as dbo.orderbook_type;

	--begin transaction;

	declare @json varchar(max) = '{"exchange": "poloniex", "pair": "DASH/USDT", "timestamp": 1536253335, "orderbook": {"bids": [[173.00000001, 90.518], [173.0, 8.13461502], [171.82525709, 231.50347075], [171.82525708, 47.13351837], [171.8252569,
33.116], [171.47134267, 331.16001], [171.47134266, 0.08570015], [171.44669499, 1.3210334], [170.63442695, 0.00586576], [170.0, 0.5], [169.94728905, 70.61012898], [168.78453788, 165.58], [166.03917752, 165.58], [165.9282142, 0.00614723], [165.52729956, 0.21158347], [165.0, 30.06060606], [164.072948, 165.58], [163.0, 6.2673838], [162.25314, 0.07488223], [162.0, 0.5617284], [160.50597999, 0.3], [160.0, 0.01425006], [159.75285, 0.07472053], [159.0, 0.12578616], [157.54318012, 0.06347466], [157.19817711, 0.26887287], [157.17147322, 1.08162122], [157.0, 1.27388535], [156.6, 0.06732151], [156.26, 3.66382204], [155.65095, 0.06129339], [155.50597999, 0.2], [155.2221, 1.0], [155.2, 0.11955898], [154.90761616, 0.50418729], [154.77992248, 82.45707582], [154.71420243, 0.14049847], [154.4085352, 2.39418232], [153.6542, 1.0], [153.40537615, 0.0076032], [152.23275576, 2.04035077], [152.0863, 1.0], [152.0, 0.07761742], [151.0, 0.09933775], [150.5184, 1.0], [150.50597999, 0.2], [150.32320632, 1.0], [150.0, 46.61850007], [148.96201, 4.51470175], [148.9505, 1.0]], "asks": [[174.41971528, 26.144], [174.41971529, 8.7858], [174.41979999, 10.656], [174.55758379, 2.7472008], [174.61151485, 30.16867208], [174.66493596, 89.40406725], [174.66493597, 33.116], [175.3, 20.0], [175.40902549, 0.08421019], [175.50614225, 0.05043588], [176.46620401, 228.73138551], [176.46620402, 331.16], [176.46620404, 0.09116731], [177.60197583, 0.19992], [177.7721, 0.00568559], [177.7997, 0.00569663], [177.8565, 0.00578149], [177.8733, 0.00578433], [177.9971, 0.00578689], [178.4920558, 156.44376], [178.72784, 0.07513253], [180.0, 0.68837516], [181.63234159, 1.1229335], [182.207, 0.00552918], [182.3071, 0.00552313], [182.40021, 2.0543863], [183.27246653, 0.00551092], [184.38293368, 0.56573565], [184.97237, 0.05678315], [185.01791859, 0.00545893], [185.2, 1.26134277], [186.7733, 0.00539892], [186.78176486, 0.19464134], [186.83214, 0.07546055], [187.63609668, 0.00538275], [187.77912486, 0.07170683], [188.0136, 0.00535549], [188.1927, 0.00535605], [188.3545, 0.00535702], [188.5065, 0.00536173], [190.0, 10.29646873], [190.5, 0.01364764], [190.99118007, 2.54453398], [191.12700081, 0.00528444], [192.0, 0.016], [192.57693716, 2.29559834], [192.62, 10.0], [192.99118007, 2.0], [193.56468317, 1.05370999], [194.0, 4.99500001]], "timestamp": null, "datetime": null, "nonce": null}}'

	select @exchange=exchange, @pair=pair
	from  OPENJSON(@json) 
	with (
		exchange varchar(50) '$.exchange',
		pair varchar(10) '$.pair' 
	) e
	
	-- select @exchange exchange, @pair pair
	
	/*
	IF @exchange IS NULL
	BEGIN
		raiserror('Exchange is NULL!', 16, 1)
		return
	END
	IF @pair IS NULL
	BEGIN
		raiserror('Pair is NULL!', 10, 1)
		return
	END
	*/
	-- INSERT to dbo.orderbook using in-memory table type dbo.histories_type
	-- see https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/faster-temp-table-and-table-variable-by-using-memory-optimization?view=sql-server-2017
	
	--print 'Insert to temp table [@temp_orderbook]'
	--insert @temp_orderbook([insert_date],[timestamp],[ts],[exchange],[pair],[price],[amount],[type])


	select * --GETUTCDATE() insert_date, [timestamp], ts, @exchange, @pair, price, amount, [type]
	from  OPENJSON(@json,'$.orderbook')
	with (
		bids nvarchar(max) '$.bids' as json, 
		asks nvarchar(max) '$.asks' as json	
	) j
	cross apply openjson(bids) bids
	cross apply openjson(asks) asks

	--cross apply (SELECT DATEADD(second, [timestamp], CAST('1970-01-01 00:00:00' AS datetime)) ts) d

/*	
	-- UPSERT to orderbook_cache
	/*
	INSERT INTO mem.[orderbook_cache]
				   ([exchange],[pair],[timestamp],[ts],[delay])
	SELECT t.exchange, t.pair, t.[timestamp], t.ts, null  from @temp_histories t
	WHERE NOT EXISTS (select * from mem.orderbook_cache c where c.exchange=@exchange and c.pair=@pair);
	*/

	print 'Insert to target table dbo.orderbook'
	INSERT INTO dbo.orderbook ([insert_date],[timestamp],[ts],[exchange],[pair],[price],[amount],[type],[side],[id])
	select insert_date, [timestamp], ts, exchange, pair, price, amount, [type], side, [id] from @temp_histories t
	where not exists (select * from dbo.orderbook h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)

	--commit;

	declare @rc int
	set @rc = @@ROWCOUNT
	print 'Inserted ' +  cast(@rc as varchar(10)) + ' rows(s)'
--	return @rc
--end
--GO


*/