
-- output:
-- the query provides weekly lead acquisition data during q3 2024, including:
-- 1. total leads acquired per week
-- 2. number of leads that converted into customers, and their ratio to total leads
-- 3. number of leads that completed a nutrition call, and their ratio to total leads
-- the output is sorted by the week of acquisition.

  select 

    format_timestamp('%y-%u', l.created_at, 'America/Chicago')                             as acquired_week    -- automatic central time conversion: https://www.googlecloudcommunity.com/gc/Data-Analytics/Bigquery-Time-zone-configuration/m-p/677193
    , count(distinct l.lead_id)                                                            as total_leads      

    , count(distinct c.lead_id)                                                            as converted_leads  
    , round(safe_divide(count(distinct c.lead_id), count(distinct l.lead_id))*100, 2)      as conversion_ratio -- ratio of conversions to total leads

    , count(distinct nc.lead_id)                                                           as leads_with_calls 
    , round(safe_divide(count(distinct nc.lead_id), count(distinct l.lead_id))*100, 2)     as call_ratio       -- ratio of leads with calls to total leads

  from leads_table l
  
  left join customers_table c 
    on l.lead_id = c.lead_id
    and c.created_at <= l.created_at -- (Note: I wonder if there is any posibility of someone being already a customer, and becoming a lead after. Apply in case, might prevent some data errors)
  
  left join nutrition_calls_table nc 
    on l.lead_id = nc.lead_id
    and nc.created_at <= l.created_at -- (Note: I wonder if there is any posibility of someone has received nutrition calls before becoming a lead. Apply in case, might prevent some data errors)

  where timestamp(datetime(l.created_at, "America/Chicago")) between timestamp('2024-07-01') and timestamp('2024-09-30') -- filter q3 2024 leads: https://www.googlecloudcommunity.com/gc/Data-Analytics/Bigquery-Time-zone-configuration/m-p/677193
  
  group by 1

  order by 1

