-- Detach-Attach
USE [master]
GO
CREATE DATABASE [Arbitron] ON 
( FILENAME = N'C:\DATA\Arbitron.mdf' )
 FOR ATTACH_REBUILD_LOG
GO
