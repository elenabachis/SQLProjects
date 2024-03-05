--1


CREATE DATABASE practicExercise;

CREATE TABLE ZugTyp(
idZugTyp int PRIMARY KEY,
Beschreibung varchar(60)
);

CREATE TABLE Zug(
idZug int PRIMARY KEY,
name varchar(30),
idZugTyp int,
FOREIGN KEY(idZugTyp) REFERENCES ZugTyp(idZugTyp)
);

CREATE TABLE Bahnhof(
idBahnhof int PRIMARY KEY,
Name varchar(30)
);

CREATE TABLE Route(
idRoute int PRIMARY KEY,
Name varchar(30),
idZug int,
FOREIGN KEY(idZug) REFERENCES Zug(idZug)
);

CREATE TABLE RouteBahnhof(
idRoute int ,
idBahnhof int ,
Ankunftszeit time,
Abfahrtszeit time,
PRIMARY KEY(idRoute, idBahnhof),
FOREIGN KEY(idRoute) REFERENCES Route(idRoute),
FOREIGN KEY(idBahnhof) REFERENCES Bahnhof(idBahnhof)
);

INSERT INTO ZugTyp
VALUES
(11, 'schnell'),
(12, 'langsam'),
(13, 'sehr schnell');

INSERT INTO Zug 
VALUES
(1, 'Z1', 11),
(2, 'Z2', 12),
(3, 'Z3', 13);

INSERT INTO Bahnhof
VALUES
(21, 'Viena'),
(22,'Bucuresti'),
(23, 'Cluj');

INSERT INTO Route
VALUES
(31, 'Viena-Cluj', 1),
(32, 'Bucuresti-Cluj', 2),
(33, 'Bucuresti-Viena', 3);

INSERT INTO RouteBahnhof
VALUES
(31, 21, '13:01', '13:30'),  
(31, 22, '09:00', '09:15'), 
(33, 23, '13:01', '13:30'),
(33, 22, '10:30', '10:35');


INSERT INTO RouteBahnhof
VALUES
(33, 21, '13:01', '13:30'),  
(32, 22, '13:01', '13:30');

INSERT INTO RouteBahnhof
VALUES
(33, 290, '13:01', '13:30'),  
(31, 23, '13:01', '13:30');
--2

CREATE OR ALTER PROCEDURE addBahnhofToRoute
@routeID int,
@bahnhofID int,
@bahnhof varchar(30),
@ankunftszeit time, 
@abfahrtszeit time
AS
BEGIN

	IF EXISTS (SELECT 1 FROM RouteBahnhof WHERE idRoute = @routeID AND idBahnhof = @bahnhofID)
	BEGIN
	DECLARE @newMinute AS int
	SET @newMinute= DATEPART(MINUTE, @ankunftszeit)+30;

	DECLARE @newTime1 AS TIME
	SET @newTime1= DATEADD(MINUTE, @newMinute, @ankunftszeit);

	DECLARE @newTime2 AS TIME
	SET @newTime2= DATEADD(MINUTE, @newMinute, @abfahrtszeit);
	UPDATE RouteBahnhof SET Ankunftszeit=@newTime1 WHERE idRoute=@routeID
	UPDATE RouteBahnhof SET Abfahrtszeit=@newTime2 WHERE idRoute=@routeID
	END
	ELSE
	BEGIN
    INSERT INTO Bahnhof (idBahnhof, Name) VALUES (@bahnhofID, @bahnhof);
    INSERT INTO RouteBahnhof (idRoute, idBahnhof, Ankunftszeit, Abfahrtszeit) VALUES (@routeID, @bahnhofID, @ankunftszeit, @abfahrtszeit);
	END
END;
GO

Update RouteBahnhof SET Ankunftszeit='13:01'WHERE idBahnhof='21' 
Update RouteBahnhof SET Abfahrtszeit='13:30'WHERE idBahnhof='21' 
EXEC addBahnhofToRoute @routeID=31, @bahnhofID=21, @bahnhof='Viena', @ankunftszeit='13:01', @abfahrtszeit='13:30'
EXEC addBahnhofToRoute @routeID=31, @bahnhofID=290, @bahnhof='Linz', @ankunftszeit='13:01', @abfahrtszeit='13:30'
SELECT * FROM Bahnhof
SELECT * FROM RouteBahnhof

DELETE FROM RouteBahnhof WHERE idBahnhof=290

EXEC addBahnhofToRoute @routeID=31, @bahnhofID=24, @bahnhof='Linz', @ankunftszeit='13:01', @abfahrtszeit='13:30'

--3

CREATE OR ALTER FUNCTION dbo.SameTimeTrains (@time time)
RETURNS TABLE
AS
RETURN
(
	SELECT B.idBahnhof, B.Name
	FROM Bahnhof B
	JOIN RouteBahnhof RB ON RB.idBahnhof=B.idBahnhof
	WHERE RB.Abfahrtszeit=@time
	GROUP BY B.idBahnhof, B.Name
	HAVING COUNT(RB.idRoute)>1
)

SELECT *
FROM dbo.SameTimeTrains('13:30');

--5

SELECT * FROM RouteBahnhof
SELECT * FROM Bahnhof
INSERT INTO Route
VALUES(27, 'R7', 3);

INSERT INTO RouteBahnhof
VALUES
(27, 21, '12:00','12:10'),
(27, 22, '12:00','12:10'),
(27, 23, '12:00','12:10'),
(27, 290, '12:00','12:10');


SELECT R.Name
FROM Route R
JOIN RouteBahnhof RB ON R.idRoute=RB.idRoute
GROUP BY R.Name
HAVING COUNT(*)=(SELECT COUNT(B.idBahnhof) FROM Bahnhof B)

--6

SELECT B.Name
FROM Bahnhof B
JOIN RouteBahnhof RB ON RB.idBahnhof=B.idBahnhof
GROUP BY B.Name
HAVING MAX(DATEDIFF(Minute, RB.Ankunftszeit, RB.Abfahrtszeit))=(SELECT MAX(DATEDIFF(Minute, RB.Ankunftszeit, RB.Abfahrtszeit)) FROM RouteBahnhof RB);


--4


--SELECT * FROM Routes