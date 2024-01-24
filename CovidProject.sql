SELECT Location, date, total_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- Looking at the Total Cases versus Total Deaths (in United States)
-- WHERE can be changed to look at other countries
-- Shows the likelihood of dying if you contract COVID in the US
-- Organized by location and date
-- At first death rates were high in the US and then dwindled down between 1 and 2 percent

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%states' AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases versus Population (in United States)
-- Shows the percentage of the population that got COVID in the US
-- Starts to approach almost 10% as 2021 progresses

SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%states' AND continent is not null
ORDER BY 1,2


-- Looking at countries with the highest infection rate compared to population
-- Data could be biased if certain countries tested more often than others
-- Andorra had the highest percentage followed by Montenegro and Czechia (low-population countries)

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionPercentage DESC


-- Looking at countries with the highest percentage of COVID deaths (per population)
-- This data could also be biased depending on what each country determined as a 'COVID Death'
-- Hungary had the highest death percentage (per population)
-- The United States had a fairly high rate
-- Considering the US is a pretty rich country, I wonder if the definition of 'COVID Death' was more broad in the United States than others

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population)*100) as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathPercentage DESC



-- Looking at deaths by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccinations
-- First joined the two separate tables
-- Then created a CTE in order to make a percent vaccinated column

With PopVsVac (Continent, Location, Date, Population, NewVaccinations, DateTotalVaccinations)
AS
(
SELECT dea.continent Continent, dea.location Location, dea.date Date, dea.population Population
, vac.new_vaccinations AS NewVaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS DateTotalVaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (DateTotalVaccinations/Population)*100 AS DatePercentVaccinated
FROM PopVsVac


