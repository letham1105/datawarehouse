{{ config(materialized='view') }}

select *
from public.stg_orders
