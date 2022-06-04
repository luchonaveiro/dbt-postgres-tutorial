select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      WITH payments AS (
    SELECT
        *
    FROM
        "raw"."dev"."stg_payments"
    WHERE
        created = '2018-01-02'
),
test_data AS (
    SELECT
        order_id,
        sum(amount) AS total_amount
FROM
    payments
GROUP BY
    1
)
SELECT
    *
FROM
    test_data
WHERE
    total_amount < 0
      
    ) dbt_internal_test