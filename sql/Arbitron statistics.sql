-- Arbitron statistics

select exchange, dateadd(hour, 3, ts) ts, pair, qty, timestamp, from_id
from v_last_ts


 SELECT --[rownum]
       id_ex_pair
      ,max(insert_date) insert_date
      ,max(dt) dt
	  ,max(id) from_id
	  ,count(1) qty
  FROM dbo.[history] --WITH (SNAPSHOT) 
  where id_ex_pair=19
  group by id_ex_pair

  select * from mem.history where id_ex_pair=19 
  and insert_date >= '19.10.2018'
  order by insert_date desc

  --delete from mem.history where id_ex_pair=19 
  --and insert_date >= '22.10.2018'

select count(*) from v_history where id_ex_pair=19 and dt>'2018-07-01' and location='memory' order by dt desc