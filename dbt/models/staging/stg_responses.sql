select
    
    answer_id,
    visit_id,
    COALESCE(question_id, 0) as question_id,

    -- Trim strings
    trim(campaign_code) as campaign_code,
    trim(intervention_point_code) as intervention_point_code,
    trim(question_type) as question_type,
    coalesce(trim(answer), 'Without answer') as answer,
    trim(expected_answer) as expected_answer,

    -- Date formats are already clean (Autodetected as DATE by DuckDB)
    created_at,
    updated_at_sys

from {{ source('raw', 'responses') }}

-- Filter NaN in question ID. We don't want the responses that we don't know the question
--where question_id is not null