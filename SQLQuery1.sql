Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

-- Selecting data being used 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total cases vs Total deaths
-- Chance of death from covid in Australia

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Australia%'
order by 1,2

-- Looking at total cases vs the poulation
-- Shows what % of popuatlion has been infected by covid 

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Australia%'
order by 1,2

-- Highest country infection rate compared to population 

Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%Australia%'
Group by location, population
order by InfectionPercentage desc

-- Country with highest death count per population

Select Location, MAX(Cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%Australia%'
where continent is not null
Group by location, population
order by TotalDeathCount desc

-- Breaking numbers down by continent 

-- Showing continents with highest death count 

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- Where location like '%Australia%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Australia%'
Where continent is not null
Group by date
order by 1,2

-- Covid Vaccination and covide Death join 
-- looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null 
  order by 2,3

  -- Using convert 

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null 
  order by 2,3

  --Use CTE

  With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(Convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location)
  --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp table 

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(Convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Create view 

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(Convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
-- order by 2,3

select *
from PercentPopulationVaccinated

-- Command for dropping view as a view can only be created once

Drop view PercentPopulationVaccinated
