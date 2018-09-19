-- list all schemas
DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = STUFF((SELECT ' UNION ALL
SELECT ' +  + QUOTENAME(name,'''') + ' as DbName, cast(Name as varchar(128)) COLLATE DATABASE_DEFAULT 
AS Schema_Name FROM ' + QUOTENAME(name) + '.sys.schemas'

FROM sys.databases Order BY [name] FOR XML PATH(''),type).value('.','nvarchar(max)'),1,12,'')

SET @SQL = @SQL + ' ORDER BY DbName, Schema_Name'

EXECUTE (@SQL)