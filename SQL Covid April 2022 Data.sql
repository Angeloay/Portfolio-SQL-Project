/* Exploring Covid 19 data
Data extracted April 27, 2022

*/

select *
From PortfolioProject..covid_deaths
where continent is not null
order by 3,4

select *
From PortfolioProject..covid_vaccination
where continent is not null
order by 3,4

-- Checking if data is imported correctly

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
order by 1,2

-- Looking at the Total Cases vs. Total Deaths
-- Shows the possibility of death if you contract Covid in Canada

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..covid_deaths
where location like '%Canada%'
order by 1,2

-- Looking at the Total Cases vs. Population
-- Shows the percentage of population in Canada that contracted Covid

Select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
From PortfolioProject..covid_deaths
where location like '%Canada%'
order by 1,2

-- Exploring at the Countries with the highest infection rate when compare with its total population.
Select location, population, date, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
From PortfolioProject..covid_deaths
where continent is not null
Group by location, population, date
order by percent_population_infected desc


-- Exploring the countries with the highest death count per population
Select location, population, Max(Cast(total_deaths as int)) as total_death_count
From PortfolioProject..covid_deaths
where continent is not null
Group by location, population
order by total_death_count desc

-- Grouping by contient
Select continent, Max(Cast(total_deaths as int)) as total_death_count
From PortfolioProject..covid_deaths
where continent is not null
Group by continent
order by total_death_count desc

--Grouping by location
Select location, SUM(cast(new_deaths as int)) as total_death_count
From PortfolioProject..covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'Lower middle income', 'Low income', 'High income')
Group by location
order by total_death_count desc

-- Global numbers of total cases, deaths and death percentage 
Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(New_cases)*100 as death_percentage
From PortfolioProject..covid_deaths
where continent is not null 
Group by date
order by 1,2

-- Global total deaths
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(New_cases)*100 as death_percentage
From PortfolioProject..covid_deaths
where continent is not null 
order by 1,2


-- Joining covid_deaths & covid_vaccination
-- Comparing total population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (rolling_people_vaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac

-- creating temp table

Drop Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
From  #percent_population_vaccinated

-- creating view to store data for later visulizations

Create View percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 