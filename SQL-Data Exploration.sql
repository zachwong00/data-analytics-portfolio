SELECT 
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
ORDER BY
  location,
  date


/* What are the likelihood of dying due to contracting Covid?
   Exploring percentages for Total Cases vs Total Deaths */
SELECT 
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS death_percentage
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  location LIKE '%Malaysia%'
ORDER BY
  location,
  date

/* What are the population percentages who got Covid19?
   Look at Total Cases vs Population */
SELECT 
  location,
  date,
  total_cases,
  population,
  (total_cases/population)*100 AS covid_percentage
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  location LIKE '%Malaysia%'
ORDER BY
  location,
  date

-- What countries have the highest infection rates compared to their population?
SELECT 
  location,
  population,
  MAX(total_cases) AS highest_infect_count,
  MAX((total_cases/population))*100 AS population_infected_percentage
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
GROUP BY
  location,
  population
ORDER BY
  population_infected_percentage DESC

-- Which countries have the highest death count per population?
SELECT 
  location,
  MAX(total_deaths) AS death_count
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL -- removing location containing regions
GROUP BY
  location
ORDER BY
  death_count DESC

/* Breaking down data by continents */

SELECT 
  location,
  MAX(total_deaths) AS death_count
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  continent IS NULL -- data file where continent rows that are null, shows data for continents as they are placed in the location columns | exp[continent: NA - location: Asia]
GROUP BY
  location
ORDER BY
  death_count DESC

-- Which continents have the highest death count per population?
SELECT 
  location,
  MAX(total_deaths) AS death_count
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL -- removing location rows containing regions
GROUP BY
  location
ORDER BY
  death_count DESC

-- Global numbers
SELECT 
  date,
  SUM(new_cases) AS total_covid_cases,
  SUM(new_deaths) AS total_covid_deaths,
  ((SUM(new_deaths))/(SUM(new_cases)))*100 AS death_percentage
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
GROUP BY
  date 
ORDER BY
  date


--overall global numbers without dates segregation
SELECT 
  SUM(new_cases) AS total_covid_cases,
  SUM(new_deaths) AS total_covid_deaths,
  ((SUM(new_deaths))/(SUM(new_cases)))*100 AS death_percentage
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` 
WHERE
  continent IS NOT NULL
ORDER BY
  total_covid_cases

-- Creating View to store data for visualization
CREATE VIEW imposing-fin-427807-p5.covid_data.vaccinatedpopulationpercent AS
  SELECT  
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location
    ORDER BY dea.location, dea.date
    ) AS rolling_new_vac
  FROM `imposing-fin-427807-p5.covid_data.covid_deaths` AS dea
  JOIN `imposing-fin-427807-p5.covid_data.covid_vaccines` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL

/* What are the total number of people in the world who are vaccinated?
   Look at Total Population vs Vaccination */
   
SELECT  
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location
    ORDER BY dea.location, dea.date
    ) AS rolling_new_vac -- breaking up the increasing new vaccinations with locations, refreshing the SUM additions
FROM `imposing-fin-427807-p5.covid_data.covid_deaths` AS dea
JOIN `imposing-fin-427807-p5.covid_data.covid_vaccines` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  dea.location,
  dea.date

-- CTE Approach
WITH Pop_vs_Vac AS (
  SELECT  
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
      PARTITION BY dea.location
      ORDER BY dea.location, dea.date
      ) AS rolling_new_vac 
  FROM `imposing-fin-427807-p5.covid_data.covid_deaths` AS dea
  JOIN `imposing-fin-427807-p5.covid_data.covid_vaccines` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
)
