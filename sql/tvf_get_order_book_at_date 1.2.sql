USE [Arbitron]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_get_order_book_at_date]    Script Date: 12.10.2018 12:33:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- tvf_get_order_book_at_date 1.2
ALTER   FUNCTION [dbo].[tvf_get_order_book_at_date] (
	@date as datetime2,
	@id_ex_pair int
)
RETURNS TABLE 
AS
RETURN (
	select * from dbo.tvf_get_order_book_at_utc_date(DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @date), @id_ex_pair) 
)
