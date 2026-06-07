select
    
    route_id,
    campaign_id,

    -- Trim strings 
    trim(route_code) as route_code,
    trim(route_name) as route_name,
    trim(campaign_code) as campaign_code,
    trim(route_status) as route_status,
    trim(delegation_code) as delegation_code,

    -- Boolean normalization 
    try_cast(trim(recall_mail_sent::varchar) as boolean) as recall_mail_sent,

    -- Date formats are already clean (Autodetected as DATE by DuckDB)
    route_start_date,
    route_end_date,
    created_at,
    updated_at_sys

from {{ source('raw', 'routes') }}