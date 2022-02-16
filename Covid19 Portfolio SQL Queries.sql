Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..['Covid-deaths']
order by 1, 2

-- Looking at Total Cases vs Total Deaths ie Death Rate in South Africa

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid-deaths']
Where location like '%south africa%' and continent is not null
order by 1, 2

--Total cases vs Population ie Infection Rate

Select location, date, total_cases, population, (total_cases/population)*100 as Infection_Rate
From [Covid Portfolio Project]..['Covid-deaths']
Where location like '%south africa%' and continent is not null
order by 1, 2

--Which countries have highest infection rates vs population

Select location,  MAX(total_cases) as Heighest_Infection_Rate, population, MAX(total_cases/population)*100 as Infection_Rate
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%' 
Group By location, population
order by Infection_Rate desc

--Countries with heighest death rate per population

Select location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%'
Where continent is not null
Group By location
order by Total_Death_Count desc

-- Which continents have the heighest death rate 

Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%'
Where continent is not null
Group By continent
order by Total_Death_Count desc

--Global Numbers
--Number of new cases globally each  day

Select date, SUM(new_cases)--,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%' 
Where continent is not null
Group By date
order by 1, 2

--Showing New Daily Cases and Deaily Deaths Globally

Select date, SUM(new_cases) as New_Daily_Cases, SUM(cast(new_deaths as int)) as New_Daily_Deaths--,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%' 
Where continent is not null
Group By date
order by 1, 2

-- Showing Global Daily Death Percentage

Select date, SUM(new_cases) as New_Daily_Cases, SUM(cast(new_deaths as int)) as New_Daily_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From [Covid Portfolio Project]..['Covid-deaths']
--Where location like '%south africa%' 
Where continent is not null
Group By date
order by 1, 2


Select * 
From [Covid Portfolio Project]..['Covid-deaths'] dea
Join [Covid Portfolio Project]..['Covid-vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Population New Vaccination Uptake per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Covid Portfolio Project]..['Covid-deaths'] dea
Join [Covid Portfolio Project]..['Covid-vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Looking at Total population vaccination uptake

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as CountOfVaccinatedPopulation
From [Covid Portfolio Project]..['Covid-deaths'] dea
Join [Covid Portfolio Project]..['Covid-vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CountOfVaccinatedPopulation numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as CountOfVaccinatedPopulation
From [Covid Portfolio Project]..['Covid-deaths'] dea
Join [Covid Portfolio Project]..['Covid-vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

Select *, (CountOfVaccinatedPopulation/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for data viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as CountOfVaccinatedPopulation
From [Covid Portfolio Project]..['Covid-deaths'] dea
Join [Covid Portfolio Project]..['Covid-vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From [Portfolio Project].[dbo].[PercentPopulationVaccinated]