{{ config(materialized='table') }}


WITH delays_by_origin AS(


    SELECT  
    Year,
    Month,
    DayofMonth,
    DayOfWeek,
    Origin,
    CAST(DepDelay as DECIMAL) as departure_delay
    FROM {{ ref('flights') }}
    WHERE DepDelay NOT LIKE 'NA'

)

SELECT * from delays_by_origin
