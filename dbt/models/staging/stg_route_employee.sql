select
    
    route_employee_id,
    route_id,
    employee_id,

    -- Boolean normalization 
    try_cast(trim(main_employee::varchar) as boolean) as main_employee,

    -- Numerical metrics (Autodetected as DOUBLE due to real decimals)
    ip_percentage,
    

    -- Date formats are already clean (Autodetected as DATE by DuckDB)
    created_at,
    updated_at,
    deleted_at

from {{ source('raw', 'route_employee') }}