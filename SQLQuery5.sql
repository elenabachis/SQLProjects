--1
CREATE TABLE Ta(
	idA INT PRIMARY KEY,
	a2 INT UNIQUE,
	a3 INT
);

CREATE TABLE Tb(
	idB INT PRIMARY KEY,
	b2 INT,
	b3 INT,
	b4 INT
);

CREATE TABLE Tc(
	idC INT PRIMARY KEY,
	idA INT,
	idB INT,
	FOREIGN KEY (idA) REFERENCES Ta(idA),
    FOREIGN KEY (idB) REFERENCES Tb(idB),
	c2 INT,
	c3 INT,
	c4 INT
);


CREATE OR ALTER PROCEDURE InsertInto
AS
BEGIN
    DECLARE @i INT =1;
	WHILE @i <= 10000
	BEGIN
	INSERT INTO Ta(idA,a2,a3) VALUES (@i, @i*2, @i*3);
	SET @i=@i+1
	END

	SET @i=1
	WHILE @i<=3000
	BEGIN
	INSERT INTO Tb(idB, b2, b3, b4) VALUES (@i, @i*5, @i*7, @i*2);
	SET @i=@i+1
	END

	SET @i=1
	WHILE @i <= 30000
    BEGIN
	    INSERT INTO Tc(idC, idA, idB, c2, c3, c4) VALUES (@i, @i%10000+1, @i%3000+1, @i*4, @i*7, @i*9)
        SET @i = @i + 1;
    END
END 
GO

EXEC InsertInto

SELECT COUNT(*) FROM Ta
SELECT COUNT(*) FROM Tb
SELECT COUNT(*) FROM Tc
DROP TABLE Ta
DROP TABLE Tb
DROP TABLE Tc



--2b

--a
EXEC sys.sp_helpindex @objname = N'Ta'


SELECT * FROM Ta WHERE idA=30

SELECT * FROM Ta ORDER BY idA

SELECT * FROM Ta
WHERE a2>10

SELECT a2 FROM Ta
WHERE a2 LIKE '1%'

--b

SELECT a2,a3
FROM Ta
WHERE a2 BETWEEN 1 AND 5

--c
EXEC sys.sp_helpindex @objname = N'Tb'

SELECT * FROM Tb
WHERE b2=30

CREATE NONCLUSTERED INDEX ib2 ON Tb(b2);
DROP INDEX Tb.ib2
--d

SELECT Tc.idC, Tc.idA FROM Ta
INNER JOIN Tc ON Tc.idA=Ta.idA
WHERE Ta.idA=999

SELECT Tc.idC, Tc.idB FROM Tb
INNER JOIN Tc ON Tc.idB=Tb.idB
WHERE Tb.idB=444

CREATE NONCLUSTERED INDEX iidA ON Tc(idA);
DROP INDEX Tc.iidA
CREATE NONCLUSTERED INDEX iidB ON Tc(idB);
DROP INDEX Tc.iidB





