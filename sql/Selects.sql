-- v_last_ts 1.0
-- select * from v_last_ts order by exchange, pair 
-- select * from v_last_ts order by qty
-- select * into last_ts from v_last_ts order by exchange, pair

create or alter view v_last_ts as
select exchange, pair
	,count(ts) qty
	,max(timestamp) timestamp
	,max(ts) ts
from history
group by exchange, pair
--order by exchange, pair

select exchange, pair, ts from dbo.last_ts
select exchange, pair, ts from dbo.v_last_ts

select top 20 exchange, pair, ts, price, amount from history where exchange='Cryptopia' and pair='DASH/LTC' order by ts
select exchange, pair, ts, price, amount from history where exchange='Cryptopia' and pair='DASH/LTC' order by ts OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
select exchange, pair, ts, price, amount from history where exchange='Cryptopia' and pair='DASH/LTC' order by ts OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
