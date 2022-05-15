SELECT
    id,
    orderid AS order_id,
    paymentmethod AS payment_method,
    status,
    -- amount is stored in cents, convert it to dollars
    {{ cents_to_dollars('amount', 4) }} as amount,
    created
FROM
    {{ source ('stripe', 'payment') }}

{% if target.name == 'dev' -%}
LIMIT 100
{%- endif -%}
