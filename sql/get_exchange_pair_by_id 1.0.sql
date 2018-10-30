-- get_exchange_pair_by_id 1.0

CREATE OR ALTER FUNCTION mem.get_exchange_pair_by_id (@id_ex_pair int)   
RETURNS TABLE --varchar(50)
WITH NATIVE_COMPILATION, SCHEMABINDING  
AS   
RETURN
--BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'English')  

    SELECT top 1 exchange, pair from mem.exchanges_pairs where id_ex_pair = @id_ex_pair

--END 

--select * from mem.get_exchange_pair_by_id(19)