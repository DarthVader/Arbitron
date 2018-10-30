USE [Arbitron]
GO

/****** Object:  Index [NCCI_order_book]    Script Date: 04.10.2018 23:12:11 ******/
DROP INDEX [NCCI_order_book] ON [dbo].[order_book]
GO

/****** Object:  Index [NCCI_order_book]    Script Date: 04.10.2018 23:12:11 ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_order_book] ON [dbo].[order_book]
(
	[id_ex_pair],
	[is_bid],
	[dt]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO


