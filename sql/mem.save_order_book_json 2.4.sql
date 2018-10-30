USE [Arbitron]
GO
/****** Object:  StoredProcedure [dbo].[save_order_book_json]    Script Date: 04.10.2018 23:46:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
checkpoint
dbcc freeproccache
dbcc dropcleanbuffers
go
*/

drop procedure if exists mem.save_order_book_json 
go
CREATE procedure mem.save_order_book_json (@json as varchar(max))
-- mem.save_order_book_json 2.4
with native_compilation, schemabinding   
as 
begin 
	atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'russian')  
	--SET LANGUAGE 'russian';
	--SET LANGUAGE 'english';
	--SET DATEFORMAT ymd;
	--SET DATEFORMAT ymd;
	--SET LANGUAGE us_english;
	--SET NoCount ON; 
	declare @ob as dbo.order_book_type;
	/*
	begin try 
		begin tran 
		*/
			insert @ob ([id_ex_pair]
					   ,[dt]
					   ,[is_bid]
					   ,[price]
					   ,[amount])
			select 
				i.id_ex_pair,
				d.dt,
				--convert(datetime, [dt], 101) dt,
				x.is_bid, 
				x.price, 
				x.amount 
			--into #tmp
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
			;
			--print 'fetched ' + cast(@@rowcount as varchar(10))

			insert into mem.order_book (
						[id_ex_pair]
					   ,dt
					   ,[is_bid]
					   ,[price]
					   ,[amount])

			select		[id_ex_pair]
						,dt
						--,convert(datetime, [dt], 120) dt
						--,format(dt, 'yyyy-MM-dd HH:mm:ss') dt
					   ,[is_bid]
					   ,[price]
					   ,[amount]
			from @ob i --#tmp i
			where not exists (	select 1 from mem.order_book o --with (snapshot)
								where 1=1 
								and o.id_ex_pair=i.id_ex_pair
								and o.is_bid=i.is_bid
								and o.price=i.price 
								and o.amount=i.amount)
			;
			--print 'inserted ' + cast(@@rowcount as varchar(10))

			--declare @id_ex_pair bigint
			--select top 1 @id_ex_pair = id_ex_pair from @ob --#tmp
			;
			/*
			delete from mem.order_book 
			where id_ex_pair = @id_ex_pair and
			 not exists (	select 1 from @ob i --#tmp i
								where 1=1 
								and mem.order_book.id_ex_pair=i.id_ex_pair
								and mem.order_book.is_bid=i.is_bid
								and mem.order_book.price=i.price 
								and mem.order_book.amount=i.amount)
			)
			*/
			
			;
			declare @id bigint = 0;
			declare @ids nvarchar(max)='';
			declare @i int = 0, @max int = 0;
			declare @id_ex_pair int, @is_bid bit, @price decimal(38,12), @amount decimal(38,12);

			select @max = count(1) from @ob;
			--select @max
			while @i < @max
			begin
				select top 1 
						@id_ex_pair=[id_ex_pair]
					   ,@is_bid=[is_bid]
					   ,@price=[price]
					   ,@amount=[amount]
				from @ob 
				where [id] = @i

				select @id=id from mem.order_book where 1=1 
						and id_ex_pair=@id_ex_pair
						and is_bid=@is_bid
						and price=@price 
						and amount=@amount

				set @ids = @ids + cast(@id as nvarchar(max))
				if @i<@max+1
				begin
					set @ids = @ids + ','
				end
				set @i = @i + 1
			end;
			

			declare @sql nvarchar(max) = '';
			set @sql = 'delete o from mem.order_book o where id not in (' + @ids + ')'

			execute sp_execute @sql;
			--cross apply (select id from string_split(@ids,',') s where o.id=s.id) s;

			/*
			declare @ids varchar(max) = '', 
			select  @ids = ',' + id 
				FROM @ob o
				FOR XML PATH('') 
			select @ids				
			*/	 
			--	STUFF((   ), 1, 1, '' )
			/*
			delete o
			from mem.order_book o --with (snapshot)
			left join @ob i on 1=1 
				and o.id_ex_pair=i.id_ex_pair
				and o.is_bid=i.is_bid
				and o.price=i.price 
				and o.amount=i.amount
			where i.price is null
			*/
			
			--print 'deleted ' + cast(@@rowcount as varchar(10))
	/*
		commit tran
	
	end try
	begin catch
		rollback
	end catch
	*/
end
go
--ALTER AUTHORIZATION ON SCHEMA::mem to arb;
grant exec on mem.save_order_book_json to [Workers]
go
/*
use Arbitron
go
grant exec on dbo.save_order_book_json to [Workers], Analysts, arb
grant exec on mem.save_order_book_json to [Workers], Analysts, arb
GRANT EXECUTE ON OBJECT::mem.save_order_book_json TO [Workers];
grant select on mem.exchanges_pairs to [Workers], Analysts, arb
GRANT exec ON TYPE::mem.order_book_type to [Workers], Analysts, arb
grant select, update, delete on mem.order_book to [Workers], Analysts, arb
GRANT exec ON TYPE::dbo.order_book_type to [Workers], Analysts, arb
GO
*/
/*
USE [Arbitron]
GO

DROP TYPE [mem].[order_book_type]
GO

CREATE TYPE [mem].[order_book_type] AS TABLE(
	[id] [bigint] IDENTITY(1,1) NOT NULL ,
	[id_ex_pair] [int] NOT NULL,
	[dt] [datetime] NOT NULL,
	--[dt] varchar(50) NOT NULL,
	[is_bid] [bit] NOT NULL,
	[price] [decimal](38, 12) NOT NULL,
	[amount] [decimal](38, 12) NOT NULL,
	--[price] varchar(50) NOT NULL,
	--[amount] varchar(50) NOT NULL,
	 PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO

*/
