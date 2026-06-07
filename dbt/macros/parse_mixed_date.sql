{% macro parse_mixed_date(col) %}
coalesce(
    --Try parsing standard format (YYYY-MM-DD)
    try_cast({{ col }} as date),
    -- Try parsing European format (DD/MM/YYYY) and force cast to DATE to remove time components
    try_strptime({{ col }}::varchar, '%d/%m/%Y')::date
)
{% endmacro %}