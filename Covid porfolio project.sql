Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using
Select location,date,total_cases,new_cases,total_cases,population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--Likelihood of dying if you contract covid in india
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid
Select location,date,total_cases,population, (total_deaths/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2


--Looking at countries with hiighest infection rate compared to population
Select location,MAX(total_cases) as highestInfectionCount,population, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--Looking at countries with highest death count per population
Select location,MAX(cast(total_deaths as int)) as highestDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by highestDeathCount desc


--Looking at total deaths in each continent
Select continent,MAX(cast(total_deaths as int)) as highestDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by highestDeathCount desc




--Global Numbers


Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2 



--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3 


-- Use CTE
WITH popvsvac(continent, location, data, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
From popvsvac


--temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
data datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
    on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Select *
From PercentPopulationVaccinated
