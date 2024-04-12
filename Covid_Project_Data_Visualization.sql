/*
COVID 19 Data Visualization 
Queries used for Tableau

*/

-- 1. Calculate the total new cases, the total new deaths and the death percentage worldwide
SELECT SUM(CONVERT(FLOAT, new_cases)) AS total_new_cases, 
		SUM(CONVERT(FLOAT, new_deaths)) AS total_new_deaths, 
		(SUM(CONVERT(FLOAT, new_deaths))/SUM(NULLIF(CONVERT(FLOAT, new_cases),0)))*100 AS death_perc
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL;

-- 2. Calculate the total death count per continent
SELECT continent,
		SUM(CONVERT(FLOAT, new_deaths)) AS total_death_count
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
AND location not IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY total_death_count DESC;

-- 3. Calculate the highest infection count and the highest infection rate by population
SELECT location, population, 
		MAX(CONVERT (FLOAT, total_cases)) AS highest_infection_count, 
		MAX((CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- 4. Calculate the daily highest infection count and the highest infection rate by population
SELECT location, population, date,
		MAX(CONVERT (FLOAT, total_cases)) AS highest_infection_count, 
		MAX((CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS highest_infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY highest_infection_rate DESC;
