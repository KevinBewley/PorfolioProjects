--SELECT * 
--FROM Portfolio_project.dbo.covid_deaths
--order by 3,4

--SELECT * 
--FROM Portfolio_project.dbo.covid_vaccinations
--order by 3,4

--shows the likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_project.dbo.covid_deaths
--WHERE location like '%state%'
order by date desc


--Looking at total cases vs. population

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage, (total_deaths/population)*100 as DeathPercentage
FROM Portfolio_project.dbo.covid_deaths
WHERE location like '%state%'
order by date desc

--Showing countries by percentage of population that have been infected
SELECT location, population, max(total_cases/population)*100 as InfectedRate
FROM Portfolio_project.dbo.covid_deaths
GROUP BY location, population
ORDER BY InfectedRate desc

--Showing highest death count per location (top 50)
SELECT location, population, max(cast(total_deaths as int)) as DeathCount
FROM Portfolio_project.dbo.covid_deaths
WHERE continent <> 'Null'
GROUP BY location, population
ORDER BY DeathCount desc
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY

--Grouping the above by continent
SELECT location, population, max(cast(total_deaths as int)) as DeathCount
FROM Portfolio_project.dbo.covid_deaths
WHERE continent is Null
GROUP BY location, population
ORDER BY DeathCount desc


--Looking at the percentage of population that have been severely ill (to the ICU) due to Covid
select distinct cd.location, cd.icu_patients_per_million, cd.total_deaths, cv.hospital_beds_per_thousand 
from Portfolio_project.dbo.Covid_deaths as cd
inner join Portfolio_project.dbo.Covid_vaccinations as cv
on cd.iso_code = cv.iso_code
where cd.icu_patients_per_million <> 'null'
order by cd.icu_patients_per_million desc

--Global Numbers  
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM Portfolio_project.dbo.covid_deaths
where continent is not null
--group by date 
order by 1,2

--Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as bigint)) 
OVER (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
FROM portfolio_project.dbo.covid_deaths as cd
join portfolio_project.dbo.covid_vaccinations as cv
on cd.location = cv.location
WHERE cd.continent is not null
and cd.date = cv.date
order by 2,3

--Creating a View of Death Counts by Continent, then querying it
create view DeathCountsByContinent
as
SELECT location, population, max(cast(total_deaths as int)) as DeathCount
FROM Portfolio_project.dbo.covid_deaths
WHERE continent is Null
GROUP BY location, population
ORDER BY DeathCount desc

select * from DeathCountsByContinent

--Total death count by location excluding income level, world, EU and international

select location, sum(cast(new_deaths as int)) as totaldeathcount
from Portfolio_project.dbo.covid_deaths
where continent is null
and location not in ('Upper middle income', 'High income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
group by location
order by totaldeathcount desc

--Top 100 countries with the highest percentage of their population that has been infected
SELECT
	location,
	population,
	MAX(total_cases) as HighestInfectionCount, 
	MAX(total_cases/population)*100 as Percentpopulationinfected
FROM Portfolio_project.dbo.Covid_deaths
WHERE location not in ('Europe', 'Asia', 'North America', 'South America', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
GROUP BY location, population
ORDER BY Percentpopulationinfected desc
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY

-- Showing the above query with all results except international

SELECT
	location,
	population,
	date,
	MAX(total_cases) as HighestInfectionCount,
	MAX(total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio_project.dbo.covid_deaths
WHERE location not in ('International')
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc