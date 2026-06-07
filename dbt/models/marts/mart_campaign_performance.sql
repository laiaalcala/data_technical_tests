-- Campaign-level visit KPIs
with staging_campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

staging_clients as (
    select * from {{ ref('stg_clients') }}
),

staging_projects as (
    select * from {{ ref('stg_projects') }}
),

visits as (
    select * from {{ ref('stg_visits') }}
),

dim_CAMPAIGN as (
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
    from staging_campaigns c
    left join staging_projects p  on c.project_id = p.project_id
    left join staging_clients cl  on cl.client_id = p.client_id
    
)

select
    c.campaign_id,
    c.campaign_start_date,
    c.campaign_end_date,
    c.total_visits_planned,
    c.client_id,
    c.client_name,
    c.sector,
    c.project_id,
    c.project_name,

    -- Total count of distinct visits
    count(distinct v.visit_id) as total_visits,

    -- Visit status breakdown
    count(distinct case when v.visit_status = 'OK' then v.visit_id end) as successful_visits,
    count(distinct case when v.visit_status = 'INCID' then v.visit_id end) as incident_visits,
    count(distinct case when v.visit_status = 'INFO' then v.visit_id end) as informational_visits,
    count(distinct case when v.visit_status = 'NOVIS' then v.visit_id end) as cancelled_visits,
    
    -- How many executed visits are directly billable to the end client
    count(distinct case when v.is_client_billable = true then v.visit_id end) as billable_visits,

    -- Campaign completion progress against planned targets.
    round(
        count(distinct v.visit_id) * 100.0 / nullif(c.total_visits_planned, 0), 
        2
    ) as completion_rate_percentage

from dim_CAMPAIGN c
left join visits v
    on c.campaign_id = v.campaign_id
group by 
    1, 2, 3, 4, 5, 6, 7, 8, 9
order by 
    total_visits desc