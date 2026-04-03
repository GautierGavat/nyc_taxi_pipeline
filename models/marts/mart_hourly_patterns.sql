-- models/marts/mart_hourly_patterns.sql

{{ config(
    materialized='incremental',
    unique_key=['pickup_date', 'pickup_hour']
) }}

SELECT
    DATE(pickup_datetime) AS pickup_date,
    pickup_hour,
    time_period,
    day_type,
    COUNT(*) AS trip_demand,
    AVG(fare_amount) AS avg_fare,
    AVG(trip_duration_minutes) AS avg_duration
FROM {{ ref('int_trip_metrics') }}

{% if is_incremental() %}
WHERE DATE(pickup_datetime) > (SELECT MAX(pickup_date) FROM {{ this }})
{% endif %}

GROUP BY 1, 2, 3, 4
ORDER BY pickup_date DESC, pickup_hour ASC