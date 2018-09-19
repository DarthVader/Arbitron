-- Shrink database ver.1.1
USE Arbitron;
-- generating disable-rebuild script for all columnstore indexes in database
--total execution time: 20 min


--3. ќбрезание журнала транзакций
DBCC SHRINKDATABASE (Arbitron, TRUNCATEONLY); 
--DBCC SHRINKDATABASE(N'MegaLock' );
/*
DbId   FileId      CurrentSize MinimumSize UsedPages   EstimatedPages
------ ----------- ----------- ----------- ----------- --------------
7      1           17199712    3072000     15196856    15196808
7      2           1048576     1048576     1048576     1048576
*/

--4. —жатие базы (высвобождение пустого места без дефрагментации)
--DBCC SHRINKFILE (MegaLock, TRUNCATEONLY);
	declare @DBFileName sysname
	declare @TargetFreeMB int
	declare @ShrinkIncrementMB int

	-- Set Name of Database file to shrink
	set @DBFileName = 'Arbitron'

	-- Set Desired file free space in MB after shrink
	set @TargetFreeMB = 100

	-- Set Increment to shrink file by in MB
	set @ShrinkIncrementMB = 100

	-- Show Size, Space Used, Unused Space, and Name of all database files
	select
		[FileSizeMB]	=
			convert(numeric(10,2),round(a.size/128.,2)),
		[UsedSpaceMB]	=
			convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
		[UnusedSpaceMB]	=
			convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
		[DBFileName]	= a.name
	from
		sysfiles a

	declare @sql varchar(8000)
	declare @SizeMB int
	declare @UsedMB int

	-- Get current file size in MB
	select @SizeMB = size/128. from sysfiles where name = @DBFileName

	-- Get current space used in MB
	select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.

	select [StartFileSize] = @SizeMB, [StartUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

	-- Loop until file at desired size
	while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
		begin

		set @sql =
		'dbcc shrinkfile ( '+@DBFileName+', '+
		convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) '

		print 'Start ' + @sql
		print 'at '+convert(varchar(30),getdate(),121)

		exec ( @sql )

		print 'Done ' + @sql
		print 'at '+convert(varchar(30),getdate(),121)

		-- Get current file size in MB
		select @SizeMB = size/128. from sysfiles where name = @DBFileName
	
		-- Get current space used in MB
		select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.

		select [FileSize] = @SizeMB, [UsedSpace] = @UsedMB, [DBFileName] = @DBFileName

		end

	select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

	-- Show Size, Space Used, Unused Space, and Name of all database files
	select
		[FileSizeMB]	=
			convert(numeric(10,2),round(a.size/128.,2)),
		[UsedSpaceMB]	=
			convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
		[UnusedSpaceMB]	=
			convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
		[DBFileName]	= a.name
	from
		sysfiles a


CHECKPOINT 
DBCC DROPCLEANBUFFERS
DBCC SHRINKFILE (Arbitron_Log, 32)


CHECKPOINT 
DBCC DROPCLEANBUFFERS
DBCC SHRINKFILE (Arbitron_Log, 32)