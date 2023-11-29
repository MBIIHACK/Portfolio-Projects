select*
from PORTFOLIOPROJECT..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PORTFOLIOPROJECT..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIOPROJECT..CovidDeaths
order by 1,2

--total cases VS total deaths in a country

select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DEATHSPERCENTAGE
from PORTFOLIOPROJECT..CovidDeaths
WHERE location like '%states%'
order by 1,2

--total cases VS population in a country

select location, date, total_cases, population, (total_cases/ population)*100 AS casesPercentage
from PORTFOLIOPROJECT..CovidDeaths
WHERE location like '%algeria%'
order by 1,2

--countries with highest infection rate

select location, max (total_cases) as highestinfectioncount, population, max (total_cases/ population)*100 AS casesPercentage
from PORTFOLIOPROJECT..CovidDeaths
group by location, population
order by casesPercentage desc


--countries with highest ideaths per population

select location, max (cast(total_deaths as int)) as highestDeathscount
from PORTFOLIOPROJECT..CovidDeaths
where continent is not null
group by location
order by highestDeathscount desc



--highest ideaths per continent

select location, max (cast(total_deaths as int)) as highestDeathscount
from PORTFOLIOPROJECT..CovidDeaths
where continent is null
group by location
order by highestDeathscount desc

--global numbers

select  sum (total_cases) as totalcases, sum(cast(total_deaths as int)) as totaldeaths, sum(cast(total_deaths as int))/sum(total_cases)*100 AS DEATHSPERCENTAGE
--total_deaths, (total_deaths/ total_cases)*100 AS DEATHSPERCENTAGE
from PORTFOLIOPROJECT..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1,2


select *
from PORTFOLIOPROJECT..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date

--total population vs total vaccinations

select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from PORTFOLIOPROJECT..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

WITH POPVAC (continent, location, date, population,new_vaccinations, rollingvaccinations) 
as
(
select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from PORTFOLIOPROJECT..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
)
select *, (rollingvaccinations/ population)*100
from popvac


--temp table

drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from PORTFOLIOPROJECT..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

select *, (rollingvaccinations/ population)*100
from #percentpopulationvaccinated


--create view to store data for later visualisation

create view percentpopulationvaccinations as
select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from PORTFOLIOPROJECT..CovidDeaths dea
join portfolioproject..covidvaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
 
 select*
 from percentpopulationvaccinations