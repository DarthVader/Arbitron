-- default dt for mem.orderbook
ALTER TABLE [mem].[order_book] ADD  DEFAULT sysutcdatetime() FOR [dt]
GO