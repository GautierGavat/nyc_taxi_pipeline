{{ config(
    materialized='incremental',
    unique_key=['pickup_date', 'pickup_location_id']
) }}

SELECT
    DATE(pickup_datetime) AS pickup_date,
    pickup_location_id,
    distance_category,
    COUNT(*) AS total_trips,
    SUM(total_amount) AS total_revenue,
    AVG(tip_percentage) AS avg_tip_pct,
    AVG(avg_speed_mph) AS avg_velocity
FROM {{ ref('int_trip_metrics') }}

{% if is_incremental() %}
WHERE DATE(pickup_datetime) > (SELECT MAX(pickup_date) FROM {{ this }})
{% endif %}

GROUP BY 1, 2, 3