--teil 1
CREATE OR ALTER PROCEDURE createTable( @tablename varchar(50), @columnname varchar(20), @columnDataType varchar(25))
AS
BEGIN
DECLARE @query AS VARCHAR(MAX)
SET @query = 'create table' + ' '+ @tablename +'('+@columnname+ ' ' + @columnDataType+ ', PRIMARY KEY(' + @columnname+') )'
print(@query)
EXEC(@query)
END
GO 

EXEC createTable @tablename='NewTable' , @columnname='ID_table', @columnDataType='int'
GO

CREATE OR ALTER PROCEDURE rollback_createTable( @tablename varchar(50))
AS 
BEGIN 
DECLARE @query as VARCHAR(MAX)
SET @query= 'drop table' + ' ' + @tablename 
print(@query)
EXEC(@query)
END 
GO

EXEC rollback_createTable @tablename='NewTable';

CREATE OR ALTER PROCEDURE createNewColumn(@tablename varchar(50), @newcolumn varchar(50), @columnDataType varchar(20))
AS
BEGIN 
DECLARE @query AS VARCHAR(MAX)
SET @query='alter table' + ' ' + @tablename + ' ' + 'add' + ' ' + @newcolumn + ' ' + @columnDataType
print(@query)
EXEC(@query)
END 
GO

EXEC createNewColumn @tablename= 'NewTable' , @newcolumn= 'Column2', @columnDataType = 'int'

CREATE OR ALTER PROCEDURE rollback_createNewColumn( @tablename varchar(50), @columnname varchar(50))
AS
BEGIN 
DECLARE @query AS VARCHAR(MAX)
SET @query= 'alter table ' + @tablename +' '+ 'drop column ' + @columnname
print(@query)
EXEC(@query)
END
GO

EXEC rollback_createNewColumn @tablename='NewTable' , @columnname='Column2'
GO

CREATE OR ALTER PROCEDURE changeDataType( @tablename varchar(50), @columnname varchar(50), @newcolumnDataType varchar(50))
AS
BEGIN
DECLARE @query AS VARCHAR(MAX)
SET @query = 'alter table ' + @tablename + ' ' + 'alter column ' + @columnname + ' ' + @newcolumnDataType
print(@query)
EXEC(@query)
END
GO

EXEC changeDataType @tablename='NewTable' , @columnname='Column2', @newColumnDataType ='varchar(50)'
GO


CREATE OR ALTER PROCEDURE newDefaultConstraint( @tablename varchar(50), @columnname varchar(50), @defaultValue varchar(50))
AS  
BEGIN
DECLARE @query AS VARCHAR(MAX)
DECLARE @checkedDefaultValue varchar(100)
IF ISNUMERIC(@defaultValue) = 1
SET @checkedDefaultValue = @defaultValue
ELSE
SET @checkedDefaultValue = '''' + @defaultValue + ''''
SET @query = 'alter table ' + @tablename + ' add constraint df_' + @columnname + ' DEFAULT ' + @checkedDefaultValue +' FOR '+  @columnname
print(@query)
EXEC(@query)
END 
GO

EXEC newDefaultConstraint @tablename= 'NewTable' ,@columnname='Column2', @defaultValue='valTest'
GO

CREATE OR ALTER PROCEDURE rollback_Constraint( @tablename varchar(50), @constraintName varchar(50))
	AS
		BEGIN
		DECLARE @query as varchar(MAX)
		SET @query = 'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT ' + @ConstraintName
		print('sub')
		PRINT (@query)
		EXEC (@query)
	END
GO


EXEC rollback_Constraint @tablename= 'NewTable' ,@constraintName='df_Column2'
GO
EXEC rollback_Constraint @tablename= 'NewTable' ,@constraintName='fk_NewTable_NewTable2'
GO


CREATE OR ALTER PROCEDURE newForeignKeyConstraint( @tablename1 varchar(50), @tablename2 varchar(50),
 @columnname1 varchar(50), @columnname2 varchar(50))
AS
BEGIN
DECLARE @query AS VARCHAR(MAX)
SET @query = 'alter table ' + @tablename1 + ' add constraint fk_' + @tablename1 + '_'
+@tablename2 + ' FOREIGN KEY ' +'(' +  @columnname1 + ')' + ' REFERENCES '+ @tablename2 +'(' + @columnname2 + ')'
print(@query)
EXEC(@query)
END 
GO

EXEC newForeignKeyConstraint @tablename1='NewTable' , @tablename2='NewTable2' , @columnname1='ID_table', @columnname2='ID_table'
GO

--teil 2

CREATE OR ALTER PROCEDURE new_Table
@nameTable varchar(MAX), @columnname varchar(MAX), @columnDataType varchar(MAX)

AS 
BEGIN
DECLARE @version AS INT
SET @version= (SELECT currentVersion FROM Version)+1
INSERT INTO Versionen(VersionNummer ,Prozedur, Parameter1,Parameter2,Parameter3) VALUES (@version, 'new_table', @nameTable,@columnname,@columnDataType)
print('version wird erstellt')


UPDATE Version
SET currentVersion=currentVersion+1
print('create table' + ' '+ @nameTable +'('+@columnname+ ' ' + @columnDataType+ ', PRIMARY KEY(' + @columnname+') )')
DECLARE @query AS VARCHAR(MAX) = 'create table' + ' '+ @nameTable +'('+@columnname+ ' ' + @columnDataType+ ', PRIMARY KEY(' + @columnname+') )'
EXEC(@query)
END
GO

CREATE OR ALTER PROCEDURE add_Column
@tablename varchar(MAX), @newColumn varchar(MAX), @newColumnType varchar(MAX)
AS
BEGIN
DECLARE @version AS int
SET @version= (SELECT currentVersion FROM Version)+1
INSERT INTO Versionen(VersionNummer, Prozedur, Parameter1, Parameter2, Parameter3) VALUES (@version, 'add_Column', @tablename, @newColumn, @newColumnType)

UPDATE Version
SET currentVersion=currentVersion+1
DECLARE @query AS VARCHAR(MAX) = 'alter table' + ' ' + @tablename + ' ' + 'add' + ' ' + @newColumn + ' ' + @newColumnType
EXEC(@query)
END
GO


GO

CREATE OR ALTER PROCEDURE modifyColumnType
@tablename varchar(MAX), @columnname varchar(MAX), @newColumnType varchar(MAX)
AS
BEGIN
DECLARE @version AS int
SET @version= (SELECT currentVersion FROM Version)+1

DECLARE @size AS int
SET @size = (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@tablename AND COLUMN_NAME=@columnname)
DECLARE @initialType AS VARCHAR(MAX)
SET @initialType= (SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@tablename AND COLUMN_NAME=@columnname)

if @size is not null
begin
SET @initialType= @initialType + '(' + cast(@size as varchar(max)) + ')' 
end
INSERT INTO Versionen(VersionNummer, Prozedur, Parameter1, Parameter2, Parameter3, Parameter4) VALUES (@version, 'modifyColumnType', @tablename, @columnname, @newColumnType, @initialType)

UPDATE Version
SET currentVersion=currentVersion+1
DECLARE @query AS VARCHAR(MAX) = 'alter table ' + @tablename + ' ' + 'alter column ' + @columnname + ' ' + @newColumnType
EXEC(@query)
END
GO


CREATE OR ALTER PROCEDURE setDefaultConstraint
@tablename varchar(MAX), @columnname varchar(50), @defaultValue varchar(50)
AS
BEGIN
DECLARE @version AS int
SET @version= (SELECT currentVersion FROM Version)+1
INSERT INTO Versionen(VersionNummer, Prozedur, Parameter1, Parameter2, Parameter3) VALUES (@version, 'setDefaultConstraint', @tablename, @columnname, @defaultValue)

UPDATE Version
SET currentVersion=currentVersion+1
DECLARE @checkedDefaultValue varchar(100)
IF ISNUMERIC(@defaultValue) = 1
SET @checkedDefaultValue = @defaultValue
ELSE
SET @checkedDefaultValue = '''' + @defaultValue + ''''
DECLARE @query AS VARCHAR(MAX) = 'alter table ' + @tablename + ' add constraint df_' + @columnname + ' DEFAULT ' + @checkedDefaultValue +' FOR '+  @columnname
EXEC(@query)
END
GO


CREATE OR ALTER PROCEDURE setFKConstraint
@tablename1 varchar(50), @tablename2 varchar(50),
 @columnname1 varchar(50), @columnname2 varchar(50)
AS
BEGIN
DECLARE @version AS int
SET @version= (SELECT currentVersion FROM Version)+1
INSERT INTO Versionen(VersionNummer, Prozedur, Parameter1, Parameter2, Parameter3, Parameter4) VALUES (@version, 'setFKConstraint', @tablename1, @tablename2 ,
 @columnname1 , @columnname2 )

UPDATE Version
SET currentVersion=currentVersion+1
DECLARE @query AS VARCHAR(MAX) = 'ALTER TABLE ' + @tablename1 + ' ADD CONSTRAINT fk_' + @tablename1 + '_' + @tablename2 +'_'  + @columnname1 +
' FOREIGN KEY (' +  @columnname1 + ') REFERENCES ' + @tablename2 + ' (' + @columnname2 + ');';

print(@query)
EXEC(@query)
END
GO


CREATE OR ALTER PROCEDURE GoToVersion(@changedVersion int)
AS
BEGIN
DECLARE @currentVersion as INT

	DECLARE @procedureName as varchar(max),
			@tableName as varchar(max),
			@columnName as varchar(max),
			@Parameter1 as varchar(max),
			@Parameter2 as varchar(max),
			@Parameter3 as varchar(max),
			@Parameter4 as varchar(max)
			

SET @currentVersion = (SELECT currentVersion FROM Version)
if (@currentVersion>@changedVersion)
	BEGIN
		WHILE @currentVersion != @changedVersion
			BEGIN
				SELECT @procedureName = v.Prozedur, @tableName = v.Parameter1, @columnName = v.Parameter2,@Parameter3 = v.Parameter3, @Parameter4=v.Parameter4
 FROM Versionen v 
 WHERE VersionNummer = @currentVersion 
				print(@procedureName)
 				DECLARE @constraint as varchar(max)

				IF (@procedureName='new_Table')
					exec rollback_createTable @tableName 
				IF (@procedureName='add_Column')
					exec rollback_createNewColumn @tableName, @columnName
				IF (@procedureName='modifyColumnType')
					exec changeDataType @tablename, @columnname , @Parameter4
				IF (@procedureName='setDefaultConstraint')
					BEGIN
					SET @constraint = 'df_'+@columnName
					exec rollback_Constraint @tableName, @constraint
					END
				IF (@procedureName='setFKConstraint')
					BEGIN
					SET @constraint = 'fk_'+@tableName+'_'+@columnName
					exec rollback_Constraint @tableName, @constraint
					END
				SET @currentVersion=@currentVersion-1
				UPDATE Version SET currentVersion= @currentVersion
			END
			UPDATE Version SET currentVersion= @changedVersion
		END
else
        BEGIN
		SET @currentVersion = @currentVersion + 1
		while(@currentVersion < @changedVersion + 1)
            BEGIN
                SELECT @procedureName = v.Prozedur, @tableName = v.Parameter1, @columnName = v.Parameter2,@Parameter3 = v.Parameter3, @Parameter4=v.Parameter4
				FROM Versionen v 
			    WHERE v.VersionNummer = @currentVersion 

				IF (@procedureName='new_Table')
					exec createTable @tableName, @columnName, @Parameter3
				IF (@procedureName='add_Column')
					exec createNewColumn @tableName, @columnName, @Parameter3
				IF (@procedureName='modifyColumnType')
					exec changeDataType @tablename, @columnname , @Parameter3
				IF (@procedureName='setDefaultConstraint')
					exec newDefaultConstraint @tableName, @columnName, @Parameter3
				IF (@procedureName='setFKConstraint')
					exec newForeignKeyConstraint @tableName, @columnName, @Parameter3, @Parameter4  
				SET @currentVersion = @currentVersion + 1;
				UPDATE Version SET currentVersion= @currentVersion
            END
			UPDATE Version SET currentVersion= @changedVersion
        END
		
END
GO

EXEC new_Table @nameTable='NewTable7', @columnname='ID_table', @columnDataType='float'
GO


EXEC add_Column @tablename='NewTable7' , @newColumn='Column2', @newColumnType='int'
GO

EXEC add_Column @tablename='NewTable7' , @newColumn='Column1', @newColumnType='varchar(40)'
GO


EXEC modifyColumnType @tablename='NewTable7', @columnname='Column1', @newColumnType='char(20)'
GO

SELECT * FROM Versionen
SELECT * FROM VERSION
EXEC setDefaultConstraint @tablename='NewTable7' ,@columnname='Column1',  @defaultValue='1Test'
GO

EXEC setDefaultConstraint @tablename='NewTable7' ,@columnname='Column2',  @defaultValue=2
GO

EXEC new_Table @nameTable='NewTable8', @columnname='ID_table', @columnDataType='float'
GO

EXEC add_Column @tablename='NewTable8' , @newColumn='ID_foreign', @newColumnType='float'
GO

EXEC setFKConstraint @tablename1='NewTable8', @tablename2='NewTable7', @columnname1='ID_foreign', @columnname2='ID_table'
GO

EXEC GoToVersion @changedversion=1
GO

EXEC GoToVersion @changedversion=10
GO

EXEC GoToVersion @changedversion=11
GO

DELETE FROM Versionen
GO

UPDATE Version
SET currentVersion=1;

ALTER TABLE NewTable8
DROP CONSTRAINT fk_NewTable8_NewTable7_ID_foreign;

DROP TABLE NewTable7 ;
GO

DROP TABLE NewTable8 ;
GO
