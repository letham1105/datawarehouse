{{ config(materialized='table') }}

with product_stats as (
    select
        "StockCode" as stock_code,
        max("Description") as description,
        avg("Price") as avg_price,
        min("Price") as min_price,
        max("Price") as max_price,
        sum("Quantity") as total_quantity_sold,
        count(distinct "Invoice") as total_orders,
        max("InvoiceDate") as last_sold_date
    from {{ ref('stg_orders') }}
    where "StockCode" is not null and "Description" is not null
    group by "StockCode"
)

select
    {{ dbt_utils.generate_surrogate_key(['stock_code']) }} as product_key,
    stock_code,
    description,
    case 
        -- Bags & Accessories
        when upper(description) like '%BAG%' or upper(description) like '%HANDBAG%' 
            or upper(description) like '%PURSE%' or upper(description) like '%WALLET%' 
            or upper(description) like '%SHOPPER%' then 'Bags & Accessories' 
        
        -- Home & Garden
        when upper(description) like '%CANDLE%' or upper(description) like '%LIGHT%' 
            or upper(description) like '%LAMP%' or upper(description) like '%HOLDER%'
            or upper(description) like '%JAR%' or upper(description) like '%STORAGE%'
            or upper(description) like '%TRINKET BOX%' or upper(description) like '%MIRROR%'
            or upper(description) like '%FRAME%' or upper(description) like '%PICTURE FRAME%' then 'Home Decor'
        
        when upper(description) like '%METAL SIGN%' 
            or upper(description) like '% SIGN' then 'Home Decor - Signs'
          
        -- Food & Kitchen
        when upper(description) like '%CAKE%' or upper(description) like '%FOOD%' 
            or upper(description) like '%KITCHEN%' or upper(description) like '%POPCORN%'
            or upper(description) like '%TEA%' or upper(description) like '%COFFEE%'
            or upper(description) like '%LUNCH BOX%' or upper(description) like '%SNACK BOX%'
            or upper(description) like '%MUG%' or upper(description) like '%PARASOL%'
            or upper(description) like '%JAM MAKING%' then 'Food & Kitchen'
        
        -- Stationery, Gifts & Crafts (Merged & Expanded)
        when upper(description) like '%CARD%' or upper(description) like '%PAPER%'
            or upper(description) like '%PEN%' or upper(description) like '%PENCIL%'
            or upper(description) like '%NOTEBOOK%' or upper(description) like '%STICKER%'
            or upper(description) like '%TISSUE%' or upper(description) like '%GIFT%'
            or upper(description) like '%CRAYONS%' or upper(description) like '%WRAP%' 
            or upper(description) like '%RIBBONS%' or upper(description) like '%SCISSOR%' 
            or upper(description) like '%CLAY%' or upper(description) like '%PAINT%'
            or upper(description) like '%CRAFT%' or upper(description) like '%ART%' 
            or upper(description) like '%PATCH%' or upper(description) like '%DESIGN%' then 'Stationery & Crafts'

        -- Toys, Games & Novelty (Expanded)
        when upper(description) like '%TOY%' or upper(description) like '%GAME%'
            or upper(description) like '%GLIDER%' or upper(description) like '%PUZZLE%'
            or upper(description) like '%DOLL%' or upper(description) like '%PLAY%'
            or upper(description) like '%HARMONICA%' or upper(description) like '%PLASTERS IN TIN%'
            or upper(description) like '%SPACEBOY%' or upper(description) like '%WOODLAND ANIMALS%' then 'Toys & Novelty' 
        
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

        when upper(description) like '%BATHROOM%' or upper(description) like '%CLOTHES PEGS%' then 'General Homeware'
        
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
