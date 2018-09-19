USE [master]
GO
--CREATE SERVER ROLE [Analysts]
GO
CREATE LOGIN [Alex] WITH PASSWORD=N'PiDQgmZJsppNIFOiFH4x7PUoAiolSjYr+9Q2hLvn2PU=', DEFAULT_DATABASE=[Arbitron], DEFAULT_LANGUAGE=[русский], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
ALTER LOGIN [Alex] DISABLE
GO
--ALTER SERVER ROLE [Analysts] ADD MEMBER [Alex]
GO

CREATE LOGIN [arb] WITH PASSWORD=N'7YnL++m83qzISPhT5je0SZkXXSrSM5+R2Zx1RP94/UA=', DEFAULT_DATABASE=[Arbitron], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
ALTER LOGIN [arb] ENABLE
GO




USE [Arbitron]
GO
CREATE ROLE [Analysts]
GO


CREATE USER [Alex] FOR LOGIN [Alex] WITH DEFAULT_SCHEMA=[dbo]
GO



USE [Arbitron]
go
grant select on dbo.history to [Analysts]
go
grant select on dbo.last_history_cache to [Analysts]
go
grant select on v_last_ts to [Analysts]
go
grant select on [dbo].[last_history] TO [Analysts]
go
revoke showplan to [Analysts]



USE [Arbitron]
GO
CREATE ROLE [Workers] AUTHORIZATION [dbo]
GO
ALTER ROLE [Workers] ADD MEMBER [arb]
GO
GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON [dbo].[last_history_cache] TO [Workers]
GO
GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON [dbo].[history] TO [Workers]
GO
GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON [dbo].[history_test] TO [Workers]
GO
GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION ON [dbo].[last_history] TO [Workers]
GO
GRANT SELECT ON [dbo].[v_last_ts] TO [Workers]
GO

grant exec on dbo.[save_orderbook_json] to [Workers]
grant exec on mem.[save_orderbook_json] to [Workers]
grant exec on dbo.[save_histories_json] to [Workers]
grant exec on mem.[save_histories_json] to [Workers]
grant exec on dbo.[save_history_json] to [Workers]
grant exec on mem.[save_history_json] to [Workers]
