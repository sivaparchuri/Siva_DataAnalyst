select * from CovidDeaths$
where continent is not null
order by 3,4

--select * from CovidVaccinations$
--order by 3,4

select location,date, total_cases,new_cases,total_deaths,population
from CovidDeaths$ 
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihoood of dying if you contact covid in your country

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$ 
where location like '%states%'
order by 1,2

--- looking at totalcases vs population 
-- shows what percentage of population got covid



select location,date,population,total_cases,(total_cases/population)*100 as deathpecentage
from CovidDeaths$ 
--where location like '%states%'
order by 1,2


-- looking at countries with highest infection rate to population

select location,population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as 
percentpopulationinfected
from CovidDeaths$
group by location,population
order by percentpopulationinfected desc

-- showing countires with highest death count per population 

select location, MAX(cast(total_deaths as int)) as totaldeaths
from CovidDeaths$
where continent is not null

group by location
order by totaldeaths desc

-- lets break things by continent


select location, MAX(cast(total_deaths as int)) as totaldeathcount 
from CovidDeaths$
where continent is  null

group by location
order by totaldeathcount desc

-- showing the continent with the hieghst deaths

select continent, MAX(cast(total_deaths as int)) as totaldeathcount 
from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers


select location date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$ 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths$
where continent is not null
order by 1,2

select * from CovidVaccinations$
order by 3,4

--looking at total population vs vaccination

select * from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date


select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac(continent, location, date, population, new_vaccinations, rollingpepolevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingpeopleVaccinated/population)*100 from PopvsVac

--Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric,
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated

from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

-- creating view to store data for later visualizations

create view percentpopulationvaccinated as  
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated