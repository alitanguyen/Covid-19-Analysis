/*
COVID 19 Data Exploration 
Skills used: Joins, CTE, Temp Table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
-- ANALYSIS PER LOCATION
-- 1. Have an overall view of the dataset
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date;

-- 2. Select key variables in the dataset
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

-- 3. Calculate the COVID death rate
SELECT location, date, total_cases, total_deaths, 
		(CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(FLOAT, total_cases), 0))*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- 4. Calculate the COVID infection rate by population
SELECT location, date, population, total_cases,
(CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(FLOAT, population), 0))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- 5. Calculate the highest infection count and the highest infection rate by population
SELECT location, population, 
		MAX(CONVERT (FLOAT, total_cases)) AS highest_infection_count, 
		MAX((CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- 6. Calculate the highest death count and the highest death rate by population
SELECT location, 
		MAX(CONVERT (FLOAT, total_deaths)) AS highest_death_count,
		MAX((CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_rate DESC;

-- ANALYSIS PER CONTINENT
-- 7. Calculate the highest infection count and rate and the highest death count and rate in population
SELECT continent, 
		MAX(CONVERT(FLOAT, total_cases)) AS highest_infection_count,
		MAX(CONVERT(FLOAT, total_deaths)) AS highest_death_count,
		MAX((CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_infection_rate,
		MAX((CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_rate DESC;

-- ANALYSIS PER DAY
-- 8. Calculate the total new cases, the total new deaths and the death percentage
SELECT date, 
		SUM(CONVERT(FLOAT, new_cases)) AS total_new_cases, 
		SUM(CONVERT(FLOAT, new_deaths)) AS total_new_deaths, 
		(SUM(CONVERT(FLOAT, new_deaths))/SUM(NULLIF(CONVERT(FLOAT, new_cases),0)))*100 AS death_perc
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- ANALYSIS OVER VACCINATIONS
-- 9. Calculate the rolling count of new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- 10. Calculate the rolling vaccinations and the vaccination rate in population
-- Use CTE
WITH PopvsVac 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (CONVERT(FLOAT, rolling_vaccinations)/NULLIF((CONVERT(FLOAT, population)), 0))*100 AS vac_rate
FROM PopvsVac;

-- 11. Create TEMP TABLE
DROP TABLE IF EXISTS #Population_Vaccinated_Rate;
CREATE TABLE #Population_Vaccinated_Rate (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date NVARCHAR(255),
    population FLOAT,
    new_vaccinations FLOAT,
    rolling_vaccinations FLOAT  
);

-- Insert into TEMP TABLE
INSERT INTO #Population_Vaccinated_Rate
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations  
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Calculate vaccination rate in population
SELECT *, 
       (CONVERT(FLOAT, rolling_vaccinations) / NULLIF((CONVERT(FLOAT, population)), 0)) * 100 AS vac_rate
FROM #Population_Vaccinated_Rate;
