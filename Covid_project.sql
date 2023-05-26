use Covid_Project;

-- Check if Data imported properly
select top 10 * from dbo.Covid_Deaths$
where continent is not null -- gets rid of duplicated/summarized data by continent
select top 10 * from dbo.Covid_vacs$ -- limit data to not crash and save time 
where continent is not null;

-- Choosing which data to pull
select Location, date, total_cases, new_cases, total_deaths, population
From dbo.Covid_Deaths$
where continent is not null -- needed in all queries as it is not relevant yet
order by 1,2; -- orders by columns

-- Total cases vs Total Deaths in specified country
select Location, date, total_cases, total_deaths, round((cast(total_deaths as float)/cast(total_cases as float))*100, 2) as Death_Percent
From dbo.Covid_Deaths$
where Location like '%states%'
and continent is not null
order by 1,2;

-- Continent Counts
select location, sum(cast(new_deaths as int)) as Total_Death_count
from Covid_Deaths$
where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'lower middle income', 'Low income' )
group by location
order by Total_Death_count desc;


-- Total cases vs Population
select Location, date, total_cases, population, round((cast(total_cases as float)/cast(population as float))*100, 2) as Infected_Pop_Percent
From dbo.Covid_Deaths$
--where Location like '%states%'
where continent is not null
order by 1,2;

-- Highest Infection rate vs population
select Location, max(cast(total_cases as int)) as Total_infect, population, date, round(max((cast(total_cases as float)/cast(population as float))*100), 3) as Infected_Pop_Percent
From dbo.Covid_Deaths$
--where total_cases is not null
group by location, population, date
order by Infected_Pop_Percent desc;

-- highest death count per population
select Location, max(cast(total_deaths as int)) as highest_deaths, round(max((cast(total_deaths as float)/cast(population as float))*100), 3) as Death_Percent
From dbo.Covid_Deaths$
where continent is not null
group by location
order by highest_deaths desc

-- Continent section

-- Continent: Highest Infection rate vs population
select continent, max(cast(total_cases as int)) as Total_infect, round(max((cast(total_cases as float)/cast(population as float))*100), 2) as Infected_Pop_Percent
From dbo.Covid_Deaths$
where continent is not null
group by continent
order by Infected_Pop_Percent desc;

-- CONTINENT: highest death count per population
select continent, max(cast(total_deaths as int)) as highest_deaths, round(max((cast(total_deaths as float)/cast(population as float))*100), 2) as Death_Percent
From dbo.Covid_Deaths$
where continent is not null
group by continent
order by highest_deaths desc;

-- GLOBAL query

-- World Death Rate
select sum(new_cases) as All_cases, sum(cast(new_deaths as int)) as All_deaths, round(sum(cast(new_deaths as int))/Sum(New_cases)*100,2) as Death_Percent
from dbo.Covid_Deaths$
where continent is not null
order by 1,2;


-- VACINATION QUERIES--

-- Joining tables
select * from Covid_Deaths$ as cd
join Covid_vacs$ as cv
on cd.location = cv.location 
and cd.date = cv.date

--Looking at Total Vacinations and Population
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as Vaccination_count
from Covid_Deaths$ as cd
join Covid_vacs$ as cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by 2,3

-- Adding Percent of Vaccinations compared to Population from above
with Population_Vacinated (continent, location, date, population, new_vaccinations, Vaccination_count)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as Vaccination_count
from Covid_Deaths$ as cd
join Covid_vacs$ as cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
--order by 2,3
)
select *, round((Vaccination_count/population)*100,2) as Percent_Vaccinated from Population_Vacinated
where Vaccination_count is not null
order by 2,3

