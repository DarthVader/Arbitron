-- modifying token ids using switch schema

SELECT [sid]
      ,[symbol]
      ,[allowed_conversions]
      ,[alt]
      ,[enabled]
      ,[fiat]
      ,[high_volume]
      ,[low_fee]
  FROM [Arbitron].[dbo].[tokens]

  select ROW_NUMBER() over(order by symbol) sid
        ,[symbol]
      ,[allowed_conversions]
      ,[alt]
      ,[enabled]
      ,[fiat]
      ,[high_volume]
      ,[low_fee]
into clone.tokens
  from tokens order by symbol


-- swap tables in schemas
ALTER SCHEMA backups TRANSFER dbo.tokens
go
ALTER SCHEMA dbo TRANSFER clone.tokens
go

-- check
select * from dbo.tokens
--select * from clone.tokens
select * from backups.tokens