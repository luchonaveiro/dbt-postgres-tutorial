
  create view "raw"."dev"."stg_orders__dbt_tmp" as (
    SELECT
    id AS order_id,
    user_id AS customer_id,
    order_date,
    status
FROM
    "raw"."jaffle_shop"."orders"

LIMIT 100
  );