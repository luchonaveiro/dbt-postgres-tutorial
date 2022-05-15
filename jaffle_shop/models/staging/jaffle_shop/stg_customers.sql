SELECT
    id AS customer_id,
    first_name,
    last_name
FROM
    {{ source ('jaffle_shop', 'customers') }}

{% if target.name == 'dev' -%}
LIMIT 100
{%- endif -%}