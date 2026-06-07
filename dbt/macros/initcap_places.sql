{% macro initcap_places(col) %}
case 
    -- 1. Hardcoded exceptions for inverted names or special cases
    when lower(trim({{ col }})) in ('castelló', 'castellon', 'castellón') then 'Castellón'
    when lower(trim({{ col }})) in ('valencia/valència') then 'Valencia'
    when lower(trim({{ col }})) = 'rioja, la' then 'La Rioja'
    when lower(trim({{ col }})) = 'palmas, las' then 'Las Palmas'
    when lower(trim({{ col }})) = 'alpes (hautes)' then 'Alpes (Hautes)'
    
    -- 2. Capitalize words separated by ' ' and '-'
    else list_aggr(
            -- Recombine the space-separated words back into a single clean string
            list_transform(
                -- Normalize text to lowercase, trim padding spaces, and split into an array by spaces
                string_split(lower(trim({{ col }}))::varchar, ' '),
                x -> list_aggr(
                        -- Recombine the segments back together using a '-' separator
                        list_transform(
                            -- For each space-separated word, split it further by '-'
                            string_split(x, '-'),
                            -- Capitalize the very first letter of each segment and append the rest
                            y -> upper(substring(y, 1, 1)) || substring(y, 2)
                        ),
                        'string_agg',
                        '-'
                     )
            ),
            'string_agg',
            ' '
         )
end
{% endmacro %}