#olyimpics complete dataset
SELECT * FROM oly.olympics;
#countries dataset: country ID, name, population, continent
SELECT * FROM oly.countries;
#host cities and countries
SELECT * FROM oly.host_countries;

#checking for PT medalists
SELECT * FROM oly.olympics where NOC="POR" and medal is not null order by Year;

#checking for the younger and older medalists
SELECT * FROM oly.olympics where (Age<=12 or Age>60) and medal is not null order by Year;

#checking all summer olympic host cities
SELECT distinct city FROM oly.olympics where Season="Summer";

#creating a table to be exported to tableau with all relevant info about summer olympic medalists
create table oly.olympics_test_file as
SELECT distinct a.ID, a.Name, a.Sex, a.Age, a.Height, a.Weight, a.Team, a.NOC, a.Year, a.City, d.Country as Host_Country, a.Sport, a.Event, a.Medal, c.Country, c.Continent, c.Continent_2
FROM oly.olympics a left join oly.country_code b on a.NOC=b.NOC
inner join oly.countries c on b.ID=c.ID 
inner join oly.host_countries d on a.City=d.City
where medal is not null and Season="Summer";

# checking the previous created table
select * from oly.olympics_test_file;

select a.NOC, b.ID from oly.olympics a left join oly.countries b on a.NOC=b.ID group by a.NOC;

SELECT Name, Sex, Age, Height, Weight, Team, NOC, Year, Sport, Event, Medal FROM oly.olympics
where Season="Summer"
order by Year, Sport, Event;
select a.Team, b.Country from oly.olympics a left join oly.countries b on a.Team=b.Country
group by a.Team order by 1; 

#checking year, medal and event where countries won medals
select distinct Year, Country, Medal, Event from oly.olympics_test_file
order by 1 desc, 2 desc,4;

#counting number of medals by year, type and country
select Year, Country, Medal, count(Event) as nr_medals from (
select distinct Year, Country, Medal, Event from oly.olympics_test_file
order by 1 desc, 2 desc,4) sub
group by 1,2,3
order by 1 desc, 2 desc;

#creating a table with medals by country
create table oly.medals_country as
select Year, Country, Continent, Continent_2, sum(nr_medals) as total_medals from(
select Year, Country, Continent, Continent_2, Medal, count(Event) as nr_medals from (
select distinct Year, Country, Continent, Continent_2, Medal, Event from oly.olympics_test_file
order by 1 desc, 2 desc,6) sub
group by 1,2,3,4,5
order by 1 desc, 4 desc) sub2
group by 1,2,3,4
order by 1 desc, 5 desc;

#counting medals year, country and gender
select Year, Country, Sex, sum(nr_medals) as total_medals from(
select Year, Country, Sex, Medal, count(Event) as nr_medals from (
select distinct Year, Country, Sex, Medal, Event from oly.olympics_test_file
order by 1 desc, 2 desc, 4) sub
group by 1,2,3,4
order by 1 desc, 2 desc) sub2
group by 1,2,3
order by 1 desc, 2 desc;

#creating a table with medals by country and type of medal
create table oly.medals_BSG_country as
select Year, Country, Medal, sum(nr_medals) as total_medals from(
select Year, Country, Medal, count(Event) as nr_medals from (
select distinct Year, Country, Medal, Event from oly.olympics_test_file
order by 1 desc, 2 desc, 4) sub
group by 1,2,3
order by 1 desc, 2 desc) sub2
group by 1,2,3
order by 1 desc, 2 desc;

#calculating a new field "medals by inhabitant"
select a.Year, a.Country, a.total_medals, b.Population, round(a.total_medals/b.Population*1000000,3) 
from oly.medals_country a inner join oly.countries b on a.Country=b.Country
order by 1 desc, 5 desc;