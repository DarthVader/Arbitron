USE [Arbitron]
GO
/****** Object:  StoredProcedure [mem].[save_history_json]    Script Date: 07.09.2018 18:18:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- mem.save_history_json 1.1

ALTER      procedure [mem].[save_history_json](@json as nvarchar(max))
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
	select insert_date, [timestamp], ts, exchange, pair, price, amount, [type], side, [id] 
	from @temp_histories t
	where not exists (select 1 from mem.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)
	--and	  not exists (select 1 from dbo.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)

	--commit;
	
	-- set @rc = @@ROWCOUNT
	-- print 'Inserted ' +  cast(@rc as varchar(10)) + ' rows(s)'
	return @@ROWCOUNT
end
