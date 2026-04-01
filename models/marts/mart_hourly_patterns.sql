-- models/marts/mart_hourly_patterns.sql

SELECT
    pickup_hour,
    time_period,
    day_type,
    COUNT(*) AS trip_demand,
    AVG(fare_amount) AS avg_fare,
    AVG(trip_duration_minutes) AS avg_duration
FROM {{ ref('int_trip_metrics') }}
GROUP BY 1, 2, 3
ORDER BY pickup_hour