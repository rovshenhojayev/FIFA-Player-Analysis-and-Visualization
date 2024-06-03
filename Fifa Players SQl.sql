-- cheking data is correct
select * from fifa_players fp limit 100

-- Top 100 Players by Overall Rating
SELECT name, overall_rating 
FROM fifa_players fp  
ORDER BY overall_rating DESC 
LIMIT 100

--Players with the Best Dribbling Skills
SELECT name, dribbling 
FROM fifa_players fp  
ORDER BY dribbling DESC 
LIMIT 100

--Average Market Value and Wage Based on Overall Ratings
SELECT "name" , overall_rating, AVG(value_euro) AS average_value, AVG(wage_euro) AS average_wage
FROM fifa_players fp 
GROUP BY "name" ,overall_rating
ORDER BY overall_rating desc

--Top 100 Players by Market Value
SELECT name, value_euro 
FROM fifa_players fp   
where value_euro is not null 
ORDER BY value_euro desc
LIMIT 100

--Comparison of Player Performance by Position
SELECT "name", positions, AVG(overall_rating) AS average_rating, AVG(potential) AS average_potential
FROM fifa_players fp 
GROUP BY name, positions
ORDER BY average_rating desc

--Identifying Underpaid Players Based on Their Performance
WITH avg_wages AS (
    SELECT 
        overall_rating,
        AVG(wage_euro) AS average_wage
    FROM 
        fifa_players 
    GROUP BY 
        overall_rating
)
SELECT 
    p.name,
    p.overall_rating,
    p.wage_euro,
    avg_w.average_wage,
    p.wage_euro < avg_w.average_wage AS is_underpaid
FROM 
    fifa_players p
JOIN 
    avg_wages avg_w ON p.overall_rating = avg_w.overall_rating
WHERE 
    p.wage_euro < avg_w.average_wage
ORDER BY 
    p.overall_rating DESC, p.wage_euro ASC;


   
--Identifying Undervalued High-Potential Players
with avg_market_values as(
	select potential,
	avg(value_euro) as average_market_value
	from fifa_players
	group by potential
)   
   
select p."name" ,
p.potential ,
p.value_euro ,
avg_mv.average_market_value,
p.value_euro < avg_mv.average_market_value * 0.7 as is_undervalued
from fifa_players p  
  join avg_market_values avg_mv on p.potential = avg_mv.potential
  where
  p.value_euro < avg_mv.average_market_value * 0.7
  order by
  p.potential desc, p.value_euro asc; 
   
   
--Top Players by Skill for Each Position
 SELECT 
    p1.name,
    p1.positions,
    p1.dribbling
FROM 
    fifa_players  p1
WHERE 
    p1.dribbling = (
        SELECT MAX(p2.dribbling)
        FROM fifa_players p2
        WHERE p2.positions = p1.positions
    )
ORDER BY 
    p1.positions, p1.dribbling DESC
	limit 100;   
   
--Finding Players with Specific Skill Combinations
SELECT 
    name,
    overall_rating,
    dribbling,
    finishing
FROM 
    fifa_players
WHERE 
    dribbling > 85 AND finishing > 85
ORDER BY 
    overall_rating DESC;

--Player Value Distribution by Nationality
   SELECT 
    nationality,
    COUNT(*) AS player_count,
    AVG(value_euro) AS average_value,
    MIN(value_euro) AS min_value,
    MAX(value_euro) AS max_value
FROM 
    fifa_players fp 
GROUP BY 
    nationality
ORDER BY 
    average_value DESC;

--Performance Metrics by Age Group
--Compare player performance metrics across different age groups (e.g., <20, 20-25, 25-30, >30)
   SELECT 
    CASE 
        WHEN age < 20 THEN '<20'
        WHEN age BETWEEN 20 AND 25 THEN '20-25'
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        ELSE '>30'
    END AS age_group,
    AVG(overall_rating) AS average_rating,
    AVG(potential) AS average_potential,
    AVG(value_euro) AS average_value
FROM 
    fifa_players p 
GROUP BY 
    age_group
ORDER BY 
    age_group;

--Top Players in Each National Team
   SELECT 
    national_team,
    name,
    overall_rating
FROM 
    fifa_players fp2 
WHERE 
    (national_team, overall_rating) IN (
        SELECT 
            national_team, MAX(overall_rating)
        FROM 
            fifa_players fp
        GROUP BY 
            national_team
    )
ORDER BY 
    national_team;
   
   
   
 CREATE VIEW top_high_potential_players AS
WITH avg_market_values AS (
    SELECT 
        potential,
        AVG(value_euro) AS average_market_value
    FROM 
        fifa_players p
    GROUP BY 
        potential
)
SELECT 
    p.name,
    p.potential,
    p.value_euro,
    avg_mv.average_market_value,
    p.value_euro < avg_mv.average_market_value * 0.7 AS is_undervalued
FROM 
    fifa_players p
JOIN 
    avg_market_values avg_mv ON p.potential = avg_mv.potential
WHERE 
    p.value_euro < avg_mv.average_market_value * 0.7
ORDER BY 
    p.potential DESC, p.value_euro ASC;

   
   
   
  CREATE OR REPLACE PROCEDURE get_top_high_potential_players()
LANGUAGE plpgsql
AS $$
BEGIN
    WITH avg_market_values AS (
        SELECT 
            potential,
            AVG(value_euro) AS average_market_value
        FROM 
            fifa_players p
        GROUP BY 
            potential
    )
    SELECT 
        p.name,
        p.potential,
        p.value_euro,
        avg_mv.average_market_value,
        p.value_euro < avg_mv.average_market_value * 0.7 AS is_undervalued
    FROM 
        fifa_players p
    JOIN 
        avg_market_values avg_mv ON p.potential = avg_mv.potential
    WHERE 
        p.value_euro < avg_mv.average_market_value * 0.7
    ORDER BY 
        p.potential DESC, p.value_euro ASC;
END;
$$;


