USE Library

DELETE FROM Buch WHERE ID_Buch LIKE '%b'
DELETE FROM Angestellte WHERE ID_Angestellte LIKE '%A'
USE Library
DELETE FROM Autor WHERE ID_Autor LIKE '%aut'
DELETE Bestellung WHERE ID_Bestellung LIKE '%bet'
--1a
CREATE TABLE Sprache(
	ID_Sprache varchar(10) ,
	Name_Sprache varchar(25),
	PRIMARY KEY(ID_Sprache)
);

CREATE TABLE Buch_Sprache(
	ID_Buch varchar(10),
	ID_Sprache varchar(10),
	PRIMARY KEY (ID_Buch, ID_Sprache),
	FOREIGN KEY (ID_Buch) REFERENCES Buch(ID_Buch),
	FOREIGN KEY (ID_Sprache) REFERENCES Sprache(ID_Sprache)
);

--1c

INSERT INTO Buch(ID_Buch, Titel, Erstellungsjahr, ID_Firma, Typ_des_Einbandes)
VALUES('20b', 'Povestea lui Harap-Alb', 1840, '18edit', 'Hardcover')

--1d

--BETWEEN Anweisungen
USE Library
UPDATE Buch
SET ID_Firma='2edit'
WHERE Erstellungsjahr BETWEEN 2000 AND 2012

USE Library
DELETE FROM Buch WHERE Erstellungsjahr<2000


--LIKE Anweisungen

USE Library
DELETE FROM Buch WHERE Typ_des_Einbandes LIKE 'H%'


UPDATE Angestellte
SET Geburtsdatum='2000/02/03'
WHERE Vorname_Angestellte LIKE 'M%'

--IN Anweisungen
USE Library
UPDATE Angestellte
SET Name_Angestellte='Hasdeu'
WHERE Addresse IN ('Strada Pastorului, Cluj', 'Barlogul lui Faust,BCU, Cluj');

USE Library 
DELETE FROM Buch WHERE Erstellungsjahr IN (2009, 2004)

--is [not] null
Use Library
UPDATE Buch
SET Typ_des_Einbandes='Hardcover'
WHERE Typ_des_Einbandes IS NOT NULL 


USE Library
DELETE FROM Autor WHERE Geburtsdatum IS NULL

Use Library
DELETE FROM Angestellte WHERE Vorname_Angestellte='Mara' OR (YEAR(Geburtsdatum)>1995 AND YEAR(Geburtsdatum)<2003)


UPDATE Buch
SET Typ_des_Einbandes='Paperback'
WHERE Erstellungsjahr<2000 AND (ID_Firma='3edit' OR ID_Firma='1edit')

