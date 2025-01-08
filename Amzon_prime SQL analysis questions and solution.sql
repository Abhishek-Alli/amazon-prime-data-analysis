SELECT * FROM amazon_prime;

-- Q1 :  Count the number of Movies vs TV Shows
--QUERY:
		SELECT type, COUNT(*) 			-- * for select all rows in type column
		FROM amazon_prime
		GROUP BY type;					--	group by used for grouping all the same content in type column

-- 	------------------------------------------------------------------------------------------------------------

-- Q2 : Find the most common rating for movies and TV shows
--QUERY :
		-- Step 1: Create a Common Table Expression (CTE) to calculate the count of each rating for Movies and TV Shows
		WITH RatingCounts AS (
		-- Select the type (Movie or TV Show), rating, and count of each unique combination
		SELECT 
			type,                    -- The type of content (Movie or TV Show)
			rating,                  -- The rating of the content (e.g., PG-13, TV-MA)
			COUNT(*) AS rating_count -- Count the number of occurrences for each type-rating combination
		FROM amazon_prime
		GROUP BY type, rating        -- Group by type and rating to calculate counts for each combination
		),
		
		-- Step 2: Use a second CTE to rank the ratings for each type based on their counts
		RankedRatings AS (
		SELECT 
			type,                    -- Include the type for filtering later
			rating,                  -- Include the rating to identify the most frequent one
			rating_count,            -- Include the count for reference
			RANK() OVER (            -- Use the RANK() function to rank ratings within each type
				PARTITION BY type    -- Create separate rankings for Movies and TV Shows
				ORDER BY rating_count DESC -- Rank by the count in descending order (most frequent first)
			) AS rank                -- Assign a rank to each rating within its type
		FROM RatingCounts
		)
		
		-- Step 3: Select only the most frequent rating for each type
		SELECT 
		type,                        -- The type of content (Movie or TV Show)
		rating AS most_frequent_rating -- The most frequent rating for that type
		FROM RankedRatings
		WHERE rank = 1;                  -- Filter to include only the top-ranked rating for each type

-- 	------------------------------------------------------------------------------------------------------------
-- Q3 :  List all movies released in a specific year (e.g., 2020)
-- QUERY : 
		-- Select the title of all Movies released in the year 2020 from the amazon_prime dataset
		SELECT 
			title               -- Retrieves the title of the content
		FROM 
			amazon_prime         -- Specifies the dataset (table) to query
		WHERE 
			type = 'Movie'       -- Filters the results to include only rows where the type is 'Movie'
			AND release_year = 2020; -- Further filters the results to include only Movies released in 2020
			
-- 	------------------------------------------------------------------------------------------------------------

--Q4 :  Find the top 5 countries with the most content on AMAZON_PRIME
--QUERY :

		-- Analyzing content count for each individual country
		SELECT 
		    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, -- Splits 'country' into individual rows
		    COUNT(show_id) AS total_content                      -- Counts the total number of shows for each country
		FROM amazon_prime
		GROUP BY new_country                                     -- Groups by the resulting individual country
		ORDER BY total_content DESC;                             -- Orders the results by content count (optional)


-- 	------------------------------------------------------------------------------------------------------------
-- Q5: Identify the longest movie
--QUERY:
		-- Select all columns from the Netflix dataset where the type is 'Movie', 
		-- and order the results by movie duration in descending order
		SELECT 
		    *                                       -- Selects all columns from the table
		FROM 
		    netflix                                 -- Specifies the table containing the data
		WHERE 
		    type = 'Movie'                          -- Filters the results to include only rows where the type is 'Movie'
		ORDER BY 
		    SPLIT_PART(duration, ' ', 1)::INT DESC  -- Splits the 'duration' column to extract the numeric part, 
		                                            -- converts it to an integer, and orders the results in descending order

-- 	------------------------------------------------------------------------------------------------------------

-- Q6 : Find content added in the last 5 years
-- QUERY :
		-- Select all columns from the amazon_prime table
		SELECT * 
		FROM amazon_prime
		-- Filter rows where the date_added is within the last 5 years
		WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
		-- TO_DATE function is used to convert the date_added string to a date in the format 'Month DD, YYYY'

-- 	------------------------------------------------------------------------------------------------------------

-- Q7: Find all the movies/TV shows by director 'Rajiv Chilaka'!
--QUERY:
		-- Select all columns from the subquery
		SELECT * 
		FROM
			(
			-- Select all columns and split the 'director' field into an array of director names
			SELECT *,
				UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
			FROM netflix
			) AS subquery
		-- Filter the results to only include rows where the director name is 'Rajiv Chilaka'
		WHERE director_name = 'Rajiv Chilaka';

-- 	------------------------------------------------------------------------------------------------------------

-- Q8: List all TV shows with more than 5 seasons
--QUERY:
		-- Select all columns from the netflix table
		SELECT * 
		FROM netflix
		-- Filter rows where the type is 'TV Show'
		WHERE TYPE = 'TV Show'
		-- Further filter rows where the duration (split by space) is greater than 5
		AND SPLIT_PART(duration, ' ', 1)::INT > 5;
		-- SPLIT_PART(duration, ' ', 1) splits the 'duration' column by space and takes the first part (the number)
		-- ::INT casts the first part of the duration as an integer for comparison
--	------------------------------------------------------------------------------------------------------------		

-- 9. Count the number of content items in each genre
--QUERY:
		-- Select the genre (by splitting 'listed_in' column) and count the total content for each genre
		SELECT 
		    UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre, -- Split the 'listed_in' column by commas and expand it into separate rows, alias as 'genre'
		    COUNT(*) as total_content -- Count the number of rows (content) for each genre
		FROM netflix -- From the 'netflix' table
		GROUP BY 1; -- Group the result by the first column (genre) to get total content for each genre

-- 	------------------------------------------------------------------------------------------------------------

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
--QUERY:

		-- Select the country, release year, total releases, and average release percentage for 'India'
		SELECT 
		    country, -- The country of the show
		    release_year, -- The release year of the show
		    COUNT(show_id) as total_release, -- Count the number of shows released in each year, alias as 'total_release'
		    ROUND(
		        COUNT(show_id)::numeric /
		        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, -- Calculate the percentage of releases for each year relative to the total shows in India
		        2 -- Round the percentage to 2 decimal places
		    ) as avg_release -- Alias the calculated percentage as 'avg_release'
		FROM netflix -- From the 'netflix' table
		WHERE country = 'India' -- Filter the rows to only include content from 'India'
		GROUP BY country, 2 -- Group by country and release year (the second column)
		ORDER BY avg_release DESC -- Order the results by the average release percentage in descending order
		LIMIT 5; -- Limit the results to the top 5 years with the highest average release percentage

-- 	------------------------------------------------------------------------------------------------------------
-- 11. List all movies that are documentaries
--QUERY:		
		-- Select all columns from the netflix table where the 'listed_in' column contains the word 'Documentaries'
		SELECT * 
		FROM netflix -- From the 'netflix' table
		WHERE listed_in LIKE '%Documentaries'; -- Filter to include only rows where the 'listed_in' column contains 'Documentaries' at the end

-- 	------------------------------------------------------------------------------------------------------------


-- 12. Find all content without a director
--QUERY:
		-- Select all columns from the netflix table where the director is NULL
		SELECT * 
		FROM netflix -- From the 'netflix' table
		WHERE director IS NULL; -- Filter to include only rows where the 'director' column is NULL (no director listed)

-- 	------------------------------------------------------------------------------------------------------------

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
--QUERY:

		-- Select all columns from the netflix table where the actor is 'Salman Khan' and the content was released within the last 10 years
		SELECT * 
		FROM netflix -- From the 'netflix' table
		WHERE 
		    casts LIKE '%Salman Khan%' -- Filter to include only rows where 'Salman Khan' appears in the 'casts' column
		    AND 
		    release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10; -- Filter to include only rows where the release year is within the last 10 years
		
-- 	------------------------------------------------------------------------------------------------------------

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
--QUERY:

		-- Select actors and the count of content they appear in, limited to content from India
		SELECT 
		    UNNEST(STRING_TO_ARRAY(casts, ',')) as actor, -- Split the 'casts' column by commas and expand it into separate rows, alias as 'actor'
		    COUNT(*) -- Count the number of rows (content) for each actor
		FROM netflix -- From the 'netflix' table
		WHERE country = 'India' -- Filter the rows to include only content from 'India'
		GROUP BY 1 -- Group the result by actor (the first column, which is 'actor')
		ORDER BY 2 DESC -- Order the results by the count (second column) in descending order
		LIMIT 10; -- Limit the results to the top 10 actors based on the count

-- 	------------------------------------------------------------------------------------------------------------

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
--QUERY:

		-- Select category, type, and the count of content for each category and type
		SELECT 
		    category, -- The category of the content (either 'Bad' or 'Good')
		    TYPE, -- The type of the content (e.g., TV Show, Movie)
		    COUNT(*) AS content_count -- Count the number of content entries for each category and type, alias as 'content_count'
		FROM (
		    -- Inner query to categorize the content based on keywords in the description
		    SELECT 
		        *, -- Select all columns from the netflix table
		        CASE 
		            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad' -- If description contains 'kill' or 'violence', categorize as 'Bad'
		            ELSE 'Good' -- Otherwise, categorize as 'Good'
		        END AS category -- Alias the result of the CASE statement as 'category'
		    FROM netflix -- From the 'netflix' table
		) AS categorized_content -- Alias the inner query as 'categorized_content'
		GROUP BY 1, 2 -- Group the result by category (1) and type (2)
		ORDER BY 2; -- Order the result by type (2)
		

-- 	------------------------------------------------------------------------------------------------------------
-- 	------------------------------------------------------------------------------------------------------------

-- End of reports



		


		