-- Data set: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/socialdata.html

-- Q1 It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
delete from highschooler
where grade = 12

-- Q2 If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
delete from likes
where ID1 in (
	select ID1 from (
		select *
		from (
			select ID1, ID2 from (
				select* from likes as L1
				except
				select* from (select L2.ID2, L2.ID1 from likes as L2)))
			intersect
			select * from friend))

-- Q3 For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)
insert into friend
select *
from (
	select distinct IDA, IDC
	from (select F1.ID1 as IDA, F1.ID2 as IDB, F2.ID2 as IDC 
		  from friend F1 join friend F2 on F1.ID2=F2.ID1)
	where IDA <> IDC
	except select* from friend)