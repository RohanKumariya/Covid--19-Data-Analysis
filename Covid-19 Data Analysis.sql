--Basic Select to get an Understanging of data
select * from [dbo].[covid_deaths$]
order by 3,4

select * from [dbo].[covid_vaccinations$]
order by 3,4

select location,date, total_cases, new_cases, total_deaths, population 
from [dbo].[covid_deaths$]
order by 1,2


--total cases vs total_deaths shows likelihood of dying if contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from [dbo].[covid_deaths$]
where location like 'India'
order by 1,2

--total cases vs population
select location,date, total_cases, population, (total_cases/population)* 100 as ContractPercentage
from [dbo].[covid_deaths$]
where location like 'India'
order by 1,2

-- COuntries with highest infection rate compare to population
select location, max(total_cases) as highesinfection, population, max((total_cases/population)* 100) as popinfected
from [dbo].[covid_deaths$]
group by location, population
--where location like 'India'
order by popinfected desc


-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeath
from [dbo].[covid_deaths$]
where continent is not null
group by location
--where location like 'India'
order by totaldeath desc

--breaking down by continent
select continent, max(cast(total_deaths as int)) as totaldeath
from [dbo].[covid_deaths$]
WHERE continent	is null
group by continent
--where location like 'India'
order by totaldeath desc


-- Global Numbers
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as deathpercentage
from [dbo].[covid_deaths$]
where continent is not null
order by 1,2

-- Total Population Vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population, [new_vaccinations], sum(cast([new_vaccinations] as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinate from 
[dbo].[covid_vaccinations$] dea
Join [dbo].[covid_deaths$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


with popvsvacs (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, [new_vaccinations], sum(cast([new_vaccinations] as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinate from 
[dbo].[covid_vaccinations$] dea
Join [dbo].[covid_deaths$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 from popvsvacs


-- Temp Table 
Create Table #PercenPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
[new_vaccinations] numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercenPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, [new_vaccinations], sum(cast([new_vaccinations] as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinate from 
[dbo].[covid_vaccinations$] dea
Join [dbo].[covid_deaths$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercenPopulationVaccinated

--Creating View
Create View PercenPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, [new_vaccinations], sum(cast([new_vaccinations] as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinate from 
[dbo].[covid_vaccinations$] dea
Join [dbo].[covid_deaths$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- View Death_Percentage  
Create view Death_Percentage as
select location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from [dbo].[covid_deaths$]
where location like 'India'
--order by 1,2

-- View CotractPercentage
Create View Contract_Percentage as
select location,date, total_cases, population, (total_cases/population)* 100 as ContractPercentage
from [dbo].[covid_deaths$]
where location like 'India'
--order by 1,2


-- View Countries with Most Affected 
Create View Countries_Most_Affected as
select location, max(total_cases) as highesinfection, population, max((total_cases/population)* 100) as popinfected
from [dbo].[covid_deaths$]
group by location, population
--where location like 'India'
--order by popinfected desc