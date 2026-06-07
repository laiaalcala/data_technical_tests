select
    -- Transform ID to integers
    cast(campaign_id as integer) as campaign_id,
    cast(project_id as integer) as project_id,

    -- Trim strings
    trim(campaign_code) as campaign_code,
    trim(campaign_name) as campaign_name,
    trim(project_code) as project_code,
    trim(client_code) as client_code,
    trim(campaign_state) as campaign_state,

    --Boolean normalization
    try_cast(is_active as boolean) as is_active,

    total_visits_planned,
    total_pos_planned,
    visit_duration_minutes,

    -- Standardize mixed text dates into proper date type
    {{ parse_mixed_date('campaign_start_date') }} as campaign_start_date,
    {{ parse_mixed_date('campaign_end_date') }} as campaign_end_date,

    (try_cast(created_at as date))::date as created_at,
    (try_cast(updated_at_sys as date))::date as updated_at_sys

from {{ source('raw', 'campaigns') }}