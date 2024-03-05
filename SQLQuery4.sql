--teil 1
 
--1

CREATE OR ALTER FUNCTION dbo.ValidateErstellungsjahr ( @param1 int)
RETURNS BIT
AS
BEGIN

DECLARE @isValid as BIT;

if(@param1 BETWEEN 1450 AND YEAR(GETDATE()))
SET @isValid = 1;

else
SET @isValid = 0;

RETURN @isValid
END

print dbo.ValidateErstellungsjahr(11)
print dbo.ValidateErstellungsjahr(2023)


CREATE OR ALTER FUNCTION dbo.ValidateTypEinband (@param1 VARCHAR(10))
RETURNS BIT
AS 
BEGIN 

DECLARE @isValid as BIT;

if(@param1 IN (SELECT Typ_des_Einbandes FROM Buch) AND @param1 IN ('Paperback', 'Hardcover'))
SET @isValid=1;

else
SET @isValid=0;

RETURN @isValid
END

print dbo.ValidateTypEinband ('90edit')
print dbo.ValidateTypEinband ('Paperback')

CREATE OR ALTER PROCEDURE dbo.ValidateInsert(
    @idBuch VARCHAR(10),
    @titel VARCHAR(45),
    @erstellungsjahr INT,
    @idFirma VARCHAR(10),
    @TypEinband VARCHAR(25)
)
AS
BEGIN

	IF dbo.ValidateErstellungsjahr(@erstellungsjahr) = 0 
    BEGIN
        PRINT('Erstellungsjahr');
        RETURN;
    END


	IF dbo.ValidateTypEinband(@TypEinband) = 0 
    BEGIN
        PRINT('TypEinband');
        RETURN;
    END


    INSERT INTO Buch (ID_Buch, Titel, Erstellungsjahr, ID_Firma, Typ_des_Einbandes)
    VALUES (@idBuch, @titel, @erstellungsjahr, @idFirma, @TypEinband);

    PRINT('Ein neues Buch ist eingefügt!!');
END;


exec dbo.ValidateInsert '48b', 'Mara', 2025, '1edit', 'Paperback'
exec dbo.ValidateInsert '48b', 'Mara', 1894, '1edit', 'Paper'
exec dbo.ValidateInsert '48b', 'Mara', 1894, '1edit', 'Paperback'

DELETE FROM Buch WHERE ID_Buch='48b'
SELECT * FROM Buch

--2

CREATE OR ALTER VIEW [BuchInfo] AS
SELECT B.ID_Buch,B.Titel, B.Erstellungsjahr, B.Typ_des_Einbandes,
A.Name_Autor AS NameAutor, A.Vorname_Autor AS VornameAutor

FROM Buch B
INNER JOIN AutorBuch AB ON AB.ID_Buch=B.ID_Buch
INNER JOIN Autor A ON A.ID_Autor=AB.ID_Autor


SELECT * FROM BuchInfo

CREATE OR ALTER FUNCTION dbo.AnzahlEinkaufen(@Datum smalldatetime)
RETURNS TABLE
AS
RETURN
(
	SELECT
    B.ID_Buch,
    SUM(UniqueProduct) AS Anzahl
FROM
    Buch B
JOIN (
    SELECT DISTINCT
        BP.ID_Produkt,
        BP.Kantitaet AS UniqueProduct
    FROM
        Bestellung_Produkt BP
    JOIN
        Bestellung Be ON Be.ID_Bestellung = BP.ID_Bestellung
	WHERE CAST(Be.Datum AS DATE) =@Datum
) Subquery ON Subquery.ID_Produkt= B.ID_Buch
GROUP BY
    B.ID_Buch

)

SELECT BI.* ,AE.Anzahl AS Einkaufen
FROM BuchInfo BI
INNER JOIN dbo.AnzahlEinkaufen('2023-11-15') AE ON BI.ID_Buch = AE.ID_Buch
ORDER BY Einkaufen DESC


--teil 2

--3

DROP Table LogTabelle
CREATE TABLE LogTabelle(
	AnweisungZeit DATETIME,
	TypAnweisung varchar(2),
	Tabellennamme varchar(10),
	AnzahlTupeln int
);

CREATE OR ALTER TRIGGER KundeLogTabelle
ON
Kunde
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
DECLARE @Anweisung varchar(2);
DECLARE @AnzahlTupeln int;

if EXISTS( SELECT * FROM inserted)
BEGIN

if EXISTS( SELECT * FROM deleted)
BEGIN
SET @Anweisung='U'
SET @AnzahlTupeln= (SELECT COUNT(*) FROM deleted)
END

else
BEGIN
SET @Anweisung='I'
SET @AnzahlTupeln= (SELECT COUNT(*) FROM inserted)
END

END

else 
BEGIN
SET @Anweisung='D'
SET @AnzahlTupeln=( SELECT COUNT(*) FROM deleted)
END

INSERT INTO LogTabelle( AnweisungZeit, TypAnweisung, Tabellennamme, AnzahlTupeln)
VALUES( GETDATE(), @Anweisung, 'Kunde', @AnzahlTupeln);

END;

INSERT INTO Kunde(ID_Kunde, Name, Vorname, Geburtsdatum, Addresse)
VALUES
('8k', 'Burduhos' , 'Maria', '1990-09-08', 'Strada Ferentari'),
('9k', 'Burduhos' , 'Cornel', '1990-09-08', 'Strada Ferentari');

UPDATE Kunde
SET Name='Bachis'
WHERE Addresse='Strada Ferentari';

UPDATE Kunde
SET Name='Bac'
WHERE ID_Kunde IN ('8k', '9k');

SELECT * FROM Kunde
DELETE FROM Kunde
WHERE ID_Kunde IN ('8k', '9k');

SELECT * FROM LogTabelle
DELETE FROM LogTabelle
DROP TABLE LogTabelle

--4

DROP TABLE BlackFridayBestellungen
CREATE TABLE BlackFridayBestellungen(
	idBestellung varchar(10) PRIMARY KEY,
	GesamtPreis float,
	FOREIGN KEY (idBestellung) REFERENCES Bestellung(ID_Bestellung)
);

CREATE OR ALTER PROCEDURE GesamtPreis
@idBestellung varchar(10), 
@Gesamt float OUTPUT
AS
BEGIN
    SELECT @Gesamt = SUM(BP.Preis * BP.Kantitaet)
    FROM Bestellung_Produkt BP
    WHERE BP.ID_Bestellung = @idBestellung;
END;
GO

DECLARE @idBestellung varchar(10);
DECLARE @neuesPreis float;

DECLARE BlackFriday CURSOR FOR
SELECT DISTINCT BP.ID_Bestellung, BP.Preis
FROM Bestellung_Produkt BP
INNER JOIN Bestellung B ON BP.ID_Bestellung=B.ID_Bestellung
WHERE CONVERT(DATE, B.Datum) = '2023-11-15';

OPEN BlackFriday;

FETCH NEXT FROM BlackFriday INTO @idBestellung, @neuesPreis;

WHILE @@FETCH_STATUS = 0
BEGIN 
    DECLARE @Gesamt float;
    EXEC GesamtPreis @idBestellung, @Gesamt OUTPUT;
    -- PRINT @Gesamt
    IF @Gesamt > 100
    BEGIN
        SET @neuesPreis = @Gesamt * 0.5;
   --     PRINT 'Updating: ID_Bestellung=' + @idBestellung + ', ID_Produkt=' + @idProdukt + ', NeuesPreis=' + CAST(@neuesPreis AS NVARCHAR(20));

    END
    ELSE
    BEGIN
	    SET @neuesPreis = @Gesamt
	
     --   PRINT 'NO';
    END

	IF NOT EXISTS (SELECT 1 FROM BlackFridayBestellungen WHERE idBestellung = @idBestellung)
	BEGIN
	INSERT INTO BlackFridayBestellungen (idBestellung, GesamtPreis)
    VALUES (@idBestellung, @neuesPreis);
	END

    FETCH NEXT FROM BlackFriday INTO @idBestellung, @neuesPreis;
END

CLOSE BlackFriday;
DEALLOCATE BlackFriday;


--(10*12+12,5*3)/2 -> 78,75 -> 8bet
--(12*1 + 19*4) ->9bet
--(10*7 + 13,08* 5)/2 ->67,7 ->10bet
--16,4 -> 3bet
--17+23*2 -> 17+46+90 = 153 -> 153/2= 76,5->5bet
--10bet, 3bet, 5bet, 8bet, 9bet
SELECT * FROM Bestellung_Produkt
SELECT * FROM BlackFridayBestellungen

DROP TABLE BlackFridayBestellungen




