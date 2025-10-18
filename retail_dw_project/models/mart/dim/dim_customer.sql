{{ config(materialized='table') }}

select
    "Customer ID" as customer_id,
    "Country" as country
from {{ ref('stg_orders') }}
group by "Customer ID", "Country"
