
USE [Arbitron]
GO


CREATE TABLE [mem].[history_split]
(
	[hotDate] [datetime2](7) NOT NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[hotDate]
)WITH ( BUCKET_COUNT = 1)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO



create or alter procedure [mem].[sp_history_set_splitdate] @newDate datetime  
   with native_compilation, schemabinding, execute as owner  
   as begin atomic with  
   (  
      transaction isolation level = snapshot,  
      language = N'russian'  
   )  

   delete from mem.history_split
   insert mem.history_split values (@newDate)
   end  
GO


-- exec mem.sp_history_set_splitdate '01.09.2018 0:00:00'



create procedure [mem].[sp_history_get_hot] @hotDate datetime2  
   with native_compilation, schemabinding, execute as owner  
   as begin atomic with  
   (  
      transaction isolation level = serializable,  
      language = N'russian'  
)  

	SELECT [rownum]
		  ,[insert_date]
		  ,[dt]
		  ,[id_ex_pair]
		  ,[price]
		  ,[amount]
		  ,[id_type]
		  ,[is_buy]
		  --,[id]
	FROM [mem].[history] --with (READ_COMMITTED)
	where insert_date < @hotDate 

	--delete from mem.history where insert_date < @hotDate  
end  
GO



create or alter procedure [mem].[sp_history_offload] (@newHotDate datetime2)
as  
begin  
   SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
   begin tran  
	  set language N'russian'  
      declare @oldHotDate datetime  
      set @oldHotDate = (select hotDate from mem.history_split with (snapshot))  

       -- get hot date under repeatableread isolation; this is to guarantee it does not change before the insert is executed  
      if (@newHotDate > @oldHotDate) 
	  begin 
			insert into dbo.history (
				   [insert_date]
				  ,[dt]
				  ,[id_ex_pair]
				  ,[price]
				  ,[amount]
				  ,[id_type]
				  ,[is_buy]
				  ,[id]
			)
			select 
				   [insert_date]
				  ,[dt]
				  ,[id_ex_pair]
				  ,[price]
				  ,[amount]
				  ,[id_type]
				  ,[is_buy]
				  ,[id]
			from [mem].[history] with (snapshot)--with (READ_COMMITTED)
			where insert_date < @newHotDate 
			--exec mem.sp_history_get_hot @newHotDate;
			delete from mem.history  WITH (SNAPSHOT) where insert_date < @newHotDate
      end  
	  /*
      else begin  
         insert into hot select * from cold with (serializable) where orderDate >= @newHotDate  
         delete from cold with (serializable) where orderDate >= @newHotDate  
      end  
	  */
      exec mem.sp_history_set_splitdate @newHotDate  
   commit tran  
end  
go


select 'history disk' info, max(insert_date) insert_date, count(*) qty from dbo.history union all
select 'history mem' info, max(insert_date) insert_date, count(*) ob_mem_qty from mem.history order by info

/*
info			insert_date					qty
history disk	2018-07-22 23:45:27.0000000	113561050
history mem		2018-09-18 22:13:49.8900000	2829964

--exec [mem].[sp_history_get_hot] '18.09.2018 0:00:00'
exec mem.sp_history_offload '18.09.2018 0:00:00'
-- (2777390 rows affected)

history disk	2018-09-17 23:40:24.6566667	116338440
history mem		2018-09-18 22:13:49.8900000	52574

-- 27.09.2018
history disk	2018-09-17 23:40:24.6566667	116338440
history mem	2018-09-27 11:10:15.3233333	3271136

declare @dt as varchar(50)
set @dt = format(dateadd(day, -7, cast(cast(SYSUTCDATETIME() as date) as datetime2)), 'dd.MM.yyyy HH:mm:ss')
exec mem.sp_history_offload @dt -- '20.09.2018 0:00:00'

history disk	2018-09-19 23:59:57.3533333	116700085
history mem	2018-09-27 11:21:05.0333333	2911119

*/

