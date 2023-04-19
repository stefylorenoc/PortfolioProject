select *
from public."CovidDeaths"

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from public."CovidDeaths"
order by 1,2

-- Looking at total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from public."CovidDeaths"
where location like '%States%'
order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from public."CovidDeaths"
-- where location like '%States%'
order by 1,2


-- Looking at countries with highest infection rate compared to population 
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from public."CovidDeaths"
-- where location = 'Colombia'
group by location, population
order by PercentPopulationInfected desc
-- limit 10


-- Showing countries with the highest death count per population 
select location, max(total_deaths) as TotalDeathCount
from public."CovidDeaths"
-- where location = 'Colombia'
where continent notnull
group by location
order by  TotalDeathCount desc
-- limit 10


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 
select continent, MAX(total_deaths) as TotalDeathCount
from public."CovidDeaths"
-- where location = 'Colombia'
where continent notnull
group by continent
order by TotalDeathCount desc
-- limit 10


-- GLOBAL NUMBERS 
Select SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from public."CovidDeaths"
-- where location = 'Colombia'
where continent notnull
--group by date
order by 1,2
-- limit 10

-- COVID DEATHS & COVID VACCINATIONS TABLES CAN BE JOINED ON LOCATION AND DATE

-- Total Population vs Vaccinations
-- Show percentage of population that has received at least one covid vaccine
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- te va sumando la anterior + la nueva por location 
	--, (RollingPeopleVaccinated/population)*100 THIS CANNOT BE DONDE because RollingPeopleVaccinated is a column you've just created, to do that you need to use CTE
from coviddeaths d
	join covidvaccinations v
		on d.location = v.location 
		and d.date = v.date
--where d.continent notnull
--where d.continent = 'Europe' and d.location like 'A%'

-- Using CTE to perform calculation on partition by in previous query
With PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
	select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- te va sumando la anterior + la nueva por location 
	--, (RollingPeopleVaccinated/population)*100 THIS CANNOT BE DONDE because RollingPeopleVaccinated is a column you've just created, to do that you need to use CTE
from coviddeaths d
	join covidvaccinations v
		on d.location = v.location 
		and d.date = v.date
where d.continent notnull
)
select *, (RollingPeopleVaccinated/Population)*100
from PopulationVsVaccination

-- Using Temp Table to perform calculation on partition by in previous query (this is an alternative to CTE)
Create temporary table PercentPopulationVaccinated
(Continent character varying(50),
 Location character varying(50),
 Date date,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
from coviddeaths d
	join covidvaccinations v
		on d.location = v.location 
		and d.date = v.date
--where d.continent notnull

-- Testing temp table
select *,(RollingPeopleVaccinated/Population)*100 from PercentPopulationVaccinated
where location = 'Albania' and date between '2021-04-22' and '2021-04-25'
-- Results: the same as CTE


-- Creating View to store data for later visualizations (create more)
Create view PopulationVaccianted as 
select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- te va sumando la anterior + la nueva por location 
	--, (RollingPeopleVaccinated/population)*100 THIS CANNOT BE DONDE because RollingPeopleVaccinated is a column you've just created, to do that you need to use CTE
from coviddeaths d
	join covidvaccinations v
		on d.location = v.location 
		and d.date = v.date
where d.continent notnull



	

