-- tvf_get_exchange_pair_by_id_ex_pair 1.0

CREATE FUNCTION dbo.tvf_get_exchange_pair_by_id_ex_pair
(	
	@id_ex_pair int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT top 1 exchange, pair from mem.exchanges_pairs with (snapshot) where id_ex_pair = @id_ex_pair
)
GO
