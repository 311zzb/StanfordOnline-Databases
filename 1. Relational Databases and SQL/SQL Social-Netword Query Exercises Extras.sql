-- Data set: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/socialdata.html

-- Q1 For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from 
	(((select L1.ID1 as IDA, L1.ID2 as IDB, L2.ID2 as IDC
	from likes as L1, likes as L2
	where L1.ID2 = L2.ID1 and L2.ID2 <> L1.ID1) as X
	join highschooler H1 on H1.ID = X.IDA) as Y
	join highschooler H2 on H2.ID = Y.IDB) as Z
	join highschooler H3 on H3.ID = Z.IDC

-- Q2 Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
select A.name, A.grade
from (highschooler H1 join friend F on H1.ID=F.ID1) A join highschooler H2 on H2.ID=A.ID2
except
select A.name, A.grade
from (highschooler H1 join friend F on H1.ID=F.ID1) A join highschooler H2 on H2.ID=A.ID2
where A.grade = H2.grade

-- Q3 What is the average number of friends per student? (Your result should be just one number.)
select avg(counts)
from (select count(*) as counts from friend group by ID1)

-- Q4 Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
select count(*) - 1
from (select ID2
	 from friend
	 where ID1 in (select ID2 from friend where ID1 = 1709)
union 
select ID2 from friend where ID1 = 1709)

-- Q5 Find the name and grade of the student(s) with the greatest number of friends.
select name, grade
from highschooler
where ID in (
			select ID1
			from (select ID1, count(*) as counts from friend group by ID1) as X1
			where not exists (select * 
							 from (select ID1, count(*) as counts from friend group by ID1) as X2 
							 where X2.counts > X1.counts))