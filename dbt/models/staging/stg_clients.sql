select distinct -- Drop duplicates

    client_id,
    company_id,

    -- Trim strings
    trim(client_name) as client_name,
    trim(sector) as sector,

    -- Normalize Country names
    case
        when lower(trim(country)) in ('spain') then 'España'
    end as country,

    -- date formats are already clean YYYY-MM-DD)
    (try_cast(created_at as date))::date as created_at,
    (try_cast(updated_at_sys as date))::date as updated_at_sys

from {{ source('raw', 'clients') }}