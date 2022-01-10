SELECT *
FROM Projects..CovidDeaths
order by 3,4



--SELECT *
--FROM Projects..CovidVaccinations
--order by 3,4


-- Select Data that we are we to be using
SELECT location, date, total_cases, new_cases,total_deaths,population
FROM Projects..CovidDeaths
order by 1,2


-- Looking at total cases versus total deaths
-- Shows likelihood of you dying if you contract Covid in US
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Projects..CovidDeaths
WHERE location like '%States'
order by 1,2

-- Looking at total cases versus population
-- Shows what percentage of population contracted COVID
SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectedPercentage
FROM Projects..CovidDeaths
WHERE location like '%States'
order by 1,2


--Looking at Countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
FROM Projects..CovidDeaths
GROUP BY Location, Population
order by PopulationInfectedPercentage DESC

-- Showing Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Projects..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
order by TotalDeathCount DESC

-- Looking at the data by continent. highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Projects..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Global numbers



SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Projects..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
order by 1,2


--Join Vaccinations table
SELECT *
FROM Projects..CovidDeaths as deaths
JOIN Projects..CovidVaccinations as vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date


-- Looking at Total Population vs Vaccinations


SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(bigint,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,
	deaths.date) AS RollingVaccinationCount
FROM Projects..CovidDeaths as deaths
JOIN Projects..CovidVaccinations as vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is NOT NULL
ORDER BY 2,3


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(bigint,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,
	deaths.date) AS RollingVaccinationCount
FROM Projects..CovidDeaths as deaths
JOIN Projects..CovidVaccinations as vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinationCount/Population)*100 AS RollingVaccinationPercentage
FROM PopvsVac

-- Temp table


DROP TABLE IF EXISTS PercentagePopulationVaccinated
Create Table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO PercentagePopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(bigint,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,
	deaths.date) AS RollingVaccinationCount
FROM Projects..CovidDeaths as deaths
JOIN Projects..CovidVaccinations as vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is NOT NULL
ORDER BY 2,3

SELECT *, (RollingVaccinationCount/Population)*100 AS RollingVaccinationPercentage
FROM PercentagePopulationVaccinated



-- Creating view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(bigint,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,
	deaths.date) AS RollingVaccinationCount
FROM Projects..CovidDeaths as deaths
JOIN Projects..CovidVaccinations as vaccinations
	ON deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
WHERE deaths.continent is NOT NULL


CREATE VIEW InfectionRateUS AS
SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectedPercentage
FROM Projects..CovidDeaths
WHERE location like '%States'

SELECT *
FROM InfectionRateUS


CREATE VIEW HighestDeathCount AS
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Projects..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location


SELECT *
FROM HighestDeathCount
ORDER BY TotalDeathCount DESC