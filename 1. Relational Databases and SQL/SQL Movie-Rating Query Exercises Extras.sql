-- Data set: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/moviedata.html

-- Q1 Find the names of all reviewers who rated Gone with the Wind.
select name
from Reviewer
where rID in (select rID from Rating where mID = 101)

-- Q2 For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
select name, title, stars
from (Reviewer join Rating using(rID)) join Movie using(mID)
where name = director

-- Q3 Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
select *
from (select title as name from Movie
	 union
	 select name as name from Reviewer)
order by name

-- Q4 Find the titles of all movies not reviewed by Chris Jackson.
select title
from Movie
where mID not in (select mID 
				 from Rating 
				 where rID = (select rID from Reviewer where name = 'Chris Jackson'))

-- Q5 For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
select distinct SQ1.name, SQ2.name 
from (select * from rating join reviewer using (rID)) as SQ1, 
	 (select * from rating join reviewer using (rID)) as SQ2
where SQ1.mID = SQ2.mID and SQ1.name < SQ2.name
order by SQ1.name

-- Q6 For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select A1.name, A1.title, A1.stars
from (select * from (rating join reviewer using(rID)) join movie using(mID)) as A1
where not exists (select * 
				 from rating as R2
				 where R2.stars < A1.stars)

-- Q7 List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
select title, avg(stars) as avgS
from movie, rating
where movie.mID = rating.mID
group by movie.mID
order by avgS desc, title

-- Q8 Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)
-- Without HAVING:
select name
from reviewer
where rID in (
			 select rID
			 from (select rID, count(rID) as counts from rating group by rID)
			 where counts > 2)
-- Without COUNT:
select name 
from reviewer 
where rID in (select distinct R1.rID 
			 from rating as R1, rating as R2, rating as R3 
			 where R1.rID = R2.rID and R1.rID = R3.rID and ((R1.ratingDate <> R2.ratingDate and R1.ratingDate <> R3.ratingDate and R2.ratingDate <> R3.ratingDate) or (R1.mID <> R2.mID and R1.mID <> R3.mID and R2.mID <> R3.mID) or (R1.stars <> R2.stars and R1.stars <> R3.stars and R2.stars <> R3.stars)))

-- Q9 Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
select movie.title, movie.director
from movie, 
	(select director, count(*) as counts from Movie group by director) as A
where A.counts > 1 and movie.director = A.director
group by movie.director, movie.title

-- Q10 Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select title, max(avgS)
from (select title, avg(stars) as avgS from Movie join Rating using(mID) group by mID)

-- Q11 Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
select title, avgS
from (select title, avg(stars) as avgS from Movie join Rating using(mID) group by mID) as A
where not exists (select * from (select title, avg(stars) as avgS from Movie join Rating using(mID) group by mID) as A1 where A1.avgS < A.avgS)

-- Q12 For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
select director, title, max(stars) as maxS
from movie join rating using(mID)
group by director
except
select director, title, max(stars) as maxS
from movie join rating using(mID)
where director is null