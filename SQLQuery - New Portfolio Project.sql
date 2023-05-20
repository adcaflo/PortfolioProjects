SELECt *
FROM Portfolio_Project..CovidDeaths$
WHERE continent IS NOT NULL
order by 3, 4

--SELECT *
--FROM [Portfolio_Project]..CovidVaccinations$
--order by 3, 4


--SELECT data that we are going to be using
SELECt location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio_Project..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECt location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_Project..CovidDeaths$
WHERE location like '%peru%'AND continent IS NOT NULL
ORDER BY 1,2


--Looking at the Total cases vs Population
--Shows what percentage of population got COVID
SELECt location, date, population,total_cases, (total_cases/population)*100 AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths$
WHERE location like '%peru%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECt location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected_Percentage
FROM Portfolio_Project..CovidDeaths$
--WHERE location like '%peru%'
GROUP BY location, population
ORDER BY Population_Infected_Percentage DESC


--Showing countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths$
--WHERE location like '%peru%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


--Let`s break things down by continent

--Showing the continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths$
--WHERE location like '%peru%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


--Global numbers
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM Portfolio_Project..CovidDeaths$
--WHERE location like '%peru%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths$ AS DEA
JOIN Portfolio_Project..CovidVaccinations$ AS VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


--Use CTE
With PopvsVAC (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths$ AS DEA
JOIN Portfolio_Project..CovidVaccinations$ AS VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVAC



--Temp. Table

DROP table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths$ AS DEA
JOIN Portfolio_Project..CovidVaccinations$ AS VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view NewPercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths$ AS DEA
JOIN Portfolio_Project..CovidVaccinations$ AS VAC
ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM NewPercentPopulationVaccinated