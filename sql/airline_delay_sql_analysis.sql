
 =====================================================
-- Airline Delay Pattern Analysis — 2024
-- SQL Analysis Script (Phase 4)
-- Database: airline_db | Table: flights_2024
-- =====================================================
-- Create database
CREATE DATABASE airline_db;


USE airline_db;

CREATE TABLE flights_2024 (
    year                INT,
    month               INT,
    day_of_month        INT,
    day_of_week         INT,
    fl_date             DATE,
    op_unique_carrier   VARCHAR(10),
    op_carrier_fl_num   INT,
    origin              VARCHAR(10),
    origin_city_name    VARCHAR(100),
    origin_state_nm     VARCHAR(50),
    dest                VARCHAR(10),
    dest_city_name      VARCHAR(100),
    dest_state_nm       VARCHAR(50),
    crs_dep_time        FLOAT,
    dep_time            FLOAT,
    dep_delay           FLOAT,
    taxi_out            FLOAT,
    wheels_off          FLOAT,
    wheels_on           FLOAT,
    taxi_in             FLOAT,
    crs_arr_time        FLOAT,
    arr_time            FLOAT,
    arr_delay           FLOAT,
    cancelled           INT,
    cancellation_code   VARCHAR(5),
    diverted            INT,
    crs_elapsed_time    FLOAT,
    actual_elapsed_time FLOAT,
    air_time            FLOAT,
    distance            FLOAT,
    carrier_delay       FLOAT,
    weather_delay       FLOAT,
    nas_delay           FLOAT,
    security_delay      FLOAT,
    late_aircraft_delay FLOAT,
    month_name          VARCHAR(20),
    day_name            VARCHAR(20),
    quarter             INT,
    total_delay         FLOAT,
    is_delayed          INT,
    delay_severity      VARCHAR(20),
    route               VARCHAR(20)
);

TRUNCATE TABLE flights_2024;
SET SESSION sql_mode = '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/flight_data_cleaned.csv'
INTO TABLE flights_2024
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM flights_2024;
SELECT 
    SUM(is_delayed) AS delayed_flights,
    SUM(cancelled) AS cancelled_flights
FROM flights_2024;

SELECT 
    op_unique_carrier AS airline,
    COUNT(*) AS total_flights,
    SUM(CASE WHEN is_delayed = 0 AND cancelled = 0 THEN 1 ELSE 0 END) AS on_time_flights,
    ROUND(SUM(CASE WHEN is_delayed = 0 AND cancelled = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM flights_2024
GROUP BY op_unique_carrier
ORDER BY on_time_pct DESC;

SELECT 
    route,
    COUNT(*) AS total_flights,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_flights
FROM flights_2024
WHERE cancelled = 0
GROUP BY route
HAVING COUNT(*) >= 50
ORDER BY avg_arr_delay DESC
LIMIT 10;

SELECT 
    'Carrier' AS delay_cause, SUM(carrier_delay) AS total_minutes FROM flights_2024
UNION ALL
SELECT 'Weather', SUM(weather_delay) FROM flights_2024
UNION ALL
SELECT 'NAS', SUM(nas_delay) FROM flights_2024
UNION ALL
SELECT 'Security', SUM(security_delay) FROM flights_2024
UNION ALL
SELECT 'Late Aircraft', SUM(late_aircraft_delay) FROM flights_2024
ORDER BY total_minutes DESC;

SELECT 
    month,
    month_name,
    COUNT(*) AS total_flights,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_flights,
    ROUND(SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay
FROM flights_2024
WHERE cancelled = 0
GROUP BY month, month_name
ORDER BY month;

SELECT 
    origin AS airport,
    origin_city_name AS city,
    COUNT(*) AS total_departures,
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_flights
FROM flights_2024
WHERE cancelled = 0
GROUP BY origin, origin_city_name
HAVING COUNT(*) >= 100
ORDER BY avg_dep_delay DESC
LIMIT 10;

SELECT 
    op_unique_carrier AS airline,
    COUNT(*) AS total_flights,
    SUM(cancelled) AS cancelled_flights,
    ROUND(SUM(cancelled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM flights_2024
GROUP BY op_unique_carrier
ORDER BY cancellation_rate_pct DESC;

SELECT 
    op_unique_carrier AS airline,
    COUNT(*) AS total_flights,
    ROUND(SUM(CASE WHEN is_delayed = 0 AND cancelled = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_pct,
    ROUND(SUM(cancelled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay
FROM flights_2024
GROUP BY op_unique_carrier
ORDER BY on_time_pct DESC, cancellation_rate_pct ASC
LIMIT 5;

WITH airport_stats AS (
    SELECT 
        origin AS airport,
        COUNT(*) AS total_departures,
        ROUND(AVG(dep_delay), 2) AS avg_dep_delay
    FROM flights_2024
    WHERE cancelled = 0
    GROUP BY origin
)
SELECT 
    airport,
    total_departures,
    avg_dep_delay,
    RANK() OVER (ORDER BY total_departures DESC) AS volume_rank,
    RANK() OVER (ORDER BY avg_dep_delay DESC) AS delay_rank
FROM airport_stats
ORDER BY total_departures DESC
LIMIT 15;

SELECT 
    day_of_week,
    day_name,
    COUNT(*) AS total_flights,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_flights,
    ROUND(SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay
FROM flights_2024
WHERE cancelled = 0
GROUP BY day_of_week, day_name
ORDER BY day_of_week;

SELECT
    COUNT(*) AS total_flights,
    SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) AS delayed_flights,
    SUM(cancelled) AS cancelled_flights,
    SUM(CASE WHEN is_delayed = 0 AND cancelled = 0 THEN 1 ELSE 0 END) AS on_time_flights,
    ROUND(SUM(CASE WHEN is_delayed = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate_pct,
    ROUND(SUM(cancelled) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(AVG(arr_delay), 2) AS avg_arr_delay,
    ROUND(AVG(dep_delay), 2) AS avg_dep_delay
FROM flights_2024;

-- =====================================================
-- SUPPLEMENTARY: SQL View created during Power BI Phase
-- (Used to resolve Top N filtering issue for "Top 10 Most 
-- Delayed Routes" table visual — applies the same 
-- min-50-flights threshold as Query 2 above, exposed as a 
-- queryable view for direct Power BI import)
-- =====================================================
USE airline_db;

CREATE OR REPLACE VIEW routes_50_plus AS
SELECT
    route,
    AVG(arr_delay) AS avg_arr_delay,
    COUNT(*) AS total_flights
FROM flights_2024
GROUP BY route
HAVING COUNT(*) >= 50
ORDER BY avg_arr_delay DESC;

SELECT *
FROM routes_50_plus
LIMIT 10;