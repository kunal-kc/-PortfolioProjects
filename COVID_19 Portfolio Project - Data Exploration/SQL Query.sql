/* 

Covid 19 Data Exploration 

Skills used in the project: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
From my_project..covid_deaths
Where continent is not null
ORDER BY 3,4

SELECT *
From my_project..covid_deaths
WHERE continent is not NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT [location],[date], total_cases,new_cases, total_deaths, population
From my_project..covid_deaths
ORDER BY 1,2


-- Looking at Total Cases Vs Total Deaths
-- This result show the likelyhood of dying if you contract covid in your country

SELECT [location],[date], total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From my_project..covid_deaths
WHERE [location] like '%India%'
ORDER BY 1,2


-- Looking at Tootal Case Vs Population 
-- Shows the percentage of population got Covid


SELECT [location],[date], population,total_cases,(total_cases/population)*100 as infected_percentage
From my_project..covid_deaths
WHERE [location] like '%India%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

	
SELECT [location], population, MAX(total_cases) as highest_infection_count, max(total_cases/population)*100 as infection_percentage
FROM my_project..covid_deaths
WHERE continent is not NULL
GROUP BY [location], population
order by infection_percentage DESC

-- Countries with Highest Death Count per Population

SELECT [location],max(CAST(total_deaths as int)) as deaths -- converting  total_death column char to int
FROM my_project..covid_deaths
WHERE continent is not NULL
GROUP by [location]
ORDER by deaths DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing the contintenets with the higest death count per population

SELECT [continent],max(CAST(total_deaths as int)) as deaths -- converting  total_death column char to int
FROM my_project..covid_deaths
WHERE continent is not NULL
GROUP by [continent]
ORDER by deaths DESC


-- Global Number

-- Death percentage on per day

SELECT [date], SUM(new_cases) as Cases, sum(cast(new_deaths as int)) as death
,sum(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage -- converting  total_death column char to int
FROM my_project..covid_deaths
WHERE continent is not NULL
GROUP by [date]
order by 1, 2

-- Total death percentage all over the word


SELECT sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/SUM(new_cases)*100 as total_death_percentage
From my_project..covid_deaths
WHERE continent is not null 

-- Looking at total population Vs vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Joining the both the table of covid death and covid vaccine 

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS rolling_peoples_vaccination
From my_project..covid_deaths dea -- dea alise for covid-19 death table 
JOIN my_project..covid_vaccination vac -- vac alise for covid-19 vaccine tabel
     ON dea.[location]= vac.[location]
     and dea.[date]=vac.[date]
WHERE dea.continent is not NULL
order by 2,3

-- Covid Reproducation rate per day 

SELECT location, date, reproduction_rate
FROM my_project..covid_deaths
WHERE continent is not null
Order by location, date

-- ICU Patients numbers 
-- Shows the number of population who got addmitted In ICU

SELECT location, date, population, icu_patients,
SUM(CONVERT(BIGINT, icu_patients)) OVER (PARTITION BY location ORDER BY location, date) as total_icu_patients
FROM my_project..covid_deaths
WHERE continent is not null
ORDER BY location, date

-- ICU Patients Percentage
-- Using CTE to perform calculation 
-- show the percentage of total poplulation who got addmitted in ICU

With per_in_icu( location, date, population, icu_patients, total_icu_patients)
as
(
SELECT location, date, population, icu_patients,
SUM(CONVERT(BIGINT, icu_patients)) OVER (PARTITION BY location ORDER BY location, date) as total_icu_patients
FROM my_project..covid_deaths
WHERE continent is not null 
--ORDER BY location, date
)
SELECT *, (total_icu_patients/population)*100 as ICU_patient_percentage
FROM per_in_icu
Order BY location, date

-- Country with higest ICU patients

SELECT location,population, sum(cast(icu_patients as bigint)) as Total_icu_patients
FROM my_project..covid_deaths
where continent is not null
GROUP BY location,population
ORDER BY Total_icu_patients desc

---------------------------
SELECT location,Max( CAST(people_fully_vaccinated AS BIGINT)) as Fully_vaccinated_people 
, SUM(CAST(new_vaccinations AS BIGINT)) as First_dose_vaccinated_people, MAX(CAST(total_vaccinations AS BIGINT)) as Total_vaccination
FROM my_project..covid_vaccination
where continent is not null
Group by location
order by location

-- Temp tabel 

DROP TABLE if EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
  Continet NVARCHAR(255),
  Location NVARCHAR(255),
  Date DATETIME,
  Population NUMERIC,
  Vaccination NUMERIC,
  Rolling_peoples_vaccination NUMERIC
)

INSERT into #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS rolling_peoples_vaccination
From my_project..covid_deaths dea 
JOIN my_project..covid_vaccination vac 
  ON dea.[location]= vac.[location]
  and dea.[date]=vac.[date]
--WHERE dea.continent is not NULL
-- order by 2,3

SELECT * , (Rolling_peoples_vaccination/population) 
from #percent_population_vaccinated

-- Creating View to store data for later visualizations In tabluae

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From my_project..covid_deaths dea 
JOIN my_project..covid_vaccination vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
