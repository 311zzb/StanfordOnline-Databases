-- Data set: https://courses.edx.org/asset-v1:StanfordOnline+SOE.YDB-SQL0001+2T2020+type@asset+block/socialdata.html

-- Q1 Find the names of all students who are friends with someone named Gabriel.
select name
from highschooler
where ID in (select ID2 from friend where ID1 in (select ID from highschooler where name = 'Gabriel'))

-- Q2 For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select A.name, A.grade, B.name, B.grade
from (highschooler join likes on highschooler.ID = likes.ID1) as A join highschooler as B on B.ID = A.ID2 
where A.grade - B.grade > 1

-- Q3 For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
select T1.name, T1.grade, T2.name, T2.grade
from (likes L join highschooler H on L.ID1 = H.ID) as T1,
	 (likes L join highschooler H on L.ID1 = H.ID) as T2
where T1.ID1 = T2.ID2 and T1.ID2 = T2.ID1 and T1.name < T2.name

-- Q4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
select name, grade
from highschooler
where ID not in (select ID1 from likes union select ID2 from likes)
order by grade, name

-- Q5 For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select H.name, H.grade, B.name, B.grade
from highschooler H 
	 join (select * from likes 
	 	 join (select * from highschooler where ID in (select ID2 from likes) and ID not in (select ID1 from likes)) as A 
		 on likes.ID2 = A.ID) as B 
	 on H.ID = B.ID1

-- Q6 Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
select name, grade
from highschooler
except
select A.name, A.grade
from (friend F join highschooler H on F.ID1 = H.ID) A join highschooler B on A.ID2 = B.ID
where A.grade <> B.grade
order by grade, name

-- Q7 For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
select Hx.name, Hx.grade, Hy.name, Hy.grade, Hz.name, Hz.grade
from highschooler Hz 
	join (highschooler Hy 
		join (highschooler Hx 
			join (select A.ID1 as IDA, B.ID2 as IDB, F2.ID2 as IDC
				 from ((select * from likes except select * from friend) A 
				 		join friend F1 on A.ID1 = F1.ID1) B 
				 			join friend F2 on B.ID2 = F2.ID1
				where F1.ID2 = F2.ID2) X 
			on Hx.ID = X.IDA) Y 
		on Hy.ID = Y.IDB) Z 
	on Hz.ID = Z.IDC

-- Q8 Find the difference between the number of students in the school and the number of different first names.
select A.numS - B.numN
from (select count(*) as NumS from highschooler) A,
 (select count(distinct name) as NumN from highschooler) B

-- Q9 Find the name and grade of all students who are liked by more than one other student.
select name, grade
from highschooler
where ID in (select ID2 
			 from (select ID2, count(*) as counts from likes group by ID2) 
			 where counts > 1)