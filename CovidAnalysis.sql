CREATE DATABASE db1;


USE db1;


#Creating CovidDeath Table
CREATE TABLE c_death
(
	iso_code VARCHAR(255),
    continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population DOUBLE,
    total_cases DOUBLE,
	new_cases DOUBLE,
    new_cases_smoothed DOUBLE,
    total_deaths DOUBLE,
    new_deaths DOUBLE,
    new_deaths_smoothed DOUBLE,
	total_cases_per_million DOUBLE,
	new_cases_per_million DOUBLE,
	new_cases_smoothed_per_million DOUBLE,
	total_deaths_per_million DOUBLE,
	new_deaths_per_million DOUBLE,
	new_deaths_smoothed_per_million DOUBLE,
	reproduction_rate DOUBLE,
	icu_patients DOUBLE,
	icu_patients_per_million DOUBLE,
	hosp_patients DOUBLE,
	hosp_patients_per_million DOUBLE,
	weekly_icu_admissions DOUBLE,
	weekly_icu_admissions_per_million DOUBLE,
	weekly_hosp_admissions DOUBLE,
	weekly_hosp_admissions_per_million DOUBLE
);


ALTER TABLE c_death
MODIFY COLUMN new_cases_smoothed DECIMAL;


#Importing CovidDeath table
LOAD DATA INFILE "D:/Users/pshab/Downloads/SQL/CovidDeaths.csv"
IGNORE INTO TABLE C_DEATH 
FIELDS TERMINATED BY ','
TERMINATED BY '"'
TERMINATED BY ','
LINES TERMINATED BY '\n'
TERMINATED BY '\r'
IGNORE 1 ROWS;


SELECT * FROM c_death;


#Creating CovidVaccine table
CREATE TABLE c_vaccine
(
    iso_code VARCHAR(255),
    continent VARCHAR(255),	
    location VARCHAR(255),	
    date DATE,	
    new_tests DOUBLE,	
    total_tests	DOUBLE,
    total_tests_per_thousand DOUBLE,
    new_tests_per_thousand DOUBLE,
    new_tests_smoothed DOUBLE,
    new_tests_smoothed_per_thousand DOUBLE,
    positive_rate DOUBLE,
    tests_per_case DOUBLE,
    tests_units DOUBLE,
    total_vaccinations DOUBLE,	
    people_vaccinated DOUBLE,
    people_fully_vaccinated	DOUBLE,
    new_vaccinations DOUBLE,
    new_vaccinations_smoothed DOUBLE,
    total_vaccinations_per_hundred DOUBLE,
    people_vaccinated_per_hundred DOUBLE,
    people_fully_vaccinated_per_hundred	DOUBLE,
    new_vaccinations_smoothed_per_million DOUBLE,
    stringency_index DOUBLE,
    population_density DOUBLE,
    median_age DOUBLE,
    aged_65_older DOUBLE,
    aged_70_older DOUBLE,
    gdp_per_capita DOUBLE,
    extreme_poverty DOUBLE,
    cardiovasc_death_rate DOUBLE,	
    diabetes_prevalence DOUBLE,
    female_smokers DOUBLE,
    male_smokers DOUBLE,
    handwashing_facilities DOUBLE,
    hospital_beds_per_thousand DOUBLE,
    life_expectancy	DOUBLE,
    human_development_index DOUBLE
);


#Importing CovidVaccine Table
LOAD DATA INFILE "D:/Users/pshab/Downloads/SQL/CovidVaccinations.csv"
IGNORE INTO TABLE C_VACCINE 
FIELDS TERMINATED BY ','
TERMINATED BY '"'
TERMINATED BY ','
LINES TERMINATED BY '\n'
TERMINATED BY '\r'
IGNORE 1 ROWS;


SELECT * FROM c_vaccine;


SELECT *
FROM c_death
WHERE continent IS NOT NULL
ORDER BY 3,4;


#FINDING DEATH PERCENTAGE


SELECT location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM c_death
WHERE location != 'World'
AND continent IS NOT NULL
ORDER BY 1,2;


#FINDING HIGHEST INFECTED LOCATIONS

SELECT location, MAX(total_deaths) AS HighestInfected, MAX((total_cases/population)*100) AS InfectedPercent
FROM c_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercent DESC;


SELECT a.location, MAX(a.total_vaccinations), MAX(b.total_deaths) AS HighestInfected, MAX(a.people_vaccinated) AS HighestVaccinated, MAX((a.people_vaccinated/b.population)*100) AS VaccinatedPercent, MAX((b.total_cases/b.population)*100) AS InfectedPercent
FROM c_vaccine a, c_death b
WHERE a.continent IS NOT NULL
AND b.continent IS NOT NULL
AND a.location=b.location
AND a.iso_code=b.iso_code
AND a.date=b.date
GROUP BY location, population
ORDER BY VaccinatedPercent ASC;




#To find the number of new COVID-19 cases and deaths per day for a specific continent
SELECT date, new_cases, new_deaths, location
FROM c_death
WHERE continent = 'Asia'
ORDER BY date;


#To find the total number of COVID-19 cases and deaths for each location in c_death table
SELECT location, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM c_death
GROUP BY location;


#To find the countries with the highest total vaccinations per hundred people in c_vaccine table
SELECT location, total_vaccinations_per_hundred
FROM c_vaccine
ORDER BY total_vaccinations_per_hundred DESC;
LIMIT 10;


#To find the average number of new COVID-19 cases per day for each continent in c_death table
SELECT continent, AVG(new_cases) AS avg_new_cases
FROM c_death
WHERE continent IS NOT NULL
GROUP BY continent;


#To find the countries with the highest and lowest positive rate (the percentage of positive COVID-19 tests out of all tests conducted) in c_vaccine table:
SELECT location, MAX(positive_rate) AS HighestPositiveRate, MIN(positive_rate) AS LowestPositiveRate
FROM c_vaccine
WHERE positive_rate IS NOT NULL
GROUP BY location
ORDER BY HighestPositiveRate DESC;


#To find the average number of ICU patients per million people in each continent in c_death table:
SELECT continent, AVG(icu_patients_per_million) as avg_icu_patients_per_million
FROM c_death
GROUP BY continent;


#To find the correlation between the number of hospital beds per thousand people and the total number of COVID-19 deaths per million people in c_death table:
SELECT b.hospital_beds_per_thousand, a.total_deaths_per_million
FROM c_death a, c_vaccine b
WHERE a.location = b.location AND a.date = b.date
AND b.hospital_beds_per_thousand != 0 
AND a.total_deaths_per_million != 0;


#To find the average number of new COVID-19 tests conducted per day in the past week in each continent in c_vaccine table:
SELECT continent, AVG(new_tests) as avg_new_tests_last_week
FROM c_vaccine
WHERE date >= DATEADD(day, -7, GETDATE()) -- assuming current date is used for the query
GROUP BY continent;


#To find the total number of COVID-19 deaths and the total number of COVID-19 vaccinations administered in each country as of the latest date available:
SELECT a.location, a.total_deaths, b.total_vaccinations
FROM c_death a, c_vaccine b
WHERE a.location = b.location 
AND a.date = b.date
AND a.total_deaths !=0 AND b.total_vaccinations !=0
ORDER BY a.location ASC;


#To find the correlation between the total number of COVID-19 vaccinations administered per hundred people and the total number of COVID-19 deaths per million people in each country:
SELECT a.location, b.total_vaccinations_per_hundred, a.total_deaths_per_million
FROM c_death a, c_vaccine b
WHERE a.location = b.location AND a.date = b.date
AND a.total_deaths_per_million !=0 
AND b.total_vaccinations_per_hundred !=0
ORDER BY a.location ASC;
