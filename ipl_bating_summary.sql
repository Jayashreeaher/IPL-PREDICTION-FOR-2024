use ipl_data;
select * from fact_bating_summary
;
--  Top 10 batsmen based on past 3 years total runs scored.
select b.batsmanName,sum(runs) as total_runs
from fact_bating_summary b
join dim_match_summary m
on b.match_id=m.match_id
where YEAR(STR_TO_DATE(matchDate, '%b %d, %Y'))>=year(current_date())-3
group by b.batsmanname
order by total_runs
desc
limit 10;
-- Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in
-- each season)
SELECT 
  b.batsmanName,
  SUM(runs) AS total_runs,
  SUM(CASE WHEN `out/not_out` = 'out' THEN 1 ELSE 0 END) AS total_dismissal,
  SUM(balls) AS total_balls,
  ROUND(
    SUM(runs) / NULLIF(SUM(CASE WHEN `out/not_out` = 'out' THEN 1 ELSE 0 END), 0),
    2
  ) AS batting_avg
FROM fact_bating_summary b
JOIN dim_match_summary m ON b.match_id = m.match_id
WHERE YEAR(STR_TO_DATE(matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3
GROUP BY b.batsmanName
HAVING total_balls > 180
ORDER BY batting_avg DESC
LIMIT 10;
-- Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)
select * from fact_bating_summary;
SELECT 
    b.batsmanName,sum(balls) as total_balls,
    ROUND(AVG(b.SR), 2) AS avg_strike_rate
FROM fact_bating_summary b
JOIN dim_match_summary m ON b.match_id = m.match_id
WHERE 
    STR_TO_DATE(m.matchDate, '%b %d, %Y') IS NOT NULL AND
    YEAR(STR_TO_DATE(m.matchDate, '%b %d, %Y')) >= YEAR(CURDATE()) - 3 and balls>60
GROUP BY b.batsmanName
ORDER BY avg_strike_rate DESC
LIMIT 10;
;
select * from fact_bating_summary;
with filt_data as 
(
select b.batsmanName,sum(b.balls) as total_balls,sum(b.4s) as total_4s,
sum(b.6s) as total_6s
from fact_bating_summary b
join dim_match_summary m
on b.match_id=m.match_id
where year(str_to_date(matchdate,'%b %d, %Y'))>=year(curdate())-3 
group by b.batsmanName,year(str_to_date(matchdate,'%b %d, %Y'))
having total_balls>60),
quali_batsmen as (
select batsmanName,round((sum(total_4s)+sum(total_6s))/sum(total_balls)*100,2) as boundry_percentage
from filt_data
group by batsmanname)
select * from quali_batsmen
order by boundry_percentage desc
limit 5;
SELECT
    team2 AS chasing_team,
    COUNT(*) AS chasing_wins
FROM dim_match_summary
WHERE 
    STR_TO_DATE(matchDate, '%b %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    AND team2 = winner
GROUP BY team2
ORDER BY chasing_wins DESC
LIMIT 2;

