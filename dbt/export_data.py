import duckdb

con = duckdb.connect("dbt_local.db")

df1 = con.execute("SELECT * FROM mart_campaign_performance").df()
df2 = con.execute("SELECT * FROM mart_visit_responses").df()

# 3. Lo guardamos en un CSV limpio
df1.to_csv("../dashboard/campaign_performance.csv", index=False)
df2.to_csv("../dashboard/visit_responses.csv", index=False)

print("CSV correctly exported")
