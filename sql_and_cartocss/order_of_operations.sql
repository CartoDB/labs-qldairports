alter table qld_flights_destinations_forsolutions add column difference_prevmonth_load numeric
alter table qld_flights_destinations_forsolutions add column difference_prevyear_load numeric
alter table qld_flights_destinations_forsolutions add column load_num numeric
alter table qld_flights_destinations_forsolutions add column prevmonth_category text
alter table qld_flights_destinations_forsolutions add column prevyear_category text
alter table qld_flights_destinations_forsolutions add column prevmonth_load_num numeric
alter table qld_flights_destinations_forsolutions add column prevyear_load_num numeric

update qld_flights_destinations_forsolutions
set load_num = cast(trim(trailing '%' from flight_cube_query_09_06_15_origins_copy.load) as numeric)

create the function (does assume a table name, edit the definition if you have a different table)
abt_qld_flights_prevmonthload(thismonth text, thisyear integer, this_city_pair text)

-- https://github.com/jsanz/labs-qldairports/blob/e97119833f0916cac79a3d15b94982189fc227eb/python_scripts/previous_month_year.sql

-- create column prevmonth_load_num

update athompson.qld_flights_lines_forsolutions set prevmonth_load_num = abt_qld_flights_prevmonthload(calendarmonth, calendaryear, city_pair)

-- create column difference_prevmonth_load

update athompson.qld_flights_lines_forsolutions set difference_prevmonth_load = (load_num - prevmonth_load_num)

alter table qld_flights_lines_forsolutions add column prevmonth_category text

update qld_flights_lines_forsolutions set prevmonth_category = 'increase' where difference_prevmonth_load >= 3

update qld_flights_lines_forsolutions set prevmonth_category = 'neutral' where (difference_prevmonth_load >= 0 AND difference_prevmonth_load < 3)

update qld_flights_lines_forsolutions set prevmonth_category = 'decrease' where difference_prevmonth_load < 0

update qld_flights_lines_forsolutions set prevmonth_category = 'not flown' where difference_prevmonth_load is null

-- https://github.com/jsanz/labs-qldairports/blob/e97119833f0916cac79a3d15b94982189fc227eb/python_scripts/previous_month_year.sql --second function

-- create column prevyear_load_num

update athompson.qld_flights_lines_forsolutions set prevyear_load_num = abt_qld_flights_prevyearload(calendarmonth, calendaryear, city_pair)

-- create column difference_prevyear_load

update athompson.qld_flights_lines_forsolutions set difference_prevyear_load = (load_num - prevyear_load_num)

-- alter table qld_flights_lines_forsolutions add column prevyear_category text

update qld_flights_lines_forsolutions set prevyear_category = 'increase' where difference_prevyear_load >= 3

update qld_flights_lines_forsolutions set prevyear_category = 'neutral' where (difference_prevyear_load >= 0 AND difference_prevyear_load < 3)

update qld_flights_lines_forsolutions set prevyear_category = 'decrease' where difference_prevyear_load < 0

update qld_flights_lines_forsolutions set prevyear_category = 'not flown' where difference_prevyear_load is null