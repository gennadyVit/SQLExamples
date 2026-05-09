DECLARE @DatabaseName NVARCHAR(MAX) = 'YourDatabaseName'; -- Specify the target database
DECLARE @sql NVARCHAR(MAX) = '';

-- Generate the SQL for the target database
SET @sql = '
USE [' + @DatabaseName + '];

DECLARE @fkSql NVARCHAR(MAX) = '''';

DECLARE @IndividualCommand NVARCHAR(MAX);

DECLARE fkCursor CURSOR FOR
SELECT ''ALTER TABLE ['' + OBJECT_SCHEMA_NAME(fkc.parent_object_id, DB_ID(''' + @DatabaseName + ''')) + ''].['' + OBJECT_NAME(fkc.parent_object_id, DB_ID(''' + @DatabaseName + ''')) + '']
DROP CONSTRAINT ['' + fk.name + ''];

ALTER TABLE ['' + OBJECT_SCHEMA_NAME(fkc.parent_object_id, DB_ID(''' + @DatabaseName + ''')) + ''].['' + OBJECT_NAME(fkc.parent_object_id, DB_ID(''' + @DatabaseName + ''')) + '']
ADD CONSTRAINT ['' + fk.name + '']
FOREIGN KEY (['' + COL_NAME(fkc.parent_object_id, fkc.parent_column_id) + ''])
REFERENCES ['' + OBJECT_SCHEMA_NAME(fk.referenced_object_id, DB_ID(''' + @DatabaseName + ''')) + ''].['' + OBJECT_NAME(fk.referenced_object_id, DB_ID(''' + @DatabaseName + ''')) + ''] (['' + COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) + ''])
ON DELETE CASCADE;'' AS SQLCommand
FROM ' + @DatabaseName + '.sys.foreign_keys fk
JOIN ' + @DatabaseName + '.sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.referenced_object_id, DB_ID(''' + @DatabaseName + ''')) = ''certificate'';

OPEN fkCursor;
FETCH NEXT FROM fkCursor INTO @IndividualCommand;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @IndividualCommand; -- Optional: Debugging output
    EXEC sp_executesql @IndividualCommand;
    FETCH NEXT FROM fkCursor INTO @IndividualCommand;
END

CLOSE fkCursor;
DEALLOCATE fkCursor;
';

-- Execute the dynamically constructed SQL
EXEC sp_executesql @sql;