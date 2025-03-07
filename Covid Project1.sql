select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs population
-- shows what percentage of population got in covid

select location,date,total_cases,population,(total_cases/population)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2


--looking at countries with highest infection ratw compared to population

select location,population,MAX(total_cases) as HighestInfectioncount,Max((total_cases/population))*100 as PercentagepopulationInfected 
from PortfolioProject..CovidDeaths$
--where location like '%india%'
group by location, population
order by PercentagepopulationInfected desc


--Showing Countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathcount desc

--Lets break things down by continent

select continent ,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathcount desc


select location ,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is null
group by location
order by TotalDeathcount desc


select continent ,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathcount desc

-- Showing the continent with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathcount desc

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as Rollingpeoplecaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-- USE CTE

with PopvsVac (Continent , Location, Date, Population,new_vaccinations, Rollingpeoplecaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as Rollingpeoplecaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select*, (Rollingpeoplecaccinated/Population)*100
from PopvsVac


-- Temp table
DROP table if exists #PercentPopulationCaccinated
Create Table #PercentPopulationCaccinated
(
continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplecaccinated numeric
)

Insert into #PercentPopulationCaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as Rollingpeoplecaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select*, (Rollingpeoplecaccinated/Population)*100
from #PercentPopulationCaccinated


-- creating view to store data for later visualization

Create View PercentPopulationCaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,
dea.date) as Rollingpeoplecaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationCaccinated