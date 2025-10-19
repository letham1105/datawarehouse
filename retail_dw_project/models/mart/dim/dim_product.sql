{{ config(materialized='table') }}

with product_stats as (
    select
        "StockCode" as stock_code,
        "Description" as description,
        avg("Price") as avg_price,
        min("Price") as min_price,
        max("Price") as max_price,
        sum("Quantity") as total_quantity_sold,
        count(distinct "Invoice") as total_orders,
        max("InvoiceDate") as last_sold_date
    from {{ ref('stg_orders') }}
    where "StockCode" is not null and "Description" is not null
    group by "StockCode", "Description"
)

select
    {{ dbt_utils.generate_surrogate_key(['stock_code']) }} as product_key,
    stock_code,
    description,
    -- Tạo category từ description (logic chi tiết hơn)
    case 
        -- Bags & Accessories
        when upper(description) like '%BAG%' or upper(description) like '%HANDBAG%' 
          or upper(description) like '%PURSE%' or upper(description) like '%WALLET%' then 'Bags & Accessories'
        
        -- Home & Garden
        when upper(description) like '%CANDLE%' or upper(description) like '%LIGHT%' 
          or upper(description) like '%LAMP%' or upper(description) like '%HOLDER%'
          or upper(description) like '%JAR%' or upper(description) like '%STORAGE%' then 'Home & Garden'
        
        -- Food & Kitchen
        when upper(description) like '%CAKE%' or upper(description) like '%FOOD%' 
          or upper(description) like '%KITCHEN%' or upper(description) like '%POPCORN%'
          or upper(description) like '%TEA%' or upper(description) like '%COFFEE%' then 'Food & Kitchen'
        
        -- Seasonal & Holiday
        when upper(description) like '%CHRISTMAS%' or upper(description) like '%XMAS%'
          or upper(description) like '%HALLOWEEN%' or upper(description) like '%VALENTINE%'
          or upper(description) like '%EASTER%' or upper(description) like '%HOLIDAY%' then 'Seasonal & Holiday'
        
        -- Stationery & Office
        when upper(description) like '%CARD%' or upper(description) like '%PAPER%'
          or upper(description) like '%PEN%' or upper(description) like '%PENCIL%'
          or upper(description) like '%NOTEBOOK%' or upper(description) like '%STICKER%'
          or upper(description) like '%TISSUE%' then 'Stationery & Office'
        
        -- Gifts & Novelty
        when upper(description) like '%GIFT%' or upper(description) like '%PRESENT%'
          or upper(description) like '%NOVELTY%' or upper(description) like '%SOUVENIR%' then 'Gifts & Novelty'
        
        -- Toys & Games
        when upper(description) like '%TOY%' or upper(description) like '%GAME%'
          or upper(description) like '%GLIDER%' or upper(description) like '%PUZZLE%'
          or upper(description) like '%DOLL%' or upper(description) like '%PLAY%' then 'Toys & Games'
        
        -- Arts & Crafts
        when upper(description) like '%PAINT%' or upper(description) like '%CRAFT%'
          or upper(description) like '%ART%' or upper(description) like '%PATCH%'
          or upper(description) like '%DESIGN%' or upper(description) like '%COLOUR%' then 'Arts & Crafts'
        
        -- Clothing & Fashion
        when upper(description) like '%SHIRT%' or upper(description) like '%DRESS%'
          or upper(description) like '%HAT%' or upper(description) like '%CLOTHING%'
          or upper(description) like '%FASHION%' or upper(description) like '%WEAR%' then 'Clothing & Fashion'
        
        -- Jewelry & Beauty
        when upper(description) like '%RING%' or upper(description) like '%NECKLACE%'
          or upper(description) like '%JEWELRY%' or upper(description) like '%BEAUTY%'
          or upper(description) like '%COSMETIC%' then 'Jewelry & Beauty'
        
        -- Electronics & Tech
        when upper(description) like '%ELECTRONIC%' or upper(description) like '%TECH%'
          or upper(description) like '%BATTERY%' or upper(description) like '%DIGITAL%' then 'Electronics & Tech'
        
        -- Books & Media
        when upper(description) like '%BOOK%' or upper(description) like '%DVD%'
          or upper(description) like '%CD%' or upper(description) like '%MEDIA%' then 'Books & Media'
        
        -- Garden & Outdoor
        when upper(description) like '%GARDEN%' or upper(description) like '%OUTDOOR%'
          or upper(description) like '%PLANT%' or upper(description) like '%FLOWER%' then 'Garden & Outdoor'
        
        else 'General'
    end as category,
    round(avg_price::numeric, 2) as avg_price,
    round(min_price::numeric, 2) as min_price,
    round(max_price::numeric, 2) as max_price,
    total_quantity_sold,
    total_orders,
    last_sold_date,

    current_timestamp as created_at,
    current_timestamp as updated_at
from product_stats
