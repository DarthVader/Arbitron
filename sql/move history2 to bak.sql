-- move history2 to bak
USE [Arbitron]
GO

INSERT INTO [mem].[history_bak]
           ([exchange]
           ,[pair]
           ,[id]
           ,[insert_date]
           ,[timestamp]
           ,[ts]
           ,[price]
           ,[amount]
           ,[type]
           ,[side])

SELECT [exchange]
      ,[pair]
      ,[id]
      ,[insert_date]
      ,[timestamp]
      ,[ts]
      ,[price]
      ,[amount]
      ,[type]
      ,[side]
  FROM [mem].[history]
GO

