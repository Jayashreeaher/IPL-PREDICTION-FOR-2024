-- Top 10 bowlers based on past 3 years total wickets taken.
select * from fact_bowling_summary;
select n.bowlerName,sum(n.wickets) as total_wickets
from fact_bowling_summary n
join dim_match_summary m
on 
n.match_id=m.match_id
where  STR_TO_DATE(m.matchDate, '%b %d, %Y') IS NOT NULL AND
YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3 
group by bowlerName,YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y')) 
order by total_wickets
desc
limit 10;
select * from fact_bowling_summary;
with filter_data as (
select b.bowlerName,sum(b.runs)as total_runs,
sum(wickets) as total_wickets,
sum(b.overs)*6 as total_balls
from fact_bowling_summary b
join dim_match_summary m on b.match_id=m.match_id
where STR_TO_DATE(m.matchDate, '%b %d, %Y') IS NOT NULL
      AND YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3
      group by bowlername,YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y'))
      having total_balls>=60  ),
qualified_bowlers as
(
select bowlerName,
round(sum(total_runs)/nullif(sum(total_wickets),0),2) as bowling_average
from filter_data
group by bowlerName
)
select * from qualified_bowlers
	ORDER BY bowling_average asc
LIMIT 10;
-- Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
WITH filter_data AS (
    SELECT 
        b.bowlerName,
        SUM(b.overs) * 6 AS total_balls,
        SUM(b.runs) AS total_runs
    FROM fact_bowling_summary b
    JOIN dim_match_summary m
        ON b.match_id = m.match_id
    WHERE STR_TO_DATE(m.matchDate, '%b %d, %Y') IS NOT NULL
      AND YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3
    GROUP BY b.bowlerName, YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y'))
    HAVING total_balls >= 60
),
qualified_bowlers AS (
    SELECT 
        bowlerName,
        ROUND(SUM(total_runs) / (SUM(total_balls) / 6), 2) AS economy_rate
    FROM filter_data
    GROUP BY bowlerName

)
SELECT *
FROM qualified_bowlers
ORDER BY economy_rate ASC
LIMIT 10;
select * from fact_bowling_summary;
WITH filterd_data AS 
(
	SELECT 
		b.bowlerName,
		SUM(b.`0s`) AS total_dot_balls,
		SUM(b.overs) * 6 AS total_balls
	FROM fact_bowling_summary b
	JOIN dim_match_summary m ON b.match_id = m.match_id
	WHERE YEAR(STR_TO_DATE(matchDate,'%b %d, %Y')) >= YEAR(CURDATE()) - 3 
	GROUP BY b.bowlerName
),
bowlers AS 
(
	SELECT 
		bowlerName,
		ROUND(SUM(total_dot_balls) / SUM(total_balls) * 100, 2) AS dot_ball_percentage
	FROM filterd_data
	GROUP BY bowlerName
)
SELECT * 
FROM bowlers
ORDER BY dot_ball_percentage DESC
LIMIT 5;
WITH recent_matches AS (
    SELECT match_id, matchDate, team1, team2, winner
    FROM dim_match_summary
    WHERE YEAR(STR_TO_DATE(matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3
),
all_teams AS (
    SELECT team1 AS team FROM recent_matches
    UNION ALL
    SELECT team2 AS team FROM recent_matches
),
matches_played AS (
    SELECT team, COUNT(*) AS total_matches
    FROM all_teams
    GROUP BY team
),
wins AS (
    SELECT winner AS team, COUNT(*) AS total_wins
    FROM recent_matches
    WHERE winner IS NOT NULL
    GROUP BY winner
),
win_percentage_calc AS (
    SELECT 
        m.team,
        m.total_matches,
        COALESCE(w.total_wins, 0) AS total_wins,
        ROUND(COALESCE(w.total_wins, 0) / m.total_matches * 100, 2) AS win_percentage
    FROM matches_played m
    LEFT JOIN wins w ON m.team = w.team
)
SELECT *
FROM win_percentage_calc
ORDER BY win_percentage DESC
LIMIT 4;
SELECT 
    winner AS team_name,
    COUNT(*) AS total_wins
FROM 
    dim_match_summary
WHERE 
    YEAR(STR_TO_DATE(matchDate, '%b %d, %Y')) = 2023
    AND winner IS NOT NULL
GROUP BY 
    winner
ORDER BY 
    total_wins DESC
LIMIT 4;
 
      
     