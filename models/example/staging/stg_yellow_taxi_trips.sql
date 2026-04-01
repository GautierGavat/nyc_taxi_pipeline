

WITH raw_data AS (
    SELECT * FROM {{ source('nyc_taxi_raw', 'RAW') }}
)

SELECT
    -- Identifiants
    v:VendorID::int AS vendor_id,
    v:PULocationID::int AS pickup_location_id,
    v:DOLocationID::int AS dropoff_location_id,

    -- Dates et Heures
    TO_TIMESTAMP(v:tpep_pickup_datetime::int / 1000000) AS pickup_datetime,
    TO_TIMESTAMP(v:tpep_dropoff_datetime::int / 1000000) AS dropoff_datetime,

    -- Métriques
    v:trip_distance::float AS trip_distance,
    v:fare_amount::float AS fare_amount,
    v:tip_amount::float AS tip_amount,
    v:total_amount::float AS total_amount,

    -- Calculs de base
    DATEDIFF('minute', pickup_datetime, dropoff_datetime) AS trip_duration_minutes

FROM raw_data
WHERE 
    v:trip_distance::float BETWEEN 0.1 AND 100
    AND v:total_amount::float > 0