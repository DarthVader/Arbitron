-- mem.history last prices comparison

-- exmo/ETH/USDT: Ratelimit=350, elapsed=2.2240 seconds, ts=1537224268
select exchange, pair, max(h.insert_date) insert_date , max(dt) dt
	, max(prices.price) price
from mem.history h
inner join mem.exchanges_pairs p on h.id_ex_pair = p.id_ex_pair
cross apply (
	select top 1 price from mem.history h1 
	where h.id_ex_pair = h1.id_ex_pair
	order by dt desc
) prices
--where exchange='exmo' and pair='ETH/USDT'
group by h.id_ex_pair, exchange, pair
order by insert_date desc