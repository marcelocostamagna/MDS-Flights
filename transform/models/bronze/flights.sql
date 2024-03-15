{{ config(materialized='table') }}

WITH flights_raw AS (

    {#-
    First read all rows from  raw csv and remove metadata
    #}

    SELECT *
    EXCLUDE (_sdc_batched_at, _sdc_deleted_at, _sdc_extra, _sdc_extracted_at, _sdc_source_bucket, _sdc_source_file, _sdc_source_lineno)
    FROM {{ source( 'flights_db', 'flights_raw' )}}
    
),

unique_flights as (

    SELECT DISTINCT
    *
    FROM flights_raw 

)

SELECT * from unique_flights 