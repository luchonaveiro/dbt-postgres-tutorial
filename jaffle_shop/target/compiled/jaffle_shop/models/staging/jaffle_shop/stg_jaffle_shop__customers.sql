with 

source as (

  select * from "raw"."jaffle_shop"."customers"

),

transformed as (

  select 

    id as customer_id,
    last_name as customer_last_name,
    first_name as customer_first_name,
    first_name || ' ' || last_name as full_name

  from source

)

select * from transformed