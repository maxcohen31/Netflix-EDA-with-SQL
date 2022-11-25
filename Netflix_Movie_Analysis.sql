/*

SQL DATA ANALYSIS - Dataset avaiable at https://www.kaggle.com/datasets/shivamb/netflix-shows

*/

-- Dataset overview
SELECT * FROM Worksheet$;

-- Unique data
SELECT DISTINCT type FROM Worksheet$; -- two types of show

-- Year range
SELECT DISTINCT release_year FROM Worksheet$
ORDER BY 1 DESC;

-- Number of rows
SELECT COUNT(*) FROM Worksheet$; 

-- Drammatic genre
SELECT COUNT(Worksheet$.title) AS drama
FROM Worksheet$
WHERE Worksheet$.listed_in IN ('Dramas');

-- Family friendly genre
SELECT COUNT(Worksheet$.title) AS Family_friendly
FROM Worksheet$
WHERE Worksheet$.listed_in LIKE '%amil%';

-- Horror genre
SELECT COUNT(Worksheet$.title) AS Horror
FROM Worksheet$
WHERE Worksheet$.listed_in LIKE 'Hor%';

-- Released movies per year
SELECT Worksheet$.release_year AS Year, COUNT(1) AS Movies
FROM Worksheet$
GROUP BY release_year
ORDER BY 1 DESC;

-- how many tv shows/ movies they have for each year 
SELECT Worksheet$.release_year , COUNT(Worksheet$.title) AS 'Movies/TV Shows'
FROM Worksheet$
GROUP BY release_year 
ORDER BY release_year DESC;


-- Movies per location
SELECT Worksheet$.country AS Country,  COUNT(Worksheet$.title) AS Movies
FROM Worksheet$
WHERE Worksheet$.country IN ('United States', 'Japan', 'India') AND Worksheet$.country IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;


-- Making duration column more readable
UPDATE Worksheet$ SET Worksheet$.duration = REPLACE(Worksheet$.duration, 'min', '');


-- Movies which duration is equal or above 100 min. length in the U.S., Japan and India
SELECT Worksheet$.title AS Title, Worksheet$.duration AS Length, Worksheet$.country AS Country
FROM Worksheet$
WHERE Worksheet$.title IN (
							SELECT Worksheet$.title
							FROM Worksheet$
							WHERE country in ('United States', 'Japan', 'India') 
							AND Worksheet$.type in ('Movie')
							AND Worksheet$.duration LIKE '1%%'
							)
ORDER By 2 DESC;

-- CTE for Movie type
WITH CTE_Movies AS(
					SELECT Worksheet$.title AS Title, Worksheet$.duration AS Length, Worksheet$.country AS Country, Worksheet$.release_year AS Year, Worksheet$.listed_in AS Genre
					FROM Worksheet$
					WHERE Worksheet$.title IN (
							SELECT Worksheet$.title
							FROM Worksheet$
							WHERE country in ('United States', 'Japan', 'India') 
							AND Worksheet$.type in ('Movie')
							AND Worksheet$.duration LIKE '1%%'
							)
)
SELECT COUNT(CTE_Movies.Title) AS HorrorCount, CTE_Movies.Country
FROM CTE_Movies
WHERE CTE_Movies.Title IN (
					SELECT CTE_Movies.Title 
					FROM CTE_Movies
					WHERE Genre LIKE 'Horror%' 
					AND Length LIKE '1%%'
)
GROUP BY Country
ORDER BY 1 DESC;


-- Temp table for TV Shows
DROP TABLE IF EXISTS #TvShows
CREATE TABLE #TvShows
(
Title	NVARCHAR(255),				
Director NVARCHAR(255),
Country NVARCHAR(255),
Year INT,
Duration NVARCHAR(255),
Rating NVARCHAR(255)
)

INSERT INTO #TvShows 
SELECT Worksheet$.title, Worksheet$.director, Worksheet$.country, Worksheet$.release_year, Worksheet$.duration, Worksheet$.rating
FROM Worksheet$
WHERE Worksheet$.type='TV Show';


-- Ratings per year
SELECT Rating, COUNT(Rating) AS TotRatings, Year
FROM #TvShows
GROUP BY Year, Rating
ORDER BY 3 DESC;

-- Released per year/country
SELECT COUNT(#TvShows.Title) AS TotShows, #TvShows.Country, #TvShows.Year 
FROM #TvShows
WHERE #TvShows.Country IS NOT NULL
AND #TvShows.Country in ('United States')
GROUP BY Country, Year
ORDER BY 3 DESC;