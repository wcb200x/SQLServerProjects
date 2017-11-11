--William Brown
--CIS 310-01
--10/24/2016
--A7

--103
select Movie_title, Movie_Year, Movie_Genre
from MOVIE
--104
select Movie_year, Movie_Title, Movie_cost 
from Movie
order by Movie_year desc
--105 
select  Movie_Title,Movie_Year, Movie_Genre
from Movie
order by Movie_Genre asc,Movie_year desc
--106
select Movie_num, Movie_Title, Price_code
from MOVIE
where Movie_title like 'R%'
--107
select Movie_Title, Movie_Year, Movie_Cost
from Movie
where Movie_title like '%Hope%'
--108
select Movie_Title, Movie_Year, Movie_Genre
from Movie
where Movie_Genre = 'ACTION'
--109
select Movie_Num, Movie_Title, Movie_cost
from Movie
where Movie_Cost >= '40'
--110
select Movie_Num, Movie_Title, Movie_Cost, Movie_Genre
from Movie
where (Movie_Genre = 'Action' or Movie_Genre = 'Comedy')
		and Movie_cost <50
order by Movie_Genre
--111
select Mem_Num, Mem_FName, Mem_LName, Mem_Street, Mem_State, Mem_Balance
from MEMBERSHIP
where Mem_State = 'TN' And Mem_Street like '%Avenue' And Mem_Balance <'5'
--112
Select Movie_Genre, Count(Movie_Genre) as [Number of Movies]
From Movie
Group By Movie_Genre
--113
select AVG(Movie_Cost) as [Average Movie Cost]
from Movie
--114
select Movie_Genre, AVG(Movie_cost) as [Average Cost]
from Movie
Group by Movie_Genre
--115
select Movie_Title, Movie_Genre, Price_Description, Price_RentFee
FROM Movie M, Price P
where P.price_code = m.price_code
--116
select Movie_Genre, AVG(Price_RentFee) as [Average Rental Fee]
from Movie M, Price P
where m.price_code = p.price_code
Group By Movie_Genre
--117
select Movie_Title, (Movie_Cost/Price_RentFee) as [Breakeven Rentals]
from Movie M, Price P
where m.price_code = p.price_code
--118
select Movie_Title, Movie_Year
from Movie m, Price p
where m.price_code= p.price_code
--119
select Movie_Title, Movie_Genre, Movie_cost
from Movie
where Movie_Cost >= '44.99' And Movie_Cost <= '49.99'
--120
select Movie_Title, Price_Description, Price_RentFee, Movie_Genre
from Movie M, Price P
where m.price_code = p.price_code and Movie_Genre != ('Action')
--121
select Mem_Num, mem_Fname, Mem_LName, Mem_Balance
from MEMBERSHIP
where Mem_Num in (select Mem_Num from Rental)
--122
select Min(Mem_Balance) as [Minimum Balance], MAX(Mem_Balance) as [Maximum Balance], AVG(Mem_Balance) as [Average Balance]
from Membership
where Mem_Num in (select Mem_Num from Rental)
