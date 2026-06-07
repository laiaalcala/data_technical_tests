select 

    intervention_point_id,

    -- Trim strings
    trim(intervention_point_code) as intervention_point_code,
    trim(intervention_point_name) as intervention_point_name,
    trim(intervention_point_address) as intervention_point_address,
    trim(intervention_point_locality) as intervention_point_locality,

    --Boolean normalization
    try_cast(intervention_point_is_active as boolean) as intervention_point_is_active,

    -- Standarize province
    {{ initcap_places('intervention_point_province') }} as intervention_point_province,

    -- Numerical metrics
    cast(intervention_point_postal_code as integer) as intervention_point_postal_code,
    intervention_point_latitude, --(Autodetected as DOUBLE due to real decimals)
    intervention_point_longitude, --(Autodetected as DOUBLE due to real decimals)

    -- date formats are already clean YYYY-MM-DD)
    (try_cast(created_at as date))::date as created_at,
    (try_cast(updated_at as date))::date as updated_at

from {{ source('raw', 'pos') }}

