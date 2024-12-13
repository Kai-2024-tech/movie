/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

select title 
from Movie
where (select distinct mID not in (select mID from Rating 
) as 'no rating'); 

select name
from Reviewer join Rating using(rID)
where ratingDate is null;

select name reviewer_name, title movie_title, stars, ratingDate 
from Movie 
join Rating on Movie.mID = Rating.mID 
join Reviewer on Rating.rID = Reviewer.rID
order by reviewer_name asc, movie_title asc, stars asc;

-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
select name, title, max(stars)
from Movie
join Rating on Movie.mID = Rating.mID 
join Reviewer on Rating.rID = Reviewer.rID
group by name, title
having count(Reviewer.rID) >= 2; -- my query is wrong

-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.

select title, max(rt1.stars) highest_stars
from Rating rt1 join Rating rt2 
ON rt1.rID = rt2.rID 
AND rt1.mID = rt2.mID 
AND rt1.stars > rt2.stars
JOIN Movie
on rt1.mID = Movie.mID 
group by title
order by title;

-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

SELECT 
    M.title, 
    MAX(R.stars) - MIN(R.stars) AS rating_spread
FROM 
    Movie M
JOIN 
    Rating R ON M.mID = R.mID
GROUP BY 
    M.title
HAVING 
    COUNT(R.stars) > 1   -- Ensures that we only get movies with more than one rating
ORDER BY 
    rating_spread DESC, 
    M.title;

-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

SELECT r1.name AS reviewer_name, m.title AS movie_title
FROM Rating AS rt1
JOIN Rating AS rt2 
  ON rt1.rID = rt2.rID 
  AND rt1.mID = rt2.mID 
  AND rt1.ratingDate < rt2.ratingDate 
  AND rt1.stars < rt2.stars
JOIN Reviewer AS r1 
  ON rt1.rID = r1.rID
JOIN Movie AS m 
  ON rt1.mID = m.mID;
  
 -- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
 -- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
 -- Don't just calculate the overall average rating before and after 1980.)
  
WITH MovieAverages AS (
    SELECT mID, AVG(stars) AS avg_rating
    FROM Rating
    GROUP BY mID
),

Pre1980 AS (
    SELECT AVG(avg_rating) AS avg_before_1980
    FROM MovieAverages MA
    JOIN Movie M ON MA.mID = M.mID
    WHERE M.year < 1980
),

Post1980 AS (
    SELECT AVG(avg_rating) AS avg_after_1980
    FROM MovieAverages MA
    JOIN Movie M ON MA.mID = M.mID
    WHERE M.year > 1980
)

SELECT 
    ABS(Pre1980.avg_before_1980 - Post1980.avg_after_1980) AS rating_difference
FROM 
    Pre1980, Post1980;
    
  --  Find the names of all reviewers who rated Gone with the Wind.
    
select distinct r1.name
from Rating rt1
Join Rating rt2 on rt1.rID = rt2.rID
				and rt1.mID = rt2.MID
Join Reviewer r1 on rt1.rID =  r1.rID
Join Movie m on rt1.mID = m.mID
where m.title = 'Gone with the Wind';

-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.

select r1.name, m.title, rt1.stars
from Rating rt1
Join Rating rt2 on rt1.rID = rt2.rID
				and rt1.mID = rt2.MID
Join Reviewer r1 on rt1.rID =  r1.rID
Join Movie m on rt1.mID = m.mID
where r1.name = m.director;

-- Return all reviewer names and movie names together in a single list, alphabetized. 
-- (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)

select name title_name
from Reviewer 
union 
select title title_name
From Movie
order by title_name asc; 

-- Find the titles of all movies not reviewed by Chris Jackson.

select distinct m.title
from Rating rt1
Join Rating rt2 on rt1.rID = rt2.rID
				and rt1.mID = rt2.MID
Join Reviewer r1 on rt1.rID =  r1.rID
Join Movie m on rt1.mID = m.mID
where m.director <> 'Chris Jackson';

-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
-- For each pair, return the names in the pair in alphabetical order.

SELECT DISTINCT 
    r1.name AS reviewer1, 
    r2.name AS reviewer2
FROM 
    Rating AS ra1
JOIN 
    Rating AS ra2 ON ra1.mID = ra2.mID AND ra1.rID < ra2.rID
JOIN 
    Reviewer AS r1 ON ra1.rID = r1.rID
JOIN 
    Reviewer AS r2 ON ra2.rID = r2.rID
ORDER BY 
    reviewer1, reviewer2;

-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

select title movie_titles, avg(stars) average_ratings
from Movie join Ratings using(mID)
group by movie_titles
order by movie_titles asc;

-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.

select title movie_titles, avg(stars) average_stars
From Movie join Rating using (mID)
group by movie_titles
order by average_stars desc, movie_titles asc;

-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)

SELECT DISTINCT r1.name
FROM Reviewer r1
JOIN Rating ra1 ON r1.rID = ra1.rID
JOIN Rating ra2 ON r1.rID = ra2.rID AND ra1.rID < ra2.rID
JOIN Rating ra3 ON r1.rID = ra3.rID AND ra2.rID < ra3.rID;

select name, count(stars) stars
from Rating join Reviewer on Rating.rID = Reviewer.rID
group by name 
having count(Rating.rID) >= 3;

-- Some directors directed more than one movie.
--  For all such directors, return the titles of all movies directed by them, along with the director name. 
-- Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT DISTINCT  m1.title, m1.director
FROM Movie m1
JOIN Movie m2 ON m1.director = m2.director AND m1.mID <> m2.mID
ORDER BY m1.director, m1.title;

-- 

select stars, max(avg(stars)) from Rating group by stars;
select stars in (select max(stars) from Rating) from Rating;


 



































