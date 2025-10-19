{{ config(materialized='table') }}

with customer_stats as (
    select
        "Customer ID" as customer_id,
        "Country" as country,
        min("InvoiceDate") as first_order_date,
        max("InvoiceDate") as last_order_date,
        count(distinct "Invoice") as total_orders,
        sum("Quantity" * "Price") as total_revenue,
        count(distinct "StockCode") as unique_products_purchased,
        sum("Quantity") as total_items_purchased,
        round(avg("Price"::numeric), 2) as avg_item_price,
        (max("InvoiceDate")::date - min("InvoiceDate")::date) as active_period_days,
        round((sum("Quantity" * "Price") / count(distinct "Invoice"))::numeric, 2) as avg_order_value,
        round((sum("Quantity") / count(distinct "Invoice"))::numeric, 1) as avg_items_per_order
    from {{ ref('stg_orders') }}
    where "Customer ID" > 0  -- Loại bỏ customer_id = -1 (guest users)
    group by "Customer ID", "Country"
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    customer_id,
    country,
    first_order_date,
    last_order_date,
    total_orders,
    round(total_revenue::numeric, 2) as total_revenue,
    unique_products_purchased,
    total_items_purchased,
    avg_item_price,
    active_period_days,
    avg_order_value,
    avg_items_per_order,
    case 
        when total_revenue >= 1000 then 'VIP'
        when total_revenue >= 500 then 'Premium'
        when total_revenue >= 100 then 'Regular'
        else 'Basic'
    end as customer_segment,
    case 
        when total_orders >= 10 and total_revenue >= 500 then 'High Value'
        when total_orders >= 5 and total_revenue >= 200 then 'Medium Value'
        when total_orders >= 2 then 'Regular'
        else 'One-time'
    end as loyalty_tier,
    current_timestamp as created_at,
    current_timestamp as updated_at
from customer_stats
