# Pizzeria-Performance-Analysis
Data Analysis with SQL and Tableau

Link to the dashboard in Tableau

https://public.tableau.com/app/profile/maria5911/viz/PizzeriaPerformanceAnalysis/Dashboard1

## Project Overview

The objective of this project was to analyze the dataset representing various operational aspects of a pizzeria for one year and make recommendations to management and owners for enhancing business performance.

## Approach

The data was analyzed using SQL for data manipulation and extractions. Subsequently, the dashboard was developed in Tableau to visualize the findings for easy interpretation by end-users.

## Data Source

The dataset for this project was provided by Maven Analytics and is available in their Data Playground section (https://www.mavenanalytics.io/data-playground).
The data was organized across four distinct files.

## Data Analysis

1.	Key Performance Indicators (KPIs) were computed, including Total Revenue, Total Order, Average Order, Total Number of Pizzas Sold, Pizza Types
2.	Sales Trends were examined to identify the best and the worst-selling pizzas in terms of quantity and revenue, sales trends by pizza size, weekdays, and peak hours.
3.	Table occupancy analysis was conducted to understand typical order sizes and table utilization efficiency throughout the day.

#### SQL Functionality
-	Queries and sub-queries
-	Joins
-	Window functions
-	Materialized views

## Dashboard Construction

All relevant resulting tables were exported to Tableau and were used to create a comprehensive dashboard. 

## Conclusions and Recommendations

The analysis identified the best and worst-selling pizzas. Thus, “The Brie Carre Pizza” is the worst selling in revenue and quantity sold. The recommendations are regarding its retention on the menu considering the cost implications since this type of pizza contains perishable ingredients used only for this single pizza type. 
The sales by size also revealed that pizzas in sizes XL and XXL are not popular, thus there is a way to make the whole menu less overloaded and decrease the choice of types and sizes.
It was determined by the analysis that the peak days of the week are Thursdays and Fridays, it may be worth optimizing staffing levels during those days. Same with the peak hours which mainly fall at lunchtime. We did not have information about the number of employees in the pizzeria, so further assessment of staffing requirements is recommended for enhanced customer service and turnover efficiency.
The table configuration analysis revealed that in many cases tables are not utilized effectively. All tables are for 4 persons; however, two-thirds of the orders are for 1 or 2 persons, which means that half of the table capacity is not used. On the other hand, the required tables are often more than the capacity, which means that during peak hours the clients have to wait for the table. The recommendations may include adjusting table configuration to better accommodate the clients, e.g. increasing the number of smaller tables (for 2 persons).
