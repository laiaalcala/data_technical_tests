### Phase 3 — Dashboard Notes & Business Justification

Requirement: The operations team needs to understand how active campaigns are performing and whether field workers are completing their routes. Management wants a portfolio view across clients and projects.

* **Total Completion Percentage (%):**
    * *Why:* Directly answers if active campaigns are meeting global targets at a macro portfolio level.
    * *Data Source:* `mart_campaign_performance`
    * *Decision Supported:* Helps Management reassign budget to struggling campaigns or identify underperforming client sectors.
    * *Design Choice:* Formatted explicitly as a percentage (`%`) to align with executive reporting standards, ensuring dynamic, weighted calculations when filtering across clients or projects.
    * *Formula:* `SUM(executed_visits) / SUM(planned_visits)`
* **Route Completion Rate (%) per Employee:**
    * *Why:* Isolates individual operational execution to benchmark field workers against each other.
    * *Data Source:* `mart_visit_responses` (BI-flattened layer)
    * *Decision Supported:* Assists HR and Operations in identifying top-performing field staff or isolating workers who require operational route support.
    * *Design Choice:* Visualized as a ranked horizontal bar chart. **A Looker Studio component-level filter is applied directly to this chart to exclude 'Route without assigned employee'**.
    * *Formula:* `COUNT_DISTINCT(visit_id) / MAX(total_visits_planned)` *(Evaluated dynamically at the employee dimension grain in Looker Studio).*
* **Portfolio Performance Breakdown (Client & Project Grain):**
    * *Why:* Directly addresses management's core requirement for a multi-client, multi-project portfolio overview.
    * *Data Source:* `mart_campaign_performance`
    * *Decision Supported:* Strategic account management. Allows executives to identify at a glance which client accounts or specific projects are driving maximum target completion versus those facing regional or operational bottlenecks.
    * *Design Choice:* Visualized as a performance table matrix grouped by `client_name` and `project_name`. It ranks business accounts by their weighted completion percentages, turning raw campaign metrics into an executive ledger for high-level portfolio operational reviews.
    * *Formula:* `SUM(executed_visits) / SUM(planned_visits)`
* **Interactive Control Layer (Client & Project Filters):**
    * *Why:* Allows regional managers to isolate a single client or specific project performance during weekly review meetings.
    * *Design Choice:* Positioned as clean, dropdown search bars at the top of the dynamic table. Metric values within the dropdowns were explicitly hidden.

### Future Improvements
If granted more operational time, the following enhancements would be deployed:
1. **Time-Series trend line:** Integrating a monthly or weekly historical timeline to see if the `Route Completion Rate` is improving or declining over time.
2. **Alerting System:** Conditional formatting thresholds (e.g., highlighting in soft red any project with a Completion Rate below 40%) to trigger proactive operational support.

### Dashboard Link
You can access the dashboard here: [Looker Studio Dashboard](https://datastudio.google.com/s/ohhVQ4epoF8)