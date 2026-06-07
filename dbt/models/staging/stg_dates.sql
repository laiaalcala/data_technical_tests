with date_spine as (
    -- Use the dbt_utils macro to automatically generate a continuous daily sequence of dates
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-01-01' as date)",
        end_date="cast('2026-12-31' as date)"
    ) }}
)

select
    date_day as date_id,
    -- Extracted date attributes to enable pre-calculated BI filtering and grouping
    extract(day from date_day) as day,
    extract(month from date_day) as month,
    extract(quarter from date_day) as quarter,
    extract(year from date_day) as year,
    -- Text representation of the date for specific categorical reporting requirements
    cast(date_day as varchar) as date_string
from date_spine