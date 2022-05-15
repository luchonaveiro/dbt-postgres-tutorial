
  create view "raw"."dev"."stg_customers__dbt_tmp" as (
    SELECT
    id AS customer_id,
    first_name,
    last_name
FROM
    "raw"."jaffle_shop"."customers"

LIMIT 100
  );