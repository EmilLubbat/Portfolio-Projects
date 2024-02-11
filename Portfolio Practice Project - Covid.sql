
-- Total Cases vs Total Deaths in UK

Select location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
From PortfolioProject..CovidDeaths
where location like 'U% K%'
ORDER BY 1,2


-- Highest infections per capita:

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

-- Against time

Select location, population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
Order by PercentPopulationInfected desc


-- Total death count per country:

Select location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
	--total_deaths incorrectly stored as nvarchar, needs to be cast as int to perform calculation
From PortfolioProject..CovidDeaths
Where continent is not NULL
	--data for continents are stored where continent name is under location and continent column is null 
Group by location
Order by TotalDeathCount desc


-- Total death per continent:

Select location, SUM(CAST(new_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
And location not in ('World', 'European Union', 'International')
	--World, European Union and Internation are catagories where the data contains duplicates from other continents
Group by location
Order by TotalDeathCount desc


-- Global deaths per case

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL


-- Total population vs vaccinations

With pop_vac (continent, location, date, population, new_vaccination, cum_vaccinations)
	AS 
	(
	Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by death.location
		Order by death.location, death.date) AS cum_vaccinations
	From PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
	where death.continent is not NULL
	)

Select *, (cum_vaccinations/population)*100 AS '%cum_vaccinations'
From pop_vac


--Views

Create view HighestInfections as
Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
--Order by PercentPopulationInfected desc

Create view HighestDailyInfections AS
Select location, population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
--Order by PercentPopulationInfected desc

Create view GolbalDeathPerCase AS
Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL


Create view TotalDeathPerContinent AS
Select location, SUM(CAST(new_deaths AS int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
And location not in ('World', 'European Union', 'International')
Group by location
--Order by TotalDeathCount desc

Create view Vaccinations as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
	, SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by death.location
		Order by death.location, death.date) AS cum_vaccinations
	From PortfolioProject..CovidDeaths death
	join PortfolioProject..CovidVaccinations vac
		on death.location = vac.location
		and death.date = vac.date
	where death.continent is not NULL

-- Total population vs vaccinations using view
	Select *, (cum_vaccinations/population)*100 AS '%cum_vaccinations'
From PortfolioProject..Vaccinations