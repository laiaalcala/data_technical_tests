select distinct -- Remove duplicates

    visit_id,
    campaign_id,
    intervention_point_id,
    
    -- Trim strings
    trim(campaign_code) as campaign_code,
    trim(project_code) as project_code,
    trim(route_code) as route_code,
    trim(visit_status) as visit_status,
    trim(visit_type) as visit_type,

    -- Numeric metrics
    intervention_point_code,
    route_id,

    -- Boolean normalization
    try_cast(trim(is_client_billable::varchar) as boolean) as is_client_billable,

    (try_cast( visit_date as date))::date as visit_date,
    visit_time,
    (try_cast(created_at as date))::date as created_at,
    (try_cast(updated_at_sys as date))::date as updated_at_sys

from {{ source('raw', 'visits') }}