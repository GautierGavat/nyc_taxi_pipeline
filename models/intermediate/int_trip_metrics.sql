-- models/intermediate/int_trip_metrics.sql

WITH trips AS (
    SELECT * FROM {{ ref('stg_yellow_taxi_trips') }}
),

calculations AS (
    SELECT
        *,
        -- 1. Catégorisation des distances
        CASE 
            WHEN trip_distance <= 1 THEN 'Court (Local)'
            WHEN trip_distance <= 5 THEN 'Moyen (Urbain)'
            WHEN trip_distance <= 10 THEN 'Long (Inter-arrondissement)'
            ELSE 'Très Long (Aéroports/Banlieue)'
        END AS distance_category,

        -- 2. Extraction de l'heure et du type de jour
        EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
        CASE 
            WHEN DAYNAME(pickup_datetime) IN ('Sat', 'Sun') THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,

        -- 3. Périodes temporelles (Rush Hours)
        CASE 
            WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 6 AND 9 THEN 'Rush Matinal'
            WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 10 AND 15 THEN 'Journée'
            WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 16 AND 19 THEN 'Rush Soir'
            WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 20 AND 23 THEN 'Soirée'
            ELSE 'Nuit'
        END AS time_period,

        -- 4. Métriques avancées
        (tip_amount / NULLIF(fare_amount, 0)) * 100 AS tip_percentage,
        (trip_distance / NULLIF(trip_duration_minutes / 60, 0)) AS avg_speed_mph

    FROM trips
)

SELECT * FROM calculations