CREATE TABLE netflix_titles (
    show_id TEXT,
    type_show TEXT,
    title TEXT,
    director TEXT,
    casts TEXT,
    country TEXT,
    date_added TEXT,
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT
);

select * from netflix_titles;

-- 1. Count the number of Movies vs TV Shows;
SELECT 
    COUNT(*),type_show
FROM netflix_titles
GROUP BY 2;			-- type column is in second place in after writing select statement

-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type_show,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY 1,2    	-- means that ->type, rating
),
RankedRatings AS (
    SELECT 
        type_show,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type_show ORDER BY rating_count DESC) AS ranking
    FROM RatingCounts
)
SELECT 
    type_show,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE ranking = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix_titles
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
select countries  ,count(countries) as counting from 
	(select 
		* , trim(unnest(string_to_array(country , ','))) as countries
	from netflix_titles)as elements
	group by countries 
	order by counting desc
	limit 5;


-- 5. Identify the Longest Movie 
-- method 1.
SELECT 
    *
FROM netflix_titles
WHERE type_show = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
-- method 2.
-- query of mysql workbranch
-- SELECT *
-- FROM netflix_titles
-- WHERE type_show = 'Movie'
-- ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- 6. Find Content Added in the Last 5 Years
-- type 1.
select *  
	from netflix_titles
	where date_added is not null 
	and to_date(date_added ,'Month DD, YYYY') >= current_date - interval '5 years'
	order by date_added desc;
	

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!	
select * 
	from
		(select 
	* , unnest(string_to_array(director,',')) as directors
	from netflix_titles) as elements
	where directors = 'Rajiv Chilaka';

-- 8. List All TV Shows with More Than 5 Seasons	
-- method 1.
select * from
		(select * , cast((string_to_array(duration, ' '))[1] as integer) as season_count 
		from netflix_titles 
		where type_show = 'TV Show' ) as elements 
		where season_count >= 5;
-- Method 2.
SELECT *
FROM netflix_titles
WHERE type_show = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the Number of Content Items in Each Genre  
select unnest(string_to_array(listed_in , ',')) as genre, count(*)
	from netflix_titles
	group by 1 ;

-- 10.Find each year and the average numbers of content release in India on netflix.	

with avg_release_ as
	(select country, release_year , count(*) as count_par_year
	from netflix_titles 
	where country = 'India'
	group by release_year , country) , 
	total as (select count(*) as all_total from netflix_titles where country = 'India')
	select 
	avg_release_.country,
	avg_release_.release_year ,
	round((avg_release_.count_par_year::numeric/ total.all_total::numeric)*100,2) as xx 
	from avg_release_,total order by avg_release_.count_par_year desc;
	;
	-- -----Note------------ 
-- - The :: operator is PostgreSQL’s shorthand for type casting.
-- - numeric is a data type in PostgreSQL that can store numbers with arbitrary precision (decimals, very large integers, etc.).
	
SELECT 5 / 2;          -- result: 2   (integer division)
SELECT 5::numeric / 2; -- result: 2.5 (decimal division)

-- 11. List All Movies that are Documentaries	
select * 
	from netflix_titles 
	where type_show = 'Movie' and listed_in like '%Documentaries%';

-- 12. Find All Content Without a Director	
select * 
	from netflix_titles
	where Director is null;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years	

SELECT * 
FROM netflix_titles
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;	

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India  
select stars , count(stars) as counting
from
(select *,
	trim(unnest(string_to_array(casts , ','))) as stars
	from netflix_titles
	where country = 'India')
	as elements
	group by stars
	order by counting desc;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords	
select Quality , count(*) 
	from
	(select *,
	case 
	when description like '%kill%' or description like '%Kill%' or description like '%violence%' or description like '%Violence%' then 'Bad_movie'
	else 'Good_movie' 
	end Quality
		from netflix_titles) as elements
		group by Quality;

-- Findings and Conclusion
-- 1 .Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
-- 2. Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
-- 3. Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
-- 4. Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

-- This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.