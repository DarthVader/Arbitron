-- mem_history_id

USE [Arbitron]
GO

ALTER TABLE [mem].[history]
	ADD INDEX ix_mem_history_id_ex_pair_id NONCLUSTERED (id_ex_pair, id)
GO