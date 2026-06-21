/* ============================================================
   PROJECT: Industry Carbon Emissions & Sustainability Analysis
   TOOL: Microsoft SQL Server
   DATASET: 50 companies x 365 days (2024), 5 industry sectors
   ============================================================ */


/* ---------------------------------------
   STEP 1: DATABASE & TABLE SETUP
   --------------------------------------- */

CREATE DATABASE IndustryCarbonEmissionsDB;
GO
USE IndustryCarbonEmissionsDB;
GO

CREATE TABLE CarbonEmissions (
    Company_ID                          VARCHAR(10),
    EmissionDate                        DATE,
    Sector                              VARCHAR(50),
    Total_Energy_Consumption_kWh        FLOAT,
    Renewable_Energy_Consumption_kWh    FLOAT,
    NonRenewable_Energy_Consumption_kWh FLOAT,
    Production_Output_Units             FLOAT,
    Supply_Chain_Transport_km           FLOAT,
    Supply_Chain_Transport_Mode         VARCHAR(20),
    Raw_Material_Usage_kg               FLOAT,
    Carbon_Emission_tCO2e               FLOAT,
    Energy_Cost_USD                     FLOAT,
    Carbon_Tax_USD                      FLOAT,
    Process_Efficiency_Percent          FLOAT,
    Employment_Count                    INT,
    Public_Acceptance_Index             FLOAT,
    Carbon_Reduction_Strategy           VARCHAR(50),
    Strategy_Implementation_Cost_USD    FLOAT,
    Expected_Carbon_Reduction_Percent   FLOAT,
    Expected_Renewable_Share_Percent    FLOAT,
    Social_Impact_Score                 FLOAT,
    Industry_Sectors                    VARCHAR(50)  
    -- NOTE: Industry_Sectors is randomly distributed across Sector
    -- (verified during data validation) and is therefore excluded
    -- from all analysis below.
);
GO


/* ---------------------------------------
   STEP 2: DATA VALIDATION
   --------------------------------------- */

-- Row count check (expect 18,250 = 50 companies x 365 days)
SELECT COUNT(*) AS Total_Rows FROM CarbonEmissions;

-- Duplicate check (one row per company per day expected)
SELECT Company_ID, EmissionDate, COUNT(*) AS Cnt
FROM CarbonEmissions
GROUP BY Company_ID, EmissionDate
HAVING COUNT(*) > 1;

-- Data integrity check: Renewable + NonRenewable should equal Total
SELECT COUNT(*) AS Mismatches
FROM CarbonEmissions
WHERE ABS((Renewable_Energy_Consumption_kWh + NonRenewable_Energy_Consumption_kWh) 
          - Total_Energy_Consumption_kWh) > 0.01;

-- Confirms Industry_Sectors has no real relationship to Sector
SELECT Sector, Industry_Sectors, COUNT(*) AS Cnt
FROM CarbonEmissions
GROUP BY Sector, Industry_Sectors
ORDER BY Sector, Cnt DESC;


/* ============================================================
   THEME A: EMISSION FOOTPRINT & RANKING
   ============================================================ */

-- Q1. Which sector has the highest total and average daily emissions?
SELECT Sector,
       SUM(Carbon_Emission_tCO2e) AS Total_Emissions,
       AVG(Carbon_Emission_tCO2e) AS Avg_Daily_Emissions
FROM CarbonEmissions
GROUP BY Sector
ORDER BY Total_Emissions DESC;


-- Q2. Top 10 companies by total annual emissions
SELECT TOP 10 Company_ID, Sector, SUM(Carbon_Emission_tCO2e) AS Total_Emissions
FROM CarbonEmissions
GROUP BY Company_ID, Sector
ORDER BY Total_Emissions DESC;


-- Q3. Rank companies within their own sector by emissions
SELECT Company_ID, Sector,
       SUM(Carbon_Emission_tCO2e) AS Total_Emissions,
       RANK() OVER (PARTITION BY Sector ORDER BY SUM(Carbon_Emission_tCO2e) DESC) AS Rank_In_Sector
FROM CarbonEmissions
GROUP BY Company_ID, Sector
ORDER BY Sector, Rank_In_Sector;


/* ============================================================
   THEME B: ENERGY EFFICIENCY & EMISSION INTENSITY
   ============================================================ */

-- Q4. Emission intensity: tCO2e emitted per unit of production output
SELECT Company_ID, Sector,
       SUM(Carbon_Emission_tCO2e) AS Total_Emissions,
       SUM(Production_Output_Units) AS Total_Output,
       ROUND(SUM(Carbon_Emission_tCO2e) / NULLIF(SUM(Production_Output_Units), 0), 4) AS Emission_Per_Unit_Output
FROM CarbonEmissions
GROUP BY Company_ID, Sector
ORDER BY Emission_Per_Unit_Output DESC;


-- Q5. Renewable energy adoption rate by sector
SELECT Sector,
       ROUND(SUM(Renewable_Energy_Consumption_kWh) * 100.0 / SUM(Total_Energy_Consumption_kWh), 2) AS Renewable_Pct
FROM CarbonEmissions
GROUP BY Sector
ORDER BY Renewable_Pct DESC;


-- Q6. Process efficiency banding vs average emissions
SELECT 
    CASE 
        WHEN Process_Efficiency_Percent < 50 THEN 'Low Efficiency (<50%)'
        WHEN Process_Efficiency_Percent BETWEEN 50 AND 75 THEN 'Medium Efficiency (50-75%)'
        ELSE 'High Efficiency (>75%)'
    END AS Efficiency_Band,
    AVG(Carbon_Emission_tCO2e) AS Avg_Emissions
FROM CarbonEmissions
GROUP BY 
    CASE 
        WHEN Process_Efficiency_Percent < 50 THEN 'Low Efficiency (<50%)'
        WHEN Process_Efficiency_Percent BETWEEN 50 AND 75 THEN 'Medium Efficiency (50-75%)'
        ELSE 'High Efficiency (>75%)'
    END
ORDER BY Avg_Emissions DESC;


/* ============================================================
   THEME C: TIME TRENDS
   ============================================================ */

-- Q7. Monthly emission trend across the year
SELECT FORMAT(EmissionDate, 'yyyy-MM') AS Month, SUM(Carbon_Emission_tCO2e) AS Monthly_Emissions
FROM CarbonEmissions
GROUP BY FORMAT(EmissionDate, 'yyyy-MM')
ORDER BY Month;


-- Q8. Month-over-month % change in emissions
WITH MonthlyTotals AS (
    SELECT FORMAT(EmissionDate, 'yyyy-MM') AS Month, SUM(Carbon_Emission_tCO2e) AS Total_Emissions
    FROM CarbonEmissions
    GROUP BY FORMAT(EmissionDate, 'yyyy-MM')
)
SELECT Month, Total_Emissions,
       LAG(Total_Emissions) OVER (ORDER BY Month) AS Prev_Month,
       ROUND((Total_Emissions - LAG(Total_Emissions) OVER (ORDER BY Month)) * 100.0 
             / LAG(Total_Emissions) OVER (ORDER BY Month), 2) AS Pct_Change
FROM MonthlyTotals
ORDER BY Month;


/* ============================================================
   THEME D: COST & STRATEGY EFFECTIVENESS
   ============================================================ */

-- Q9.. Strategy adoption, average emissions, and cost
SELECT Carbon_Reduction_Strategy,
       COUNT(DISTINCT Company_ID) AS Companies_Using,
       AVG(Carbon_Emission_tCO2e) AS Avg_Emissions,
       AVG(Strategy_Implementation_Cost_USD) AS Avg_Implementation_Cost,
       AVG(Expected_Carbon_Reduction_Percent) AS Avg_Expected_Reduction_Pct
FROM CarbonEmissions
GROUP BY Carbon_Reduction_Strategy
ORDER BY Avg_Emissions ASC;
