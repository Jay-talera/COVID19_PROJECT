Select * 
From CovidDeaths;

/*
Select * 
From CovidVaccinations order by 3,4;
*/


Select location,date,total_cases,new_cases,total_deaths,population
From Covid19..CovidDeaths
Order By 1,2



-- TOTAL CASES VS TOTAL DEATHS
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths,Round((total_deaths/total_cases)*100,2) as DeathPercentage
From Covid19..CovidDeaths
Where location like '%india%'
Order By 1,2



-- TOTAL CASES VS POPULATION
-- Shows percentage of population infected with covid

Select location,date,population,total_cases,(total_cases/population)*100 as covidPercentage
From Covid19..CovidDeaths
Where location like '%india%'
Order By 1,2


-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location, population , MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
group by location, population
order by  PercentPopulationInfected desc


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
group by location
order by  TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
group by continent
order by  TotalDeathCount desc 


-- Daily GLobal Numbers 

Select date, SUM(new_cases) as new_cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast (new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
group by date
order by 1,2



-- GLOBAL OVERALL

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
order by 1,2



--  TOTAL POPULATION VS TOTAL VACCINATION
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac(continent, location, date, population,new_vaccination, rollingpeoplevaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100 as vaccinatedPercentage
from popvsvac 
order by 2,3





-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create table #percentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
--where cd.continent is not null


select *, (rollingpeoplevaccinated/population)*100 as vaccinatedPercentage
from #percentPopulationVaccinated 
order by 2,3





-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

--DROP View IF EXISTS PercentPopulationVaccinated

CREATE View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location , cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
where cd.continent is not null


select * 
from PercentPopulationVaccinated