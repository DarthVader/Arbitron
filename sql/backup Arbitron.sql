-- backup Arbitron
BACKUP DATABASE [Arbitron] TO  DISK = N'C:\BACKUP\Arbitron_2018.09.19.bak' WITH NOFORMAT, NOINIT,  NAME = N'Arbitron-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
