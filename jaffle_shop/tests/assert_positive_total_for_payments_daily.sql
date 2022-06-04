WITH payments AS (
    SELECT
        *
    FROM
        {{ ref ('stg_payments') }}
    WHERE
        created = '{{ var ("date") }}'
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
