-- orderbook partitioning 1.0


-- the hotDate is maintained in this memory-optimized table. The current hotDate is always the single date in this table  
drop procedure if exists mem.sp_orderbook_set_splitdate
go  
drop table if exists mem.orderbook_split

create table mem.orderbook_split (  
   hotDate datetime2 not null primary key nonclustered hash with (bucket_count = 1)  
) with (memory_optimized=on)  
go  



--  Stored Procedures  
--  set the hotDate  
--  snapshot: if any other transaction tries to update the hotDate, it will fail immediately due to a  
--  write/write conflict  
drop procedure if exists mem.sp_orderbook_set_splitdate
go  

create procedure mem.sp_orderbook_set_splitdate @newDate datetime  
   with native_compilation, schemabinding, execute as owner  
   as begin atomic with  
   (  
      transaction isolation level = snapshot,  
      language = N'english'  
   )  

   delete from mem.orderbook_split
   insert mem.orderbook_split values (@newDate)
   end  
go

--select distinct insert_date from mem.orderbook order by insert_date desc
--exec mem.sp_orderbook_set_splitdate '08.09.2018 16:58:07.010'
--select * from mem.orderbook_split

/*
-- cold portion of the SalesOrders - partitioned disk-based table  
CREATE PARTITION FUNCTION pf_date (datetime2) AS RANGE RIGHT   
   FOR VALUES();  
GO  

CREATE PARTITION SCHEME [ByDateRange]   
   AS PARTITION pf_date
   ALL TO ([PRIMARY]);  
GO  

*/


drop procedure if exists mem.sp_orderbook_get_hot
go  
create procedure mem.sp_orderbook_get_hot @hotDate datetime2  
   with native_compilation, schemabinding, execute as owner  
   as begin atomic with  
   (  
      transaction isolation level = serializable,  
      language = N'russian'  
)  
	
	SELECT --[id]
		   [exchange]
		  ,[pair]
		  ,[ts]
		  ,[dt]
		  ,[insert_date]
		  ,[side]
		  ,[price]
		  ,[amount]
	FROM [mem].[orderbook] --with (READ_COMMITTED)
	where insert_date < @hotDate 

	--delete from mem.orderbook where insert_date < @hotDate  
end  
go

-- exec mem.sp_orderbook_get_hot '07.09.2018'

drop procedure if exists mem.sp_orderbook_offload
go  
create procedure mem.sp_orderbook_offload (@newHotDate datetime2)
as  
begin  
   SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
   begin tran  
	  set language 'russian'
      declare @oldHotDate datetime  
      set @oldHotDate = (select hotDate from mem.orderbook_split with (snapshot))  

       -- get hot date under repeatableread isolation; this is to guarantee it does not change before the insert is executed  
      if (@newHotDate > @oldHotDate) 
	  begin 
		/*	INSERT INTO [dbo].[orderbook]
					   ([exchange]
					   ,[pair]
					   ,[ts]
					   ,[dt]
					   ,[insert_date]
					   ,[side]
					   ,[price]
					   ,[amount])
					   */
        insert into dbo.orderbook exec mem.sp_orderbook_get_hot @newHotDate;
		

		 delete from mem.orderbook  WITH (SNAPSHOT) where insert_date < @newHotDate
      end  
	  /*
      else begin  
         insert into hot select * from cold with (serializable) where orderDate >= @newHotDate  
         delete from cold with (serializable) where orderDate >= @newHotDate  
      end  
	  */
      exec mem.sp_orderbook_set_splitdate @newHotDate  
   commit tran  
end  
go  

select max(insert_date) insert_date from mem.orderbook 




select 'orderbook disk' info, count(*) qty from dbo.orderbook union all -- 782152 + 1396200  = 2178352 + 2880200 = 5058552 + 1175990 + 1721400 + 581200
select 'orderbook mem' info, count(*) ob_mem_qty from mem.orderbook union all -- 4774200 - 1396200 = 3393000 - 2880200 = 653400 - 1175990
select 'history disk' info, count(*) qty from dbo.history union all
select 'history mem' info, count(*) ob_mem_qty from mem.history 
order by info

-- 12766945