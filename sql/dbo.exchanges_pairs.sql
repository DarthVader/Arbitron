-- dbo.exchanges_pairs
select ROW_NUMBER() over(order by exchange, pair) id_ex_pair, * 
into dbo.exchanges_pairs 
from mem.exchanges_pairs
order by exchange, pair