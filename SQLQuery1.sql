SELECT *
FROM New_Project ..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM New_Project ..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM New_Project ..CovidDeaths$
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project ..CovidDeaths$
WHERE location LIKE '%India%' AND continent is not null
ORDER BY 1,2

Select location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From New_Project..CovidDeaths$
--Where location like '%India%'
order by 1,2

Select location, Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From New_Project..CovidDeaths$
--Where location like '%India%'
GROUP BY location, population
order by PercentPopulationInfected DESC

Select location, population, MAX(cast(total_deaths as int)) as MaxTotaldeaths
From New_Project..CovidDeaths$
--Where location like '%India%'
WHERE continent is not null
GROUP BY location, population
order by MaxTotaldeaths DESC

Select continent, SUM(cast(total_deaths as int)) as MaxTotaldeaths
From New_Project..CovidDeaths$
--Where location like '%India%'
WHERE continent is not null
GROUP BY continent
order by MaxTotaldeaths DESC

SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
    SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM New_Project..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent

SELECT * 
FROM New_Project..CovidDeaths$ dea
join New_Project..CovidVaccinations$ vac
	ON dea.location = dea.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM New_Project..CovidDeaths$ dea
join New_Project..CovidVaccinations$ vac
	ON dea.location = dea.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, COALESCE(vac.new_vaccinations, 0))) 
            OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM New_Project..CovidDeaths$ dea
    JOIN New_Project..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL and new_vaccinations is not null
)
SELECT *, 
       (RollingPeopleVaccinated * 100.0 / Population) AS VaccinationPercentage
FROM PopvsVac;


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, COALESCE(vac.new_vaccinations, 0))) 
            OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM New_Project..CovidDeaths$ dea
    JOIN New_Project..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, COALESCE(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM New_Project..CovidDeaths$ dea
JOIN New_Project..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
