USE [Arbitron]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--declare @json as nvarchar(max) = '{"exchange": "poloniex", "pair": "DASH/USDT", "histories": [{"timestamp": 1533596244000, "datetime": "2018-08-06T22:57:24.000Z", "symbol": "DASH/USDT", "id": "2376411", "order": null, "type": "limit", "side": "buy", "price": 200.75354986, "amount": 0.01101504, "cost": 2.21130838, "fee": null}]}'
declare @json as nvarchar(max) ='{"exchange": "poloniex", "pair": "DASH/USDT", "histories": [{"timestamp": 1533596244000, "datetime": "2018-08-06T22:57:24.000Z", "symbol": "DASH/USDT", "id": "2376411", "order": null, "type": "limit", "side": "buy", "price": 200.75354986, "amount": 0.01101504, "cost": 2.21130838, "fee": null}, {"timestamp": 1533596433000, "datetime": "2018-08-06T23:00:33.000Z", "symbol": "DASH/USDT", "id": "2376413", "order": null, "type": "limit", "side": "sell", "price": 199.79165029, "amount": 0.00500972, "cost": 1.00090022, "fee": null}, {"timestamp": 1533596433000, "datetime": "2018-08-06T23:00:33.000Z", "symbol": "DASH/USDT", "id": "2376412", "order": null, "type": "limit", "side": "sell", "price": 199.79165029, "amount": 0.00500972, "cost": 1.00090022, "fee": null}, {"timestamp": 1533596443000, "datetime": "2018-08-06T23:00:43.000Z", "symbol": "DASH/USDT", "id": "2376414", "order": null, "type": "limit", "side": "buy", "price": 199.79165029, "amount": 5.605, "cost": 1119.83219987, "fee": null}, {"timestamp": 1533596480000, "datetime": "2018-08-06T23:01:20.000Z", "symbol": "DASH/USDT", "id": "2376415", "order": null, "type": "limit", "side": "sell", "price": 199.52716654, "amount": 8.18382294, "cost": 1632.89500268, "fee": null}, {"timestamp": 1533596708000, "datetime": "2018-08-06T23:05:08.000Z", "symbol": "DASH/USDT", "id": "2376417", "order": null, "type": "limit", "side": "buy", "price": 200.75326998, "amount": 0.361, "cost": 72.47193046, "fee": null}, {"timestamp": 1533596708000, "datetime": "2018-08-06T23:05:08.000Z", "symbol": "DASH/USDT", "id": "2376416", "order": null, "type": "limit", "side": "buy", "price": 200.75325, "amount": 0.005, "cost": 1.00376625, "fee": null}, {"timestamp": 1533596720000, "datetime": "2018-08-06T23:05:20.000Z", "symbol": "DASH/USDT", "id": "2376418", "order": null, "type": "limit", "side": "buy", "price": 200.75326998, "amount": 4.074, "cost": 817.86882189, "fee": null}, {"timestamp": 1533596733000, "datetime": "2018-08-06T23:05:33.000Z", "symbol": "DASH/USDT", "id": "2376420", "order": null, "type": "limit", "side": "buy", "price": 200.75354986, "amount": 0.00951585, "cost": 1.91034066, "fee": null}, {"timestamp": 1533596733000, "datetime": "2018-08-06T23:05:33.000Z", "symbol": "DASH/USDT", "id": "2376419", "order": null, "type": "limit", "side": "buy", "price": 200.75326998, "amount": 0.00021625, "cost": 0.04341289, "fee": null}, {"timestamp": 1533596764000, "datetime": "2018-08-06T23:06:04.000Z", "symbol": "DASH/USDT", "id": "2376422", "order": null, "type": "limit", "side": "buy", "price": 200.76, "amount": 0.0003695, "cost": 0.07418082, "fee": null}, {"timestamp": 1533596764000, "datetime": "2018-08-06T23:06:04.000Z", "symbol": "DASH/USDT", "id": "2376421", "order": null, "type": "limit", "side": "buy", "price": 200.75354986, "amount": 0.01671345, "cost": 3.35528441, "fee": null}, {"timestamp": 1533597122000, "datetime": "2018-08-06T23:12:02.000Z", "symbol": "DASH/USDT", "id": "2376425", "order": null, "type": "limit", "side": "buy", "price": 201.0, "amount": 0.04473971, "cost": 8.99268171, "fee": null}, {"timestamp": 1533597122000, "datetime": "2018-08-06T23:12:02.000Z", "symbol": "DASH/USDT", "id": "2376424", "order": null, "type": "limit", "side": "buy", "price": 200.999, "amount": 0.005, "cost": 1.004995, "fee": null}, {"timestamp": 1533597122000, "datetime": "2018-08-06T23:12:02.000Z", "symbol": "DASH/USDT", "id": "2376423", "order": null, "type": "limit", "side": "buy", "price": 200.999, "amount": 0.00500521, "cost": 1.0060422, "fee": null}, {"timestamp": 1533597585000, "datetime": "2018-08-06T23:19:45.000Z", "symbol": "DASH/USDT", "id": "2376426", "order": null, "type": "limit", "side": "sell", "price": 200.999, "amount": 0.034, "cost": 6.833966, "fee": null}, {"timestamp": 1533597760000, "datetime": "2018-08-06T23:22:40.000Z", "symbol": "DASH/USDT", "id": "2376428", "order": null, "type": "limit", "side": "sell", "price": 200.1397212, "amount": 0.00500101, "cost": 1.00090074, "fee": null}, {"timestamp": 1533597760000, "datetime": "2018-08-06T23:22:40.000Z", "symbol": "DASH/USDT", "id": "2376427", "order": null, "type": "limit", "side": "sell", "price": 200.999, "amount": 0.00082604, "cost": 0.16603321, "fee": null}, {"timestamp": 1533597796000, "datetime": "2018-08-06T23:23:16.000Z", "symbol": "DASH/USDT", "id": "2376429", "order": null, "type": "limit", "side": "buy", "price": 200.03192537, "amount": 0.028, "cost": 5.60089391, "fee": null}, {"timestamp": 1533597962000, "datetime": "2018-08-06T23:26:02.000Z", "symbol": "DASH/USDT", "id": "2376430", "order": null, "type": "limit", "side": "sell", "price": 199.8999599, "amount": 1.7425, "cost": 348.32568012, "fee": null}, {"timestamp": 1533597964000, "datetime": "2018-08-06T23:26:04.000Z", "symbol": "DASH/USDT", "id": "2376431", "order": null, "type": "limit", "side": "sell", "price": 199.8999599, "amount": 0.673, "cost": 134.53267301, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376440", "order": null, "type": "limit", "side": "sell", "price": 198.50002001, "amount": 5.54363716, "cost": 1100.41208718, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376439", "order": null, "type": "limit", "side": "sell", "price": 198.7, "amount": 0.001, "cost": 0.1987, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376438", "order": null, "type": "limit", "side": "sell", "price": 199.0, "amount": 0.1, "cost": 19.9, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376437", "order": null, "type": "limit", "side": "sell", "price": 199.0, "amount": 0.07583417, "cost": 15.09099983, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376436", "order": null, "type": "limit", "side": "sell", "price": 199.00001001, "amount": 1.40928725, "cost": 280.44817685, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376435", "order": null, "type": "limit", "side": "sell", "price": 199.2, "amount": 0.001, "cost": 0.1992, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376434", "order": null, "type": "limit", "side": "sell", "price": 199.23606914, "amount": 0.05019171, "cost": 9.999999, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376433", "order": null, "type": "limit", "side": "sell", "price": 199.4773375, "amount": 0.20052403, "cost": 39.9999996, "fee": null}, {"timestamp": 1533598033000, "datetime": "2018-08-06T23:27:13.000Z", "symbol": "DASH/USDT", "id": "2376432", "order": null, "type": "limit", "side": "sell", "price": 199.8999599, "amount": 0.00052568, "cost": 0.10508341, "fee": null}, {"timestamp": 1533598057000, "datetime": "2018-08-06T23:27:37.000Z", "symbol": "DASH/USDT", "id": "2376441", "order": null, "type": "limit", "side": "sell", "price": 198.52048013, "amount": 0.13092675, "cost": 25.99164127, "fee": null}, {"timestamp": 1533598068000, "datetime": "2018-08-06T23:27:48.000Z", "symbol": "DASH/USDT", "id": "2376442", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 0.50583164, "cost": 100.66049636, "fee": null}, {"timestamp": 1533598082000, "datetime": "2018-08-06T23:28:02.000Z", "symbol": "DASH/USDT", "id": "2376443", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 0.093, "cost": 18.507, "fee": null}, {"timestamp": 1533598085000, "datetime": "2018-08-06T23:28:05.000Z", "symbol": "DASH/USDT", "id": "2376444", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 0.12562814, "cost": 24.99999986, "fee": null}, {"timestamp": 1533598125000, "datetime": "2018-08-06T23:28:45.000Z", "symbol": "DASH/USDT", "id": "2376445", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 1.4289, "cost": 284.35109998, "fee": null}, {"timestamp": 1533598139000, "datetime": "2018-08-06T23:28:59.000Z", "symbol": "DASH/USDT", "id": "2376447", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.123, "cost": 24.47699999, "fee": null}, {"timestamp": 1533598139000, "datetime": "2018-08-06T23:28:59.000Z", "symbol": "DASH/USDT", "id": "2376446", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.017, "cost": 3.38299999, "fee": null}, {"timestamp": 1533598140000, "datetime": "2018-08-06T23:29:00.000Z", "symbol": "DASH/USDT", "id": "2376449", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.26, "cost": 51.73999999, "fee": null}, {"timestamp": 1533598140000, "datetime": "2018-08-06T23:29:00.000Z", "symbol": "DASH/USDT", "id": "2376448", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.13, "cost": 25.86999999, "fee": null}, {"timestamp": 1533598141000, "datetime": "2018-08-06T23:29:01.000Z", "symbol": "DASH/USDT", "id": "2376451", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.086, "cost": 17.11399999, "fee": null}, {"timestamp": 1533598141000, "datetime": "2018-08-06T23:29:01.000Z", "symbol": "DASH/USDT", "id": "2376450", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.086, "cost": 17.11399999, "fee": null}, {"timestamp": 1533598142000, "datetime": "2018-08-06T23:29:02.000Z", "symbol": "DASH/USDT", "id": "2376452", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.13, "cost": 25.86999999, "fee": null}, {"timestamp": 1533598143000, "datetime": "2018-08-06T23:29:03.000Z", "symbol": "DASH/USDT", "id": "2376453", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.099, "cost": 19.70099999, "fee": null}, {"timestamp": 1533598172000, "datetime": "2018-08-06T23:29:32.000Z", "symbol": "DASH/USDT", "id": "2376454", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.077, "cost": 15.32299999, "fee": null}, {"timestamp": 1533598173000, "datetime": "2018-08-06T23:29:33.000Z", "symbol": "DASH/USDT", "id": "2376455", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.05417958, "cost": 10.78173641, "fee": null}, {"timestamp": 1533598203000, "datetime": "2018-08-06T23:30:03.000Z", "symbol": "DASH/USDT", "id": "2376456", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 0.0585472, "cost": 11.65089279, "fee": null}, {"timestamp": 1533598217000, "datetime": "2018-08-06T23:30:17.000Z", "symbol": "DASH/USDT", "id": "2376458", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 1.88421718, "cost": 374.95921882, "fee": null}, {"timestamp": 1533598217000, "datetime": "2018-08-06T23:30:17.000Z", "symbol": "DASH/USDT", "id": "2376457", "order": null, "type": "limit", "side": "buy", "price": 198.99999999, "amount": 1.48368282, "cost": 295.25288116, "fee": null}, {"timestamp": 1533598413000, "datetime": "2018-08-06T23:33:33.000Z", "symbol": "DASH/USDT", "id": "2376459", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 0.02068592, "cost": 4.11649808, "fee": null}, {"timestamp": 1533598468000, "datetime": "2018-08-06T23:34:28.000Z", "symbol": "DASH/USDT", "id": "2376460", "order": null, "type": "limit", "side": "buy", "price": 199.0, "amount": 0.36663712, "cost": 72.96078688, "fee": null}]}'
exec [mem].[save_history_json] @json
go

select * from [Arbitron].[mem].[history] WITH (SNAPSHOT)
--delete from [Arbitron].[mem].[history] 

-- drop procedure if exists [mem].[save_history_json]

CREATE or alter    procedure [mem].[save_history_json](@json as nvarchar(max))
with native_compilation, schemabinding   
as 
begin atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')  

	declare @exchange varchar(50)=NULL, @pair varchar(10)=NULL;
	declare @temp_histories as dbo.histories_type;
	declare @rc int;
	-- declare @json varchar(max) = '{"exchange": "okex", "pair": "ETC/USDT", "histories": [{"timestamp": 1535753378149, "datetime": "2018-08-31T22:09:38.149Z", "symbol": "ETC/USDT", "id": "173594805", "order": null, "type": null, "side": "sell", "price": 12.7075, "amount": 12.0}] }'

	-- begin transaction;

	select @exchange=exchange, @pair=pair
	from  OPENJSON(@json) 
	with (
		exchange varchar(50) '$.exchange',
		pair varchar(10) '$.pair'
	) e
	
	IF @exchange IS NULL
	BEGIN
		--raiserror('Exchange is NULL!', 16, 1)
		return 0
	END
	IF @pair IS NULL
	BEGIN
		--raiserror('Pair is NULL!', 10, 1)
		return 0
	END
	
	-- INSERT to dbo.history using in-memory table type dbo.histories_type
	-- see https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/faster-temp-table-and-table-variable-by-using-memory-optimization?view=sql-server-2017
	-- print 'Insert to temp table [@temp_histories]'


	insert @temp_histories([insert_date],[timestamp],[ts],[exchange],[pair],[price],[amount],[type],[side],[id])
	--select GETUTCDATE() insert_date, [timestamp], ts, @exchange, @pair, price, amount, [type], side, coalesce(id1,id2,id3) [id]
	select GETUTCDATE() insert_date, timestamp, ts, @exchange, @pair, cast(cast(price as real) as decimal(38,10)) price, cast(cast(amount as real) as decimal(38,10)) amount, type, side, coalesce(id1,id2,id3) id
	from  OPENJSON(@json,'$.histories')
	with (
		[timestamp] numeric(38, 0) '$.timestamp',
		-- [timestamp] numeric(38, 0) '$.date',
		[type] varchar(24) '$.type',
		--quantity decimal(38, 12) '$.quantity',
		price varchar(32) '$.price',
		amount varchar(32) '$.amount',
		side varchar(5) '$.side',
		[id1] bigint '$.trade_id',
		[id2] bigint '$.id',
		[id3] bigint '$.tid'
	) j
	--cross apply (SELECT DATEADD(second, [timestamp], CAST('1970-01-01 00:00:00' AS datetime)) ts) d
	cross apply (SELECT DATEADD(second, [timestamp]/1000, CAST('1970-01-01 00:00:00' AS datetime)) ts) d

	
	-- UPSERT to history_cache
	/*
	INSERT INTO mem.[history_cache]
				   ([exchange],[pair],[timestamp],[ts],[delay])
	SELECT t.exchange, t.pair, t.[timestamp], t.ts, null  from @temp_histories t
	WHERE NOT EXISTS (select * from mem.history_cache c where c.exchange=@exchange and c.pair=@pair);
	*/

	-- print 'Insert to target table mem.history'
	INSERT INTO mem.history ([insert_date],[timestamp],[ts],[exchange],[pair],[price],[amount],[type],[side],[id])
	select insert_date, [timestamp], ts, exchange, pair, price, amount, [type], side, [id] from @temp_histories t
	where not exists (select 1 from mem.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)
	--and	  not exists (select 1 from dbo.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)

	--commit;
	
	-- set @rc = @@ROWCOUNT
	-- print 'Inserted ' +  cast(@rc as varchar(10)) + ' rows(s)'
	return @@ROWCOUNT
end
GO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
select * from [Arbitron].[mem].[history] with(SNAPSHOT) order by insert_date desc, ts desc