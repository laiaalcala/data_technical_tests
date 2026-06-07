-- flattened visit + answer table ready for BI consumption
with staging_responses as (
    
    select * from {{ ref('stg_responses') }}),

dim_visit as (
    select * from {{ ref('stg_visits') }} ),

dim_question as (
    select * from {{ ref('stg_questions') }}),

dim_campaign as (
    -- (Campaign + Client + Project)
    select 
        c.campaign_id,
        c.campaign_start_date,
        c.campaign_end_date,
        c.total_visits_planned,
        cl.client_id,
        cl.client_name,
        cl.sector,
        p.project_id,
        p.project_name
    from {{ ref('stg_campaigns') }} c
    left join {{ ref('stg_projects') }} p  on c.project_id = p.project_id
    left join {{ ref('stg_clients') }} cl  on cl.client_id = p.client_id
    
),

dim_route as (
    select * from {{ ref('stg_routes') }}),

bridge_route_employee as (
    select * from {{ ref('stg_route_employee') }}
),

dim_workers as (
    select * from {{ ref('stg_workers') }} ),

dim_pos as (
    select * from {{ ref('stg_pos') }})

-- FACT_VISIT_RESPONSE r
select
    -- Keys & Metrics from the responses table
    sr.answer_id,
    sr.expected_answer,
    sr.visit_id,
    sr.question_id,
    sr.question_type,
    sr.answer,

    -- Attributes from DIM_VISIT
    v.visit_status,
    v.visit_date as date_id, 

    -- Attributes from DIM_QUESTION
    q.question_name,
    q.question_type,
    q.question_category,

    -- Attributes from DIM_CAMPAIGN 
    c.campaign_id,
    c.campaign_start_date,
    c.campaign_end_date,
    c.total_visits_planned,
    c.client_id,
    c.client_name,
    c.sector,
    c.project_id,
    c.project_name,

    -- Attributes from DIM_ROUTE
    r.route_start_date,
    r.route_end_date,

    -- Attributes from DIM_WORKERS
    e.employee_id,
    COALESCE(e.employee_first_name, 'Route without assigned employee') as employee_first_name,
    e.employee_contract_type,
    e.employee_address_province,

    -- Attributes from DIM_POS
    p.intervention_point_id,
    p.intervention_point_name,
    p.intervention_point_province

from staging_responses sr

-- Relational joins to connect the fact grain to every dimension
left join dim_visit v on sr.visit_id = v.visit_id
left join dim_question q on sr.question_id = q.question_id
left join dim_campaign c on v.campaign_id = c.campaign_id
left join dim_route r on v.route_id = r.route_id
left join bridge_route_employee re on v.route_id = re.route_id and re.main_employee = true
left join dim_workers e on re.employee_id = e.employee_id
left join dim_pos p on v.intervention_point_id = p.intervention_point_id