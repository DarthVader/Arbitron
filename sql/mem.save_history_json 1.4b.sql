-- mem.save_history_json 1.4b

declare @json as varchar(max) = '{"exchange": "binance", "pair": "ETH/USDT", "histories": [{"info": {"a": 39646396, "p": "204.66000000", "q": "2.70000000", "f": 44090559, "l": 44090559, "T": 1539928799051, "m": false, "M": true}, "timestamp": 1539928799051, "datetime": "2018-10-19T05:59:59.051Z", "symbol": "ETH/USDT", "id": "39646396", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 204.66, "cost": 552.582, "amount": 2.7, "fee": null}, {"info": {"a": 39646397, "p": "204.62000000", "q": "3.99225000", "f": 44090560, "l": 44090560, "T": 1539928799878, "m": false, "M": true}, "timestamp": 1539928799878, "datetime": "2018-10-19T05:59:59.878Z", "symbol": "ETH/USDT", "id": "39646397", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 204.62, "cost": 816.894195, "amount": 3.99225, "fee": null}, {"info": {"a": 39646398, "p": "204.65000000", "q": "0.97000000", "f": 44090561, "l": 44090561, "T": 1539928799879, "m": false, "M": true}, "timestamp": 1539928799879, "datetime": "2018-10-19T05:59:59.879Z", "symbol": "ETH/USDT", "id": "39646398", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 204.65, "cost": 198.5105, "amount": 0.97, "fee": null}, {"info": {"a": 39646399, "p": "204.65000000", "q": "11.48605000", "f": 44090562, "l": 44090563, "T": 1539928799883, "m": false, "M": true}, "timestamp": 1539928799883, "datetime": "2018-10-19T05:59:59.883Z", "symbol": "ETH/USDT", "id": "39646399", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 204.65, "cost": 2350.6201325, "amount": 11.48605, "fee": null}, {"info": {"a": 39646400, "p": "204.65000000", "q": "0.46606000", "f": 44090564, "l": 44090564, "T": 1539928799905, "m": false, "M": true}, "timestamp": 1539928799905, "datetime": "2018-10-19T05:59:59.905Z", "symbol": "ETH/USDT", "id": "39646400", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 204.65, "cost": 95.379179, "amount": 0.46606, "fee": null}]}'


	declare @id_ex_pair as int,
			@exchange as varchar(50),
			@pair as varchar(50),
			@has_history_id as int

	

	select  @id_ex_pair = ep.id_ex_pair,
			@exchange = e.exchange,
			@pair = e.pair
	from  OPENJSON(@json) 
		with (
			exchange varchar(50) '$.exchange',
			pair varchar(10) '$.pair'
		) e
	inner join mem.exchanges_pairs ep on e.exchange=ep.exchange and e.pair=ep.pair

	--select @exchange, @pair, @id_ex_pair


	select @has_history_id = isnull(has_history_id, 0) from exchanges where id=@exchange
	--select @has_history_id

	if @has_history_id = 1
	begin
		-- print 'Insert to target table mem.history'
		--INSERT INTO mem.history (insert_date, dt, id_ex_pair, price, amount, id_type, is_buy, [id])
		select GETUTCDATE() insert_date, dt, 
				--ep.id_ex_pair, 
				@id_ex_pair id_ex_pair,
				conv.price, 
				conv.amount, 
				x.id_type,
				x.is_buy,
				ids.id [id]

		from  OPENJSON(@json) 
			with (
				exchange varchar(50) '$.exchange',
				pair varchar(10) '$.pair'
			) e

		cross apply OPENJSON(@json,'$.histories')
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

		cross apply (
			select 
				cast((case [type]
						when 'limit' then 1
						when 'market' then 2 else NULL end) as smallint) id_type,
				cast((case [side]
						when 'sell' then 0
						when 'buy' then 1 else NULL end) as bit) is_buy
		) x
		cross apply (SELECT DATEADD(second, [timestamp]/1000, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
		cross apply (
			select
				cast(cast(j.price as real) as decimal(38,10)) price, 
				cast(cast(j.amount as real) as decimal(38,10)) amount
		) conv

		cross apply (
			select cast(coalesce(id1, id2, id3) as decimal(38,0)) id
		) ids
	/*
		where not exists 
			(select 1 from mem.history h 
			 where h.id_ex_pair = @id_ex_pair --and h.id=coalesce(id1,id2,id3)
				and h.dt = d.dt 
				--and h.price=conv.price 
				--and h.amount=conv.amount 
				--and h.is_buy=x.is_buy
				and h.id = ids.id -- ищем 
			)
	*/


	end


	select * from mem.history where id_ex_pair=19 and id=39646396
	select max(dt), max(id) from mem.history where id_ex_pair=19 -- 39646400

	--select * 
	--delete from mem.history where insert_date='2018-10-19 05:59:59.9233333'

/*
	else 
	begin -- если у fetch_history не возвращает ID транзакции, то ищем по всем остальным полям - дата, цена, размер, тип
		-- print 'Insert to target table mem.history'
		--INSERT INTO mem.history (insert_date, dt, id_ex_pair, price, amount, id_type, is_buy, [id])
		select GETUTCDATE() insert_date, dt, 
				--ep.id_ex_pair, 
				@id_ex_pair id_ex_pair,
				conv.price, 
				conv.amount, 
				x.id_type,
				x.is_buy,
				ids.id [id]

		from  OPENJSON(@json) 
			with (
				exchange varchar(50) '$.exchange',
				pair varchar(10) '$.pair'
			) e

		cross apply OPENJSON(@json,'$.histories')
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

		cross apply (
			select 
				cast((case [type]
						when 'limit' then 1
						when 'market' then 2 else NULL end) as smallint) id_type,
				cast((case [side]
						when 'sell' then 0
						when 'buy' then 1 else NULL end) as bit) is_buy
		) x
		cross apply (SELECT DATEADD(second, [timestamp]/1000, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
		cross apply (
			select
				cast(cast(j.price as real) as decimal(38,10)) price, 
				cast(cast(j.amount as real) as decimal(38,10)) amount
		) conv

		cross apply (
			select cast(coalesce(id1, id2, id3) as decimal(38,0)) id
		) ids
	
		where not exists 
			(select 1 from mem.history h 
			 where h.id_ex_pair = @id_ex_pair --and h.id=coalesce(id1,id2,id3)
				and h.dt = d.dt 
				and h.price=conv.price 
				and h.amount=conv.amount 
				and h.is_buy=x.is_buy
				--and h.id = ids.id
			)
	end

*/