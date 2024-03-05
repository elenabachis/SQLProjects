USE Library
--2

--1 Join, 1 Order BY, 1 Group By, 1 Count
SELECT COUNT(*) AS AnzahlBucher , Genre.Name_Genre
FROM Buch 
JOIN BuchGenre ON Buch.ID_Buch=BuchGenre.ID_Buch
JOIN Genre ON Genre.ID_Genre=BuchGenre.ID_Genre
GROUP BY Genre.ID_Genre ,Genre.Name_Genre
ORDER BY Genre.Name_Genre

--1 COUNT, 1 JOIN, 1 GROUP BY, 1 TOP, 1 WHERE
USE Library
SELECT TOP 3 B.ID_Buch, B.Titel AS BuchTitle,COUNT(*) AS Anzahl
FROM Bestellung_Produkt BP
JOIN Buch B ON B.ID_Buch=BP.ID_Produkt
JOIN Bestellung ON Bestellung.ID_Bestellung=BP.ID_Bestellung
GROUP BY B.ID_Buch, B.Titel
ORDER BY Anzahl DESC

--1 SUM, 1 JOIN,  1 Group by, 1 Having
USE Library

SELECT Bestellung.ID_Bestellung, K.Name, K.Vorname, SUM(BP.Preis * BP.Kantitaet) AS TotalPreis
FROM Bestellung
JOIN Kunde K ON Bestellung.ID_Kunde = K.ID_Kunde
JOIN Bestellung_Produkt BP ON Bestellung.ID_Bestellung = BP.ID_Bestellung
JOIN Buch B ON BP.ID_Produkt = B.ID_Buch
GROUP BY Bestellung.ID_Bestellung, K.Name, K.Vorname
HAVING COUNT(BP.ID_Bestellung) > 1


--1 Join, 1 HAVING
USE Library
SELECT Buch.ID_Buch, Buch.Titel
FROM Buch
JOIN AutorBuch AB ON AB.ID_Buch = Buch.ID_Buch
JOIN Autor A ON A.ID_Autor = AB.ID_Autor
GROUP BY Buch.ID_Buch,Buch.Titel
HAVING COUNT(A.ID_Autor)>1

-- 1 OUTER JOIN
USE Library
SELECT K.Name,K.Vorname, B.ID_Bestellung
FROM Kunde K
LEFT OUTER JOIN Bestellung B ON K.ID_Kunde = B.ID_Kunde;

--1 In, 1 EXCEPT, 2 where, 1 join
SELECT B.ID_Buch, B.Titel, B.Erstellungsjahr
FROM Buch B
WHERE B.Erstellungsjahr > 1945
EXCEPT
SELECT B.ID_Buch, B.Titel, B.Erstellungsjahr
FROM Buch B
JOIN Buch_Sprache BS ON BS.ID_Buch = B.ID_Buch
JOIN Sprache Sp ON Sp.ID_Sprache = BS.ID_Sprache
WHERE Sp.ID_Sprache IN (SELECT Sprache.ID_Sprache FROM Sprache WHERE Sprache.Name_Sprache IN ('Deutsch', 'Franzoesisch', 'Englisch', 'Spanisch', 'Italienisch'));

--1 NOT In, 1 Intersect, 1 Where, 1 join
SELECT B.ID_Buch, B.Titel, B.Erstellungsjahr
FROM Buch B
WHERE B.Erstellungsjahr BETWEEN 1918 AND 1939
INTERSECT
SELECT B.ID_Buch, B.Titel, B.Erstellungsjahr
FROM Buch B
JOIN Buch_Sprache BS ON BS.ID_Buch = B.ID_Buch
JOIN Sprache Sp ON Sp.ID_Sprache = BS.ID_Sprache
WHERE Sp.ID_Sprache NOT IN ( SELECT Sprache.ID_Sprache FROM Sprache WHERE Sprache.Name_Sprache IN ('Deutsch', 'Franzoesisch', 'Englisch', 'Spanisch', 'Italienisch'));

--1 Union
USE Library;
SELECT Angestellte.Addresse, Angestellte.ID_Angestellte, Angestellte.Name_Angestellte, Angestellte.Vorname_Angestellte
FROM Angestellte
WHERE Angestellte.ID_Angestellte IN (
    SELECT B.ID_Angestellte
    FROM Bestellung B
)
UNION
SELECT Kunde.Addresse, Kunde.ID_Kunde, Kunde.Name, Kunde.Vorname
FROM Kunde
WHERE Kunde.ID_Kunde IN (
    SELECT B.ID_Kunde
    FROM Bestellung B
);

--Having, ALL
SELECT B.ID_Buch, B.Titel
FROM Buch B
JOIN Bestellung_Produkt BP ON B.ID_Buch= BP.ID_Produkt
WHERE B.Typ_des_Einbandes='Paperback' AND BP.Preis > ALL (
    SELECT BP2.Preis
    FROM Buch B1
	JOIN Bestellung_Produkt BP2 ON BP2.ID_Produkt=B1.ID_Buch
    WHERE B1.Typ_des_Einbandes='Hardcover'
	
);

--1 DISTINCT, 1 ANY, 1 OR
USE Library;

SELECT DISTINCT B.Titel, B.Erstellungsjahr
FROM Buch B
JOIN Bestellung_Produkt BP ON B.ID_Buch= BP.ID_Produkt
WHERE (B.Erstellungsjahr < 1945 OR B.ID_Firma=(SELECT F.ID_Firma FROM Firma F WHERE F.Name = 'Polirom'))
AND BP.Preis > ANY (
    SELECT BP2.Preis
	FROM Buch B2
    JOIN Bestellung_Produkt BP2 ON B2.ID_Buch= BP2.ID_Produkt
	WHERE B2.Erstellungsjahr > 1945
);






