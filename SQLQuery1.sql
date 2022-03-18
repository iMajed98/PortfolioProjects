select location, date , total_cases, new_cases,total_deaths , population
from SQlTOO..CovidDeaths$
where continent is not null
order by 1,2


-- total cases vs total deaths 
-- shows an aproximate % of dying if you contract covid in saudi arabia 
select location, date , total_cases, total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from SQlTOO..CovidDeaths$
where location like '%Saudi%' 
order by 1,2


--Lookin at the total cases vs population 
-- shows the percentage of population got infected by covid
select location, date , total_cases, population ,(total_cases/population)*100 as CasesPercentage
from SQlTOO..CovidDeaths$
where location like '%Saudi%' 
order by 1,2

--looking at countries with highest infection rate compared to population
select location, MAX(total_cases)as HighestCount,MAX((total_cases/population))*100 as PopulationPercent
from SQlTOO..CovidDeaths$ 
group by location , population
order by PopulationPercent DESC

--showing countries with highest death count per population 


select location,MAX (cast(total_deaths as int )) as TotalDeathCount
from SQlTOO..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Breaking it down by continent & world

select location,MAX (cast(total_cases as int )) as TotalCount , MAX(CAST(total_deaths as int)) as TotalDeath 
from SQlTOO..CovidDeaths$
Where continent is  null
group by location 
order by TotalCount desc


--  GLOBAL NUMBERS 

select  date ,  SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths , SUM(CAST(new_deaths as int )) /SUM(new_cases)*100 as DeathPercent
from SQlTOO..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- total population vs vaccination
Select dae.continent, dae.location , dae.population , dae.date , vac.new_vaccinations , sum(CONVERT(bigint , vac.new_vaccinations )) OVER (partition by dae.location order by dae.location , dae.date) as RollingPeopleVac
from SQlTOO..CovidDeaths$  dae
join SQlTOO..CovidVaccination$  vac
on dae.location = vac.location and  dae.date=vac.date
where dae.continent is not null
order by 2,3


--USING CTE

with PopVsVac (Continent , location , date , population ,new_vaccination ,  RollingPeopleVac)
as(
Select dae.continent, dae.location , dae.population , dae.date , vac.new_vaccinations , sum(CONVERT(bigint , vac.new_vaccinations )) OVER (partition by dae.location order by dae.location , dae.date) as RollingPeopleVac
from SQlTOO..CovidDeaths$  dae
join SQlTOO..CovidVaccination$  vac
on dae.location = vac.location and  dae.date=vac.date
where dae.continent is not null
)
select* ,(convert(bigint , RollingPeopleVac)/convert(bigint,population))*100 as percentige
from PopVsVac
