USE [Arbitron]
GO

/****** Object:  Index [NCCI_order_book]    Script Date: 21.09.2018 01:03:02 ******/
DROP INDEX [NCCI_order_book] ON [dbo].[order_book]
GO

/****** Object:  Index [NCCI_order_book]    Script Date: 21.09.2018 01:03:02 ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCI_order_book] ON [dbo].[order_book]
(
	[id_ex_pair],
	[is_bid],
	[dt]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0, DATA_COMPRESSION =  COLUMNSTORE_ARCHIVE) ON [PRIMARY]
GO


