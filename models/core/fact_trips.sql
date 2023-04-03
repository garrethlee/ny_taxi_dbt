{{ config(materialized='table') }}

with green_data as (
    select 
        *,
        'Green' as service_type
    from {{ ref('green_taxi_sql')}}
),

yellow_data as (
    select 
        *,
        'Yellow' as service_type
    from {{ ref('yellow_taxi_sql')}}
),

trips_unioned as (
    select * from green_data
    union all
    select * from yellow_data
),

dim_zones as (
    select *
    from {{ ref('dim_zones' )}}
    where borough != 'Unknown'
)

select 
    trips_unioned.tripid, 
    trips_unioned.vendorid, 
    trips_unioned.service_type,
    trips_unioned.ratecodeid, 
    trips_unioned.pickup_locationid, 
    pickup.borough as pickup_borough, 
    pickup.zone as pickup_zone, 
    trips_unioned.dropoff_locationid,
    dropoff.borough as dropoff_borough, 
    dropoff.zone as dropoff_zone,  
    trips_unioned.pickup_datetime, 
    trips_unioned.dropoff_datetime, 
    trips_unioned.store_and_fwd_flag, 
    trips_unioned.passenger_count, 
    trips_unioned.trip_distance, 
    trips_unioned.fare_amount, 
    trips_unioned.extra, 
    trips_unioned.mta_tax, 
    trips_unioned.tip_amount, 
    trips_unioned.tolls_amount, 
    trips_unioned.improvement_surcharge, 
    trips_unioned.total_amount, 
    trips_unioned.payment_type, 
    trips_unioned.payment_description, 
    trips_unioned.congestion_surcharge
    from trips_unioned 
    inner join dim_zones pickup 
    on pickup.location_id = trips_unioned.pickup_locationid -- for pickup
    inner join dim_zones dropoff 
    on dropoff.location_id = trips_unioned.dropoff_locationid -- for dropoff

{% if var('is_test', default = true) %}

limit 100

{% endif %}