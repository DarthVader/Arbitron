-- tvf_get_HOB 1.0
GO
CREATE OR ALTER FUNCTION [dbo].[tvf_get_HOB] (
	@id_ex_pair int,
	@start_date as datetime,
	@end_date  as datetime 
)
RETURNS TABLE 
AS
RETURN (

select dt, id_ex_pair, exchange, pair, price, amount, bid_ask side, 1 src, validFrom, validTill
from v_order_book
where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date
union all 
select dt, id_ex_pair, exchange, pair, price, amount, bid_ask side, 2 src, ValidFrom, validTill
from v_order_book_history
where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date
union all
select dt, id_ex_pair, exchange, pair, h.price, h.amount, h.side, 3 src, dt, dt
FROM v_history h
where id_ex_pair = @id_ex_pair and dt between @start_date and @end_date

)

/*

select * from tvf_get_HOB(19, '29.09.2018 0:00:00', '30.09.2018 0:00:00') order by dt, src --478303 rows
select * from tvf_get_HOB(19, dateadd(hour, -24, getdate()), getdate()) order by dt, src

*/
select datediff(second, validFrom, validTill) diffs, count(*) qty
from tvf_get_HOB(19, dateadd(hour, -96, getdate()), getdate()) where src=2 and id_ex_pair=19
group by datediff(second, validFrom, validTill)
order by qty desc --datediff(second, validFrom, validTill) desc