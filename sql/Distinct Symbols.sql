
-- Distinct Symbols

select distinct symbol --dbo.AggregateStrings(symbol) 
from (
select distinct substring(pair, 1, CHARINDEX('/', pair)-1) symbol from history -- 
union all
select distinct substring(pair, CHARINDEX('/', pair)+1, len(pair)) from history -- same + USD
) t
order by symbol
-- BCH,XRP,XLM,ETC,ADA,ZEC,LTC,DASH,ICX,DCR,DOGE,XEM,BTG,USDT,ETH,OMG,BTC,XMR,USDT,ETH,EOS,XMR,XVG,BTC,XDG,TRX,SC,NEO,BCH,LTC,USD,DOGE