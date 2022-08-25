select *
from [Portfolio project]..CovidDeaths
where continent is not null
order by 3,4

--select *
--from [Portfolio project]..CovidVaccinations
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from [Portfolio project]..CovidDeaths
and continent is not null
order by 1,2

-- Looking at total cases vs total deaths

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where location like '%states%'
order by 1,2


--Loking at total cases vs population

select Location,date,total_cases,Population,(total_cases/Population)*100 as PercentpoplationInfected
from [Portfolio project]..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentpoplationInfected
from [Portfolio project]..CovidDeaths
Group by Location,Population
order by PercentpoplationInfected desc

-- Showing Countries with highes death count per population

select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--Lets break things down by continent

select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc


--Showing continents will highest death counts per population

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

Select SUM(new_cases) as total_cases,SUM(cast (new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM (New_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
On  dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

With PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
On  dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
On  dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view for data for later visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated