-- check last updates from ETH-USDT
select * from [dbo].[v_last_ts] where pair='ETH/USDT' order by ts desc