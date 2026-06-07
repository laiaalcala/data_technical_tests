with source_data as (
    select
        question_id,
        campaign_id,

        -- Trim strings
        trim(campaign_code) as campaign_code,
        trim(question_code) as question_code,
        coalesce(question_name, 'Not identified question') as question_name,
        trim(question_type) as question_type,
        trim(question_category) as question_category,

        -- Boolean normalization
        try_cast(trim(question_is_highlighted::varchar) as boolean) as question_is_highlighted,
        try_cast(trim(image_associated::varchar) as boolean) as image_associated,

        -- Numerical metrics
        question_order,

        -- Date formats are already clean (Autodetected as DATE by DuckDB)
        created_at,
        updated_at_sys

    from {{ source('raw', 'questions') }}
),

-- Artificial dummy record (ID 0) created to safeguard referential integrity.
-- This prevents relationships tests from failing when downstream fact tables contain orphaned question IDs.
dummy_record as (
    select
        0 as question_id,
        null as campaign_id,
        'DUMMY' as campaign_code,
        'DUMMY' as question_code,
        'Not identified question (ID fallback)' as question_name,
        'UNKNOWN' as question_type,
        'UNKNOWN' as question_category,
        false as question_is_highlighted,
        false as image_associated,
        0 as question_order,
        cast(now() as date) as created_at,
        cast(now() as timestamp) as updated_at_sys
)

-- Consolidate both data blocks into a unified set to generate the final dimension grain
select * from source_data
union all
select * from dummy_record