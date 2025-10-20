{{ config(materialized='table') }}

with date_range as (
    select 
        (select min("InvoiceDate"::date) from {{ ref('stg_orders') }}) - interval '1 year' as start_date,
        (select max("InvoiceDate"::date) from {{ ref('stg_orders') }}) + interval '2 years' as end_date
),
dates as (
    select 
        generate_series(
            (select start_date from date_range),
            (select end_date from date_range),
            interval '1 day'
        )::date as date
)

select
    to_char(date, 'YYYYMMDD')::int as date_id,
    date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(day from date) as day,
    extract(dow from date) as day_of_week,
    extract(quarter from date) as quarter,

    extract(week from date) as week_of_year,
    extract(isodow from date) as day_of_week_iso,

    trim(to_char(date, 'Month')) as month_name,
    trim(to_char(date, 'Mon')) as month_name_short,
    trim(to_char(date, 'Day')) as day_name,
    trim(to_char(date, 'Dy')) as day_name_short,
    to_char(date, 'YYYY-MM') as year_month,

    case 
        when extract(dow from date) in (0, 6) then true 
        else false 
    end as is_weekend,
    case 
        when extract(month from date) in (12, 1, 2) then 'Winter'
        when extract(month from date) in (3, 4, 5) then 'Spring'
        when extract(month from date) in (6, 7, 8) then 'Summer'
        else 'Autumn'
    end as season,
    current_timestamp as created_at
from dates
