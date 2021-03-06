USE [Arbitron]
GO

/****** Object:  View [dbo].[v_order_book]    Script Date: 05.10.2018 12:41:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- dbo.v_order_book 1.1
create or alter view [dbo].[v_order_book] as 
select --top 100 percent
	 o.id_ex_pair
	,exchange
	,pair
	--,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) as datetime) dt
	,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dt) dt
	,bid_ask
    ,cast(round([price], 10) as real) price
    ,cast(round([amount], 10) as real) amount
	,cast(round(price * amount, 10) as real) volume
	,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validFrom) as datetime) validFrom
	--,cast(DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), o.validTill) as datetime) validTill
	--,o.validFrom
	,o.validTill
from mem.order_book o
inner join mem.exchanges_pairs ep on o.id_ex_pair=ep.id_ex_pair
cross apply (select iif(o.is_bid=1,'bid','ask') bid_ask) side
--where exchange = 'binance' and pair='ETH/USDT'
--order by price
GO


