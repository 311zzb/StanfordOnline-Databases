-- Data set: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/moviedata.html

-- Q1 Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into Reviewer
select '209', 'Roger Ebert'

-- Q2 For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
update Movie
set year = year + 25
where mID in 
			(select mID
			from rating
			group by mID
			having avg(stars) >= 4)

-- Q3 Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from rating
where stars < 4 and mID in (select mID from Movie where year<1970 or year>2000)