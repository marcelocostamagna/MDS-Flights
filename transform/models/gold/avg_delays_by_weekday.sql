{{ config(materialized='table') }}


WITH avg_delays_by_weekday AS(


    SELECT  
    Origin as origin,
    CAST(DayOfWeek AS INT) as dayofweek,
    AVG(departure_delay) as avg_delay
    FROM {{ ref('delays') }}
    GROUP by ALL

),

avg_delays_by_weekday_name AS(
    SELECT origin,
    dayofweek,
    CASE 
        WHEN dayofweek = 1 THEN '1-Sunday'
        WHEN dayofweek = 2 THEN '2-Monday'
        WHEN dayofweek = 3 THEN '3-Tuesday'
        WHEN dayofweek = 4 THEN '4-Wednesday'
        WHEN dayofweek = 5 THEN '5-Thursday'
        WHEN dayofweek = 6 THEN '6-Friday'
        WHEN dayofweek = 7 THEN '7-Saturday'
        ELSE 'Unknown'
    END AS dayname,
    avg_delay
    FROM avg_delays_by_weekday
)


SELECT * from avg_delays_by_weekday_name
