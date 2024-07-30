-- Updated Covid Data: 2020 to 2024 from Our World in Data Masterfile (owid)

-- Visualization 1: Global Numbers
SELECT 
  SUM(CAST(new_cases AS int)) AS total_covid_cases,  
  SUM(CAST(new_deaths AS int)) AS total_covid_deaths,
  ((SUM(new_deaths))/(SUM(new_cases)))*100 AS death_percentage
FROM 
  owid_covid_data  
WHERE
  continent <> ""
ORDER BY
  1

-- Visualization 2: Total Deaths by countries 
SELECT 
  location,
  SUM(CAST(new_deaths AS int)) as total_covid_deaths
FROM 
  owid_covid_data 
WHERE 
  continent IS "" -- NULL variant, AS FULL DATA IS located IN columns: NA + location: Asia/Europe/Oceania etc.
  AND location NOT IN ("World", "European Union", "International", "High income", "Upper middle income", "Lower middle income", "Low income") -- remove outlier groups recorded
GROUP BY 
  location 
ORDER BY 
  total_covid_deaths DESC 

-- Visualization 3: Infected Population by Countries (Mapping)
SELECT 
  location,
  population,
  MAX(CAST(total_cases AS int)) AS highest_infection_count,
  MAX((total_cases/population))*100 AS infected_population_percentage
FROM 
  owid_covid_data 
GROUP BY
  location,
  population 
ORDER BY 
  infected_population_percentage DESC
  
-- Visualization 4: Infected Population by Countries + Date (Line graphs)
SELECT 
  location,
  population,
  date,
  MAX(CAST(total_cases AS int)) AS highest_infection_count,
  MAX((total_cases/population))*100 AS infected_population_percentage
FROM
  owid_covid_data 
GROUP BY
  location,
  population,
  date 
ORDER BY 
  infected_population_percentage DESC