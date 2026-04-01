SELECT
    pickup_location_id,
    distance_category,
    COUNT(*) AS total_trips,
    SUM(total_amount) AS total_revenue,
    AVG(tip_percentage) AS avg_tip_pct,
    AVG(avg_speed_mph) AS avg_velocity
FROM {{ ref('int_trip_metrics') }}
GROUP BY 1, 2