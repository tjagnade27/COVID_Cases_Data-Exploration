
select * 
from Projects..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from Projects..CovidVaccinations$
--continent is not null
--order by 3,4


--Selecting data which is required 

select location,date,total_cases,new_cases,total_deaths,population
from Projects..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- shows likehood of dying if you contact covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percent
from Projects..CovidDeaths$
where location like '%India%' and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percent of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as Infected_Percent
from Projects..CovidDeaths$
where location like '%India%' and continent is not null
order by 1,2


--Looking at countries with Highest infection rate comapred to population

select location,population,MAX(total_cases) as Highest_InfectionCount,MAX((total_cases/population))*100 as Infected_Percent
from Projects..CovidDeaths$
where continent is not null
Group by location,population
order by Infected_Percent desc


--Showing Countries with Highest death Count per Population

select location,population,MAX(cast(total_deaths as int)) as Total_DeathCount
from Projects..CovidDeaths$
where continent is not null
Group by location,population
order by Total_DeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with highest Death count per population

select continent,MAX(cast(total_deaths as int)) as Total_DeathCount
from Projects..CovidDeaths$
where continent is not null
Group by continent
order by Total_DeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
from Projects..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations

select * 
from Projects..CovidDeaths$
where continent is not null
order by 3,4

select * 
from Projects..CovidVaccinations$
where continent is not null
order by 3,4

Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as int)) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from Projects..CovidDeaths$ d
join Projects..CovidVaccinations$ v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	order by 2,3

--CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as int)) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Projects..CovidDeaths$ d
join Projects..CovidVaccinations$ v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	--order by 2,3
	)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as int)) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Projects..CovidDeaths$ d
join Projects..CovidVaccinations$ v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for LAter Visualizations

USE Projects
CREATE VIEW PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as int)) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Projects..CovidDeaths$ d
join Projects..CovidVaccinations$ v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	--order by 2,3

Select * from PercentPopulationVaccinated





