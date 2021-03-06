-- backup Arbitron
declare @name varchar(255), @description varchar(255)

select @name=FORMAT(getdate(),'Arbitron_yyyy.MM.dd_HH.mm.ss.bak')
select @description=FORMAT(getdate(),'Arbitron-Full Database Backup yyyy.MM.dd HH:mm:ss')

BACKUP DATABASE [Arbitron] TO  DISK = @name WITH NOFORMAT, NOINIT,  NAME = @description, SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
