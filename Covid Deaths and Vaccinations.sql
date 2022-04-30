Select * From PortfolioProject..CovidDeaths$ where continent<>location order by 3,4

--select*from PortfolioProject..CovidVaccinations$

Select Location,date, total_cases,new_cases,total_deaths,population From PortfolioProject..CovidDeaths$
where continent<>location
order by 1,2

--Total Cases Vs Total Deaths

Select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage  From PortfolioProject..CovidDeaths$
where Location like '%India%'
order by 1,2 

--Total Cases vs Population

Select Location,date, total_cases,population,(total_cases/population)*100 as InfectedPercentage  From PortfolioProject..CovidDeaths$
where Location like '%India%'
order by 1,2 

--Highest Infection Rate w.r.t Population

Select Location,population,max(total_cases) as MaxCases,max((total_cases/population))*100 as InfectedPercentage  From PortfolioProject..CovidDeaths$
--where Location like '%India%'
where continent<>location
group by location,population
order by InfectedPercentage desc

--Total Deaths w.r.t Population (Total_Deaths was Varchar therefore not ordering in desc order, casted it to bigint to solve this)
--Added clause continent!=location as continental grouping isn't needed 

Select Location,max(cast(total_deaths  as bigint)) as MaxDeaths From PortfolioProject..CovidDeaths$
--where Location like '%India%'
where continent<>location
group by location
order by MaxDeaths desc


---BREAKING THINGS DOWN BY CONTINENT

Select location,max(cast(total_deaths  as bigint)) as MaxDeaths From PortfolioProject..CovidDeaths$
--where Location like '%India%'
where continent is null
group by location
order by MaxDeaths desc

--GLOBAL NUMBERS(Only Looking at Countries, we use new_cases because we are unable to aggregrate twice the total_cases)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
--Group By date
order by 1,2

--JOINING TABLES VACCINATION AND DEATH ON LOCATION,DATE(Because it's much more specific)

select*
from PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vacc
on death.location =  vacc.location
and death.date = vacc.date

--Total Population vs Vaccination

--Create CTE(same number of columns as inner table)

With VaccineVsPopul (continent, location, date,population, new_vaccinations, LiveVaccineUpdate)
as
(
select death.continent,death.location,death.date,death.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as LiveVaccineUpdate
from PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vacc
on death.location =  vacc.location
and death.date = vacc.date
where death.continent<>death.location
)
select *, (LiveVaccineUpdate/population)*100 as LiveVaccinatedPercent
from VaccineVsPopul

--Creating View for Visualisation

create view VaccineVsPopul as 
select death.continent,death.location,death.date,death.population, vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as LiveVaccineUpdate
from PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vacc
on death.location =  vacc.location
and death.date = vacc.date
where death.continent<>death.location


select*from VaccineVsPopul