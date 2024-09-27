-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows

select
	type,
	rating as Most_frequent_rating
from(
	select 
		type,
		rating,
		rating_count,
        rank() over (partition by type order by rating_count desc) as rank1 
	from (
		select 
			type,
            rating ,
            count(*) as rating_count
		from netflix 
        group by 1,2
        )
	as a
)
 as b 
 where 
	rank1 =1 ;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		SUBSTRING_INDEX(country, ',', 1) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY substring_index(duration, ' ', 1);


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE str_to_date(date_added, '%M %d, %Y') >= CURRENT_DATE - INTERVAL 5 DAY;



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(

SELECT 
	*,
	SUBSTRING_INDEX(director, ',', 1) as director_name
FROM 
netflix
) as a
WHERE 
	director_name = 'Rajiv Chilaka';



-- 8. List all TV shows with more than 5 seasons

SELECT 
    *
FROM
    netflix
WHERE
    TYPE = 'TV Show'
        AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;



-- 9. Count the number of content items in each genre

SELECT 
	SUBSTRING_INDEX(listed_in, ',', 1)as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !



SELECT  
    release_year, 
    total_release, 
    ROUND(
        total_release / (SELECT COUNT(DISTINCT release_year) FROM netflix WHERE country = 'India'), 2
    ) AS avg_release
FROM (SELECT  
        release_year,  
        COUNT(show_id) AS total_release 
      FROM netflix 
      WHERE country = 'India' 
      GROUP BY release_year) as a 
ORDER BY avg_release DESC  
LIMIT 5;



-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';



-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



SELECT 
	SUBSTRING_INDEX(casts, ',', 1) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

