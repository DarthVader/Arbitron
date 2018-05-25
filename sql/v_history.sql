-- v_history
use Arbitron 
go

--with lags as (
	SELECT top 1000
		   [load_date]
		  ,lag(load_date) over (partition by exchange, symbol order by timestamp) prev_load
		  ,DATEDIFF(SECOND,lag(load_date) over (partition by exchange, symbol order by timestamp), load_date) lag_sec
		  -- расчёт медианы
		  ,x1.RowAsc
		  ,x2.RowDesc
		  ,timestamp
		  ,dateadd(S, cast(left(timestamp, 10) as int), '01.01.1970 0:00:00:000') transaction_date
		  ,[exchange]
		  ,[symbol]
		  ,SUBSTRING(symbol, 1, CHARINDEX('/', symbol)-1) fsym
		  ,SUBSTRING(symbol, CHARINDEX('/', symbol)+1, LEN(symbol)) tsym
		  ,[price]
		  ,[volume]
		  ,[type]
		  ,[side]
	  FROM [dbo].[history]
	  cross apply (
		select ROW_NUMBER() over (partition by exchange, symbol order by timestamp) RowAsc
	  ) x1
	  cross apply (
		select ROW_NUMBER() over (partition by exchange, symbol order by timestamp desc) RowDesc
	  ) x2
	  --option (querytraceon 8649)
	  --where exchange='Binance' and symbol='ETH/USDT' order by timestamp
	  --where exchange = 'Cryptopia' order by symbol, ts
--)
/*
,ex_median as (
	select exchange, 
		avg(lag_sec) lag_exchange from lags
	where RowAsc in (RowDesc, RowDesc-1, RowDesc+1)
	group by exchange
)

,symbol_median as (
	select exchange, symbol, 
		avg(lag_sec) lag_median from lags
	where RowAsc in (RowDesc, RowDesc-1, RowDesc+1)
	group by exchange , symbol 
)

select * from lags where tsym not in ('USD', 'USDT', 'BTC', 'ETH', 'DOGE', 'LTC', 'EUR', 'RUB') 
order by exchange, symbol, timestamp
*/
/*
select pm.*, pe.lag_exchange
from symbol_median pm
left join ex_median pe on pm.exchange = pe.exchange --and l.symbol = m.symbol
order by exchange, symbol
*/