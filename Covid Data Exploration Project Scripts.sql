-- Selecting all data
SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total cases vs total deaths
-- Likelihood of dying if covid was contracted
SELECT location, date, total_cases, total_deaths, 
	(total_deaths::float/total_cases::float)*100 death_percentage
FROM covid_deaths
WHERE location LIKE '%States'
ORDER BY 1,2;

-- Total cases vs Population --
-- Percentage of population that has covid --
SELECT location, date, population, total_cases, 
	(total_cases::float/population::float)*100 percentage_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Countries with highest infection rate compared with population
SELECT location, population, MAX(total_cases) highest_infection, 
	MAX((total_cases::float/population::float))*100 percentage_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_population_infected DESC;

-- Countries with highest death count per population
SELECT location, MAX(total_deaths) total_death_counts
FROM covid_deaths
WHERE continent IS NOT NULL
	and total_deaths IS NOT NULL
GROUP BY location
ORDER BY total_death_counts DESC;

-- Continent with hghest death count
SELECT continent, MAX(total_deaths) total_death_counts
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_counts DESC;

SELECT location, MAX(total_deaths) total_death_counts
FROM covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_counts DESC;

-- Global numbers
SELECT SUM(new_cases) total_cases, SUM(new_deaths) total_deaths, SUM(new_deaths::FLOAT)/SUM(new_cases::FLOAT)*100 death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

SELECT *
FROM covid_vaccination

-- Total vaccination vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) OVER(Partition by dea.location 
								   Order by dea.location, dea.date) rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Creating a CTE
WITH pop_vac AS(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) OVER(Partition by dea.location 
								   Order by dea.location, dea.date) rolling_people_vaccinated
	FROM covid_deaths dea
	JOIN covid_vaccination vac
		ON dea.location = vac.location
		AND dea.date = vac. date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated::FLOAT/population::FLOAT)*100 vaccination_percantage
FROM pop_vac;

-- Creating a temp table
DROP TABLE IF EXISTS pop_vac

CREATE TEMP TABLE pop_vac 
(continent VARCHAR(255),
location VARCHAR(255),
date TIMESTAMP,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO pop_vac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) OVER(Partition by dea.location 
								   Order by dea.location, dea.date) rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 vaccination_percantage
FROM pop_vac;

-- Creating View to store data for future visualization
CREATE VIEW pops_vac AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) OVER(Partition by dea.location 
								   Order by dea.location, dea.date) rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

