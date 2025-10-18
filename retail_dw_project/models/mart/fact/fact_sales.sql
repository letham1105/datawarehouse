{{ config(materialized='table') }}

select
    o."Invoice" as invoice_no,
    o."Customer ID" as customer_id,
    o."StockCode" as stock_code,
    o."Quantity" as quantity,
    o."Price" as price,
    o."InvoiceDate" as order_date,
    to_char(o."InvoiceDate"::date, 'YYYYMMDD')::int as date_id  -- thêm cột date_id
from {{ ref('stg_orders') }} o
