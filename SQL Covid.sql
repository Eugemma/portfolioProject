--select data
use portfolioProject
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location = 'Romania'
order by 1,2

--looking at Total cases vs Population, percentage of population got Covid
select location, count(total_cases) as TotalNrOfCases, population, (count(total_cases)/population)*100 as GotCovidPercentage
from CovidDeaths
where continent is not null
--and location = 'Romania'
group by population, location
order by GotCovidPercentage desc


--looking at countries with highest infection rate compared to population
select location, MAX(total_cases) as MaxNrOfCases, population, MAX((total_cases/population))*100 as GotCovidPercentage
from CovidDeaths
where continent is not null
--and location = 'Romania'
group by location,population
order by GotCovidPercentage desc

--showing contries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location,population
order by TotalDeathCount desc


--highest death rate by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathsPercentage
from CovidDeaths
where continent is not null
order by total_cases, total_deaths


--Looking at Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
and vac.location='Romania'
order by 2,3

--use CTE (Common table expresion)
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--and vac.location='Romania'
)
select * , (RollingPeopleVaccinated/population) from PopvsVac 

--TEMP table
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--and vac.location='Romania'
select * , (RollingPeopleVaccinated/population) from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
and vac.location='Romania'
