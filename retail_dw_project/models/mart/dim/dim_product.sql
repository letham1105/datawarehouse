{{ config(materialized='table') }}

select
    "StockCode" as stock_code,
    "Description" as description
from {{ ref('stg_orders') }}
group by "StockCode", "Description"
