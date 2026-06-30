
--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their results.
SELECT Team1 , Team2 , Ground , Winner
FROM T20I
WHERE (Team2 = 'West Indies' AND Team1 = 'Sri Lanka') OR (Team1 = 'West Indies' AND Team2 = 'Sri Lanka')


--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.
SELECT  TOP 1 Winner , count(*) NumberOfWins
FROM T20I
GROUP BY Winner
ORDER BY NumberOfWins DESC

--Q3 Rank the teams based on the total number of wins in 2024.
SELECT Winner, count(*) NumberOfWins,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) RankAssigned
FROM T20I
WHERE Winner != 'no result'
GROUP BY Winner

--Q4 Which team had the highest average winning margin (in runs), and what was the average margin?

SELECT *
FROM T20I 

--Q4.1 Which team had the highest average winning margin (in runs), and what was the average margin?

SELECT Winner,AVG(CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT)) AvgMargin
FROM T20I 
WHERE Margin like '%runs'
GROUP BY Winner 
ORDER BY AvgMargin DESC;


-- Average Margin 
SELECT AVG(CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT)) AvgMargin
FROM T20I 
WHERE Margin like '%runs'


 -- Which team had the highest average winning margin (in wickets), and what was the average margin?
SELECT Winner,AVG(CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT)) AvgMargin
FROM T20I 
WHERE Margin like '%wickets'
GROUP BY Winner 
ORDER BY AvgMargin DESC;

-- Average Margin 

WITH AvgMargin AS (SELECT AVG(CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT)) AvgMargin
FROM T20I 
WHERE Margin like '%wickets' OR Margin like '%runs')



--Q5 List all matches where the winning margin was greater than the average margin across all matches.
SELECT Team1 , Team2 , Winner , Margin 
FROM T20I 
WHERE Margin like '%runs' AND CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT) > (
	SELECT AVG(CAST(SUBSTRING (Margin , 1 ,CHARINDEX(' ', Margin)- 1 ) AS INT)) AvgMargin
	FROM T20I 
	WHERE Margin like '%runs'
)



--Q6 Find the team with the most wins when chasing a target (wins by wickets)
WITH Rank AS (SELECT Winner , COUNT(*) NumberOfWins , Dense_Rank() OVER(Order by COUNT(*) DESC) Ranked
FROM T20I 
WHERE Margin like '%wickets' 
GROUP BY Winner 
)

SELECT *
FROM Rank 
WHERE Ranked = 1
 

--Q7 Head-to-head record between two selected teams (e.g., England vs Australia).
SELECT Winner , COUNT(*) NoOfMatches
FROM T20I 
WHERE (Team1 = 'England' AND Team2='Australia') OR (Team2 = 'England' AND Team1='Australia')
GROUP BY Winner

--Q8 Identify the month in 2024 with the highest number of T20I matches played.
SELECT  DATENAME(MONTH,MatchDate) Month, COUNT(*) NumberOfMatches
FROM T20I 
GROUP BY DATENAME(MONTH,MatchDate) 
ORDER BY NumberOfMatches DESC


--Q9 For each team, find how many matches they played in 2024 and their win percentage.

WITH CTE_Matches_Played AS(SELECT Team , COUNT(*) AS MatchesPlayed 
from(
	SELECT Team1 AS Team 
	FROM T20I 

	UNION ALL 
	SELECT Team2 
	FROM T20I) t
	GROUP BY Team ),	  
CTE_Wins AS (SELECT Winner AS Team, COUNT(*) AS MatchesWon
FROM T20I 
GROUP BY Winner)


SELECT p.Team , p.MatchesPlayed, ISNULL(w.MatchesWon, 0) MatchesWon , CAST(w.MatchesWon * 100.00/ p.MatchesPlayed AS DECIMAL(10,2)) AS WinPercentage 
FROM CTE_Matches_Played p
left join CTE_Wins w
ON p.Team = w.Team
order by WinPercentage DESC



--Q10 Identify the most successful team at each ground (team with most wins per ground).

WITH Rank AS (SELECT Ground, Winner, COUNT(*) NumberOfWins ,
Rank() OVER( PARTITION BY Ground ORDER BY COUNT(*) DESC) Rank
FROM T20I
GROUP BY Ground , Winner)

SELECT Ground, Winner, Rank
FROM Rank 
WHERE Rank = 1



