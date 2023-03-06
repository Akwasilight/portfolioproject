/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Loading Data 
select*
from [Portfolio project]..CovidDeath
order by 3,4

-- Loading Data without Null in continent
select*
from [Portfolio project]..CovidVacination
where continent is not null
order by 3,4


--selecting some data columns 
select location,date, total_cases, new_cases,total_deaths, population 
from [Portfolio project]..CovidDeath
where continent is not null
order by 1,2 

--Total Cases vs  Total Deaths 
--Shos the likely hold of dying if one contract covid in a country 
select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeath
where location like  '%Ghana%'
 and  continent is not null
order by 1,2 


--Total cases vs population
--Showing the percentage of population that got covid 
select location,date, total_cases,population ,(total_cases/population)*100 as CasesPercentage
from [Portfolio project]..CovidDeath
where location = 'Ghana'
 and continent is not null
order by 1,2 


-- countries With Highest Infection Rate

select location,population, MAX(total_cases) as HighestInfecion, max((total_cases/population)) as Casespercentage
from [Portfolio project]..CovidDeath
where continent is not null
group by location,population
order by Casespercentage desc


-- Countries With The Highest count of Death
select location, MAX(cast(total_deaths as int )) as TotalDeathCount 
from [Portfolio project]..CovidDeath
where continent is not null
group by location
order by TotalDeathCount  desc

-- Contient  with the Highest Count of Death 
select location, MAX(cast(total_deaths as int )) as TotalDeathCount 
from [Portfolio project]..CovidDeath
where continent is   null
group by location
order by TotalDeathCount  desc


--The contient with the Highest count per population
select location, MAX(cast(total_deaths as int )) as TotalDeathCount 
from [Portfolio project]..CovidDeath
where continent is   null
group by location
order by TotalDeathCount  desc

--Global Numbers dte by death
select date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentages 
from [Portfolio project]..CovidDeath
where continent is not null 
group by date 
order by 1,2 

--world death rate 
select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentages 
from [Portfolio project]..CovidDeath
where continent is not null 
--group by date 
order by 1,2 


---- Joining the dataset
select*
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date

---- total population vs total vacination
---- total unmber of vacination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-----suming new vaccinations by location
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) OVER (partition by dea.location order by dea.location,
dea.Date) as Rolling_people_vaccinated 
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--- USE CTE 

WITH popvsvac (continent ,location, Date, population,Rolling_people_vaccinated,new_vaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) OVER (partition by dea.location order by dea.location,
dea.Date) as Rolling_people_vaccinated 
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_people_vaccinated/population)*100
from popvsvac


--- creating view or data visualizations 
create view populationvaccination AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int )) OVER (partition by dea.location order by dea.location,
dea.Date) as Rolling_people_vaccinated 
from [Portfolio project]..CovidDeath dea
join [Portfolio project]..CovidVacination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select*
from populationvaccination

