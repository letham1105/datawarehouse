{{ config(materialized='table') }}

with clean_orders as (
    select *
    from {{ ref('stg_orders') }}
    where "Customer ID" > 0  -- Loại bỏ guest users
      and "Quantity" > 0     -- Chỉ lấy sales (không lấy returns)
      and "Price" > 0        -- Giá phải dương
      and "StockCode" is not null
      and "Description" is not null
)

select
    -- Surrogate key cho fact record
    {{ dbt_utils.generate_surrogate_key(['o."Invoice"', 'o."StockCode"', 'o."InvoiceDate"', 'o."Price"', 'o."Quantity"']) }} as sales_key,
    
    -- Business keys
    o."Invoice" as invoice_no,
    o."Customer ID" as customer_id,
    o."StockCode" as stock_code,
    
    -- Foreign keys to dimensions (surrogate keys)
    dc.customer_key,
    dp.product_key,
    to_char(o."InvoiceDate"::date, 'YYYYMMDD')::int as date_id,
    
    -- Measures (facts)
    o."Quantity" as quantity,
    round(o."Price"::numeric, 2) as unit_price,
    round((o."Quantity" * o."Price")::numeric, 2) as line_total,
    
    -- Additional measures
    case 
        when o."Quantity" >= 10 then 'Bulk'
        when o."Quantity" >= 5 then 'Multi'
        else 'Single'
    end as quantity_tier,
    
    -- Timestamps
    o."InvoiceDate" as order_datetime,
    o."InvoiceDate"::date as order_date,
    extract(hour from o."InvoiceDate"::timestamp) as order_hour,
    
    -- Audit fields
    current_timestamp as created_at
    
from clean_orders o
left join {{ ref('dim_customer') }} dc 
    on o."Customer ID" = dc.customer_id
left join {{ ref('dim_product') }} dp 
    on o."StockCode" = dp.stock_code
