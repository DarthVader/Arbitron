
SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO 

/*

How to Move TempDB to New Drive in SQL Server
Introduction

This article explains the steps you must follow to move TempDB database from one drive to another in SQL Server. However, for the changes to come into effect you must restart SQL Server Service.
Overview of Steps to move TempDB data and log files to new location are:-

1. Identify the location of TempDB Data and Log Files
2. Change the location of TempDB Data and Log files using ALTER DATABASE
3. Stop and Restart SQL Server Service
4. Verify the File Change
5. Delete old tempdb.mdf and templog.ldf files
Identify the location of TempDB Data and Log Files

In the New Query window of SQL Server Management Studio, execute the below mentioned script to identify the location of TempDB data and log file.

Use master
GO

SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
GO

Location of TempDB Data and Log File in SQL Server

Once you have identified the location of TempDB files then the next step will be to create the respective folders on the new drive where you would like to store the TempDB data and log file. However, you need to make sure that the new location where the TempDB files are stored is accessible by SQL Server. i.e., you need to ensure that the Account under which SQL Server Service is running has read and write permissions on the folder where the files are stored.
Change the location of TempDB Data and Log files using ALTER DATABASE

Execute the below ALTER DATABASE command to change the location of TempDB Data and Log file in SQL Server.
*/
USE master;
GO

ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, FILENAME = 'C:\DATA\MSSQL\tempdb.mdf');
GO

ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, FILENAME = 'C:\DATA\MSSQL\templog.ldf');
GO

ALTER DATABASE tempdb
MODIFY FILE (NAME = temp2, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_2.ndf');
GO
--D:\DATA\MSSQL14.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_2.ndf
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp3, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_3.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp4, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_4.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp5, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_5.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp6, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_6.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp7, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_7.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = temp8, FILENAME = 'C:\DATA\MSSQL\tempdb_mssql_8.ndf');
GO


SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'master');
GO 
ALTER DATABASE tempdb
MODIFY FILE (NAME = [master], FILENAME = 'C:\DATA\MSSQL\master.mdf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = mastlog, FILENAME = 'C:\DATA\MSSQL\master.ldf');
GO


-- master
SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'master');
GO 

ALTER DATABASE [master]
MODIFY FILE (NAME = [master], FILENAME = 'C:\DATA\MSSQL\master.mdf');
GO
ALTER DATABASE [master]
MODIFY FILE (NAME = mastlog, FILENAME = 'C:\DATA\MSSQL\master.ldf');
GO


-- model
SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'model');
GO 

ALTER DATABASE model
MODIFY FILE (NAME = modeldev, FILENAME = 'C:\DATA\MSSQL\model.mdf');
GO
ALTER DATABASE model
MODIFY FILE (NAME = modellog, FILENAME = 'C:\DATA\MSSQL\modellog.ldf');
GO


-- MSDB
SELECT
name AS [LogicalName]
,physical_name AS [Location]
,state_desc AS [Status]
FROM sys.master_files
WHERE database_id = DB_ID(N'MSDB');
GO 

ALTER DATABASE MSDB
MODIFY FILE (NAME = MSDBData, FILENAME = 'C:\DATA\MSSQL\MSDBData.mdf');
GO
ALTER DATABASE MSDB
MODIFY FILE (NAME = MSDBLog, FILENAME = 'C:\DATA\MSSQL\MSDBLog.ldf');
GO


USE [master]
GO
CREATE DATABASE [Arbitron] ON 
( FILENAME = N'C:\DATA\Arbitron.mdf' ),
( FILENAME = N'C:\DATA\Arbitron_log.ldf' )
 FOR ATTACH
GO
