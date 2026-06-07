
select
    project_id,
    client_id,

    -- Trim strings
    trim(project_name) as project_name,
    trim(project_code) as project_code,
    trim(client_code) as client_code,

     -- Boolean normalization
    try_cast(project_exportable as boolean) as project_exportable,

    -- Date formats are already clean (Autodetected as DATE by DuckDB)
    created_at,
    updated_at_sys

from {{ source('raw', 'projects') }}