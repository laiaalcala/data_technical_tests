# Phase 2 — dbt Transformations Analytics Engineering

This folder contains the dbt Core project configured with DuckDB to transform raw data from retail field visits into reliable corporate Data Marts ready for BI consumption.

## Layer Architecture Decisions

### 1. Staging Layer (`models/staging/`)
* **Objective:** One-to-one mapping with raw CSV files to standardize, clean, and cast data types.
* **Cleaning Decisions:**
  * Dates were parsed using standardized formats (`YYYY-MM-DD`).
  * `TRIM()` and text formatting applied to categorical strings (provinces, statuses, names) to avoid analytical duplication due to trailing spaces.
  * Explicit data-type casting (`INTEGER`, `BOOLEAN`, `VARCHAR`) to enforce schema validation.
  * Handled structural nulls safely using `COALESCE` in the staging layer to guarantee downstream data quality and pass dbt schema tests:
    * Injected `COALESCE(question_id, 0)` to handle 288 records where `question_id` was missing. Data profiling revealed these were not empty rows, but an upstream data corruption issue, as they contained valid answers (e.g., "Auxiliar de farmacia", "Mejora altura") and question types ('T', 'M', 'S').
    * By mapping them to a default technical ID (`0`) instead of filtering them out, we successfully pass the dbt `not_null` schema tests and prevent losing genuine business answers in the final BI layer.
    * *Referential Integrity Safeguard:* To prevent the dbt `relationships` test from failing due to these 288 orphaned records, an artificial dummy record with `question_id = 0` was injected into `stg_questions` via a `UNION ALL` statement. This ensures strict referential integrity between the fact and dimension grains while gracefully modeling unmapped upstream data.
    * `answer` values combine text cleaning and null prevention using `COALESCE(TRIM(answer), 'Without answer')`.


### 2. Marts Layer (`models/marts/`)
* **`mart_campaign_performance`:** Aggregated at the Campaign grain. It solves business operational metrics (KPIs) regarding planned vs. executed visits, completion rates, and status breakdowns.  
  #### Calculated KPIs Included:
  * **`total_visits`**: Distinct count of all unique visits executed within the campaign.
  * **Operational Breakdown**: Segmented counters based on visit final statuses:
    * `successful_visits`: Visits completed successfully (Status: `'OK'`).
    * `incident_visits`: Visits completed with an incidence (Status: `'INCID'`).
    * `informational_visits`: Informational visits (Status: `'INFO'`).
    * `cancelled_visits`: Visit not carried out (Status: `'NOVIS'`).
  * **`billable_visits`**: Revenue-tracking KPI counting only executed visits marked as `is_client_billable = true`.
  * **`completion_rate_percentage`**: Campaign target progress calculated as `(total_visits * 100.0) / total_visits_planned` (rounded to 2 decimals). It safely handles missing targets using `NULLIF` to prevent division-by-zero errors.

* **`mart_visit_responses`:** Flattened table at the Answer grain. 
* *Star Schema Implementation:* It joins the central fact grain (`stg_responses`) directly with dimensions (`dim_campaign`, `dim_route`, `dim_pos`, `dim_question`) to optimize read-performance for BI tools, preventing slow snowflake-like chained joins.
  * *Many-to-Many Bridge Resolution & Worker Enrichment:* Although the conceptual Star Schema decouples workers from the core fact table to maintain normalization, this analytical mart intentionally enriches the final table with employee metadata. It addresses the N:M relationship between Routes and Employees by utilizing `stg_route_employee` as a bridge table and filtering strictly by `main_employee = true`. This architectural choice flattens the execution hierarchy, directly mapping a single accountable field worker to each individual response without risking artificial fact row duplication.
  * *Orphan Records Resilience:* Data profiling revealed 1,321 response records that lacked an assigned worker. Further root-cause analysis in the staging layer identified a dual upstream data quality issue: 155 visits were natively missing a `route_id`, while the remaining unmapped records belonged to visits with a `route_id` that did not exist within the 241 routes registered in the bridge table. To protect analytical integrity and avoid dropping real store activity, a fallback mechanism was implemented using `COALESCE(e.employee_first_name, 'Route without assigned employee')`, allowing these operational gaps to be cleanly surfaced and handled at the BI layer via dashboard filters.
---

## How to Run the Project Locally

### Prerequisites
1. Ensure you have Python installed, then set up the environment:
```bash
pip install dbt-core dbt-duckdb
```

2. Navigate to the dbt project:
```bash
cd dbt
```

3. Verify the connection:
```bash
dbt debug
```

4. Run the full transformation pipeline:
```bash
dbt run
```

5. Execute integrity tests:
```bash
dbt test
```

6. Generate and view the documentation lineage graph:
```bash
dbt docs generate
dbt docs serve
```

---

## Future Improvements (Given more time)

**Custom Singular Tests:** Introduce explicit custom business logic validation within the `tests/` directory (e.g., creating an automated rule ensuring that `campaign_end_date` is never chronologically prior to `campaign_start_date`).

* **Package Extensions (`dbt-expectations`):** Integrate advanced data assertions to enforce strict value bounds on key performance metrics, such as validating that `completion_rate_percentage` never exceeds a logical maximum of 100% or that `visit_status` or `question_type` stay within expected categorical parameters.

* **Granular Documentation:** Fully map description blocks and owner metadata for all staging and mart entities in centralized `.yml` schemas to leverage `dbt docs generate`, preparing the project for seamless self-service BI governance.

* **Dedicated Intermediate Layer (`models/intermediate/`):** Abstract the campaign/project/client join into a reusable int_campaigns.sql model to keep the code DRY and avoid duplication between marts.

* **Incremental Models:** Convert high-volume staging and fact tables (such as `FACT_VISIT_RESPONSE`) from standard `table` or `view` configurations to `incremental` materializations. This ensures only newly arrived or updated survey records are processed daily, exponentially reducing computing workloads and processing costs as historical data scales over the years.

* **GitHub Actions Pipeline:**: Automate an isolated pipeline to run `dbt run` and `dbt test` on every pull request.