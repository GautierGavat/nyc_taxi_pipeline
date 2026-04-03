-- models/marts/mart_daily_summary.sql

{{ config(
    materialized='incremental',
    unique_key='pickup_date'
) }}

SELECT
    DATE(pickup_datetime) AS pickup_date,
    COUNT(*) AS total_trips,
    SUM(total_amount) AS total_revenue,
    AVG(trip_distance) AS avg_distance,
    AVG(trip_duration_minutes) AS avg_duration_minutes
FROM {{ ref('stg_yellow_taxi_trips') }}

{% if is_incremental() %}
WHERE DATE(pickup_datetime) > (SELECT MAX(pickup_date) FROM {{ this }})
{% endif %}

GROUP BY 1
ORDER BY 1 DESC