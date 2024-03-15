{{ config(materialized='table') }}


WITH total_delays_by_origin AS(


    SELECT  
    Origin,
    SUM(departure_delay) as total_delay
    FROM {{ ref('delays') }}
    GROUP by ALL

)

SELECT * from total_delays_by_origin
