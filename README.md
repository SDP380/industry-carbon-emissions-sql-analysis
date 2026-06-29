# industry-carbon-emissions-sql-analysis
 Analyzing daily operational, energy, and emissions data across 50 companies and 5 industry sectors using Microsoft SQL Server to uncover emission drivers, strategy effectiveness, and efficiency patterns.

 Dataset:
Source: Kaggle — Industry Carbon Emissions dataset
Grain: One row per company, per day
Size: 18,250 rows (50 companies x 365 days, full year 2024)
Key fields: energy consumption (total/renewable/non-renewable), production output, supply chain transport, carbon emissions, energy & carbon tax costs, process efficiency, employment, ESG-style scores, and carbon reduction strategy adopted

Tools Used:
Microsoft SQL Server (T-SQL)
SSMS for query execution

Project Workflow:
Database & table setup — created a typed SQL Server table matching the dataset schema
Data validation — checked row counts, duplicates, null values, and cross-column consistency
Exploratory analysis — 10 SQL queries across 4 themes, using aggregation, window functions, conditional logic, and time-series comparison
Insights documentation — summarized findings

Data Validation:
Before analysis, the dataset was validated to confirm it was clean and reliable:
Row count- 18,250 (matches expected 50 companies x 365 days)
Failed type conversions- 0
Duplicate records (Company_ID + Date)- 0
Renewable + Non-Renewable = Total Energy- Confirmed, 0 mismatches
Date range- 2024-01-01 to 2024-12-30

Analysis Themes & Questions:

Theme A — Emission Footprint & Ranking
Which sector has the highest total and average daily emissions?
Top 10 companies by total annual emissions
Rank companies within their own sector by emissions (window function)

Theme B — Energy Efficiency & Emission Intensity
4. Emission intensity — tCO2e emitted per unit of production output
5. Renewable energy adoption rate by sector
6. Process efficiency banding vs. average emissions

Theme C — Time Trends
7. Monthly emission trend across the year
8. Month-over-month % change in emissions (window function)

Theme D — Cost & Strategy Effectiveness
9. Carbon reduction strategy adoption, average emissions, and implementation cost

Key Insights:
Total emissions are driven mainly by company count per sector, not sector type. Average daily emissions per record are nearly identical across all 5 sectors (~32.2–32.5 tCO2e), even though Manufacturing has the highest total (more companies in that sector).
Emission intensity (emissions per unit of output) is tightly clustered (0.0057–0.0062) across all companies, indicating emissions scale roughly linearly with production output rather than varying due to company-specific inefficiency.
No strong seasonal pattern was found in monthly emissions across 2024- month-over-month changes fluctuate without a sustained directional trend.
Renewable Adoption is the standout strategy, it has both the lowest average implementation cost and the lowest average emissions among the four strategies, making it the strongest combination of cost and impact in this dataset, although the margin over other strategies is modest.

SQL Concepts Demonstrated:
Aggregation (GROUP BY, SUM, AVG, COUNT)
Window functions (RANK() OVER (PARTITION BY ...), LAG() OVER (ORDER BY ...))
Common Table Expressions (CTEs)
Conditional logic (CASE WHEN) for bucketing continuous data
Derived/calculated metrics (ratio-based intensity measures)
Data validation and integrity-check queries

Files:
industry_carbon_emissions_analysis_1.sql — full script: database/table creation, validation queries, and all 10 analysis queries
screenshots/ — query outputs and validation results


 



 
