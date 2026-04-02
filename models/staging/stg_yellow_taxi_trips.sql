WITH raw_data AS (
    SELECT
        -- Identifiants
        v:VendorID::int AS vendor_id,
        v:PULocationID::int AS pickup_location_id,
        v:DOLocationID::int AS dropoff_location_id,

        -- Dates et Heures (Conversion microsecondes vers Timestamp)
        TO_TIMESTAMP(v:tpep_pickup_datetime::int / 1000000) AS pickup_datetime,
        TO_TIMESTAMP(v:tpep_dropoff_datetime::int / 1000000) AS dropoff_datetime,

        -- Métriques
        v:trip_distance::float AS trip_distance,
        v:fare_amount::float AS fare_amount,
        v:tip_amount::float AS tip_amount,
        v:total_amount::float AS total_amount
    FROM {{ source('nyc_taxi_raw', 'RAW') }}
),

final AS (
    SELECT 
        *,
        -- Calcul de durée basé sur les colonnes transformées
        DATEDIFF('minute', pickup_datetime, dropoff_datetime) AS trip_duration_minutes
    FROM raw_data
    WHERE 
        -- 1. Filtre temporel pour dégager 2007/2026
        pickup_datetime >= '2025-01-01' 
        AND pickup_datetime < '2026-01-01'
        
        -- 2. Filtres de qualité (Distance et Montant)
        AND trip_distance BETWEEN 0.1 AND 100
        AND total_amount > 0
)

SELECT * FROM final