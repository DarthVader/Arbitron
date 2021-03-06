-- Enabled exchanges: 'binance','bittrex','cryptopia','hitbtc2','huobipro','kraken','poloniex','yobit'
SELECT dbo.AggregateStrings(id)
  FROM [Arbitron].[dbo].[exchanges]
  where enabled = 1

update exchanges set enabled=0 where id in ('bittrex','cryptopia','hitbtc2','huobipro','kraken','yobit')