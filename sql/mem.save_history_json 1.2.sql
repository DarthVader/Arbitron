USE [Arbitron]
GO
/****** Object:  StoredProcedure [mem].[save_history_json]    Script Date: 07.09.2018 18:18:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- mem.save_history_json 1.2

ALTER      procedure [mem].[save_history_json](@json as nvarchar(max))
with native_compilation, schemabinding   
as 
begin atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')  
	
	-- INSERT to dbo.history using in-memory table type dbo.histories_type
	-- see https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/faster-temp-table-and-table-variable-by-using-memory-optimization?view=sql-server-2017

	-- print 'Insert to target table mem.history'
	INSERT INTO mem.history ([insert_date],[timestamp],[ts],[exchange],[pair],[price],[amount],[type],[side],[id])
	select GETUTCDATE() insert_date, [timestamp], ts, e.exchange, e.pair, cast(cast(price as real) as decimal(38,10)) price, cast(cast(amount as real) as decimal(38,10)) amount, [type], side, coalesce(id1,id2,id3) id
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
	cross apply (SELECT DATEADD(second, [timestamp]/1000, CAST('1970-01-01 00:00:00' AS datetime)) ts) d

	where not exists (select 1 from mem.history h where h.exchange=e.exchange and h.pair=e.pair and h.id=coalesce(id1,id2,id3))
	--and	  not exists (select 1 from dbo.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)

	return @@ROWCOUNT
end
