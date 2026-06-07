select DISTINCT -- Remove duplicates

    employee_id,
    company_id,

    -- Trim strings
    trim(employee_first_name) as employee_first_name,
    trim(employee_contract_type) as employee_contract_type,

    -- Standarization of provinces
    {{ initcap_places('employee_address_province') }} as employee_address_province,

    -- Boolean normalization
    try_cast(trim(employee_active_status::varchar) as boolean) as employee_active_status,

    -- Date formats are already clean (Autodetected as DATE by DuckDB)
    employee_hire_date,
    created_at,
    updated_at_sys

from {{ source('raw', 'workers') }}