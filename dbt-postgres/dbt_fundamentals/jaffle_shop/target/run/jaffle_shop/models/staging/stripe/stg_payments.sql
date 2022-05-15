
  create view "raw"."dev"."stg_payments__dbt_tmp" as (
    SELECT
    id,
    orderid AS order_id,
    paymentmethod AS payment_method,
    status,
    -- amount is stored in cents, convert it to dollars
    round( 1.0 * amount / 100, 4) as amount,
    created
FROM
    "raw"."stripe"."payment"

LIMIT 100
  );