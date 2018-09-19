USE [Arbitron]
GO


select * from dbo.tokens where symbol in(
'BTG', --2
'BCH', --4
'DASH',--5
'EOS', --8
'ETC', --9
'LTC', --12
'XRP', --24
'USD'  --18
)

select * from mem.exchanges_pairs

/*
INSERT INTO [dbo].[exchanges_pairs]
           (--id_ex_pair
		    [exchange]
           ,[pair]
           ,[id_fsym]
           ,[id_tsym]
           ,[enabled]
           ,[fsym]
           ,[tsym]
		   )
     VALUES --('okex', 'BTG/BCH',  2, 4, 1, 'BTG', 'BCH'),
			--('okex', 'DASH/BCH', 5, 4, 1, 'DASH', 'BCH')
			--('okex', 'EOS/BCH', 8, 4, 1, 'EOS', 'BCH'),
			--('okex', 'ETC/BCH', 9, 4, 1, 'ETC', 'BCH'),
            --('okex', 'LTC/BCH', 12,4, 1, 'LTC', 'BCH')
			(--(select max(id_ex_pair)+1 from dbo.exchanges_pairs), 
			 'okex', 'XRP/USD', 24, 18, 1, 'XRP', 'USD')

*/