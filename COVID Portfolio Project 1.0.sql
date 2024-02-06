
Select * 
From PortfolioProject..CovidDeaths
where continent is null
order by 3,4

Select * 
From PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases) * 100 as PercentagePopulationDeaths
From PortfolioProject..CovidDeaths
Where location like '%germany'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of confirmed cases per country's population

Select location, date, population, total_cases, (1.0*total_cases/population) * 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%germany'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
-- Highest infection rates per country

Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((1.0*total_cases/population) * 100) as MaxPercentagePopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by MaxPercentagePopulationInfected DESC

-- Looking at countries sorted by highest death rate per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- Breakdown by Continent

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not like '%income'
group by location
order by TotalDeathCount DESC

-- Looking at income groups sorted by highest death rate per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location like '%income'
group by location
order by TotalDeathCount DESC

-- Global numbers

Select location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases) * 100 as PercentagePopulationDeaths
From PortfolioProject..CovidDeaths
where location like 'world'
order by 1,2

--Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)*1.0/SUM(new_cases) * 100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where continent is not null and NULLIF(new_cases,0) is not null
----group by date
--order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Looking at Total Vaccinations per capita
-- Using CT

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (cast(RollingVaccinations as float)/population)*100
From PopvsVac
order by 2,3

--Using Temp Table

DROP Table if exists #PercentVaccinationsPopulation
Create Table #PercentVaccinationsPopulation
(
continent nvarchar(50),
location nvarchar(50),
date date,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentVaccinationsPopulation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select *, (cast(RollingVaccinations as float)/population)*100
From #PercentVaccinationsPopulation
order by 2,3


-- Creating View to store data for later vizualizations

Create View PercentVaccinationsPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null