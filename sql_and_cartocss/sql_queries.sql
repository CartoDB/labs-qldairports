-- FIRST ONE IS JORGE's

with -- first data, main cities of the world
data as (
  select * from athompson.flight_cube_query_09_06_15_dests_corrected
  where
    origin_city = 'OOL' AND -- change the airport
    calendaryear = 2010  AND -- change the year
    calendarmonth IN ('April') -- change the month
), -- from OOL and others
origin as (
  select * from athompson.flight_cube_query_09_06_15_origins where cartodb_id = 1753 -- change the id based on airport
), -- get cities closer to 14000 Km
dests as (
  select d.*,
  (ST_Distance(
    o.the_geom::geography, 
    d.the_geom::geography 
  ))/1000::int distance
  from data d, origin o
), -- generate lines using the geographic maxmimum circle
lines as(
  select
  dests.cartodb_id, dests.calendarmonth, dests.calendaryear, dests.city_pair, dests.flight_type, dests.load, dests.distance,
  ST_Transform(
     ST_Segmentize(
       ST_MakeLine(
         ST_Transform(origin.the_geom, 953027),
         ST_Transform(dests.the_geom, 953027)
       ), 
       100000
     ), 
    3857 
   ) the_geom_webmercator
  from origin,dests
), -- steps to interpolate, 300 per route, from 0 to 1
steps as (
  select lines.cartodb_id,
    generate_series(0, 300, 1 )/300.0 step
  from lines
) -- finally the points over lines
select
  -- fake autonum
  row_number() over (partition by 1) cartodb_id,
  -- fake category (needed by torque)
  lines.city_pair, lines.flight_type, 1 as fakecat,
  -- calculate the timing of each point starting with this date
  timestamp '2015-08-23 10:00'
    -- they will all arrive _almost_ at the same time
    -- to the destiny (1 hour would be same time)
    - interval '45 minutes' * (lines.distance/1000.0)
    -- some random exit distribution using modulus
    + interval '1 hour' * (lines.cartodb_id % 15)
    -- actual distribution across the line at 1000km/h speed
    + interval '1 hour' * (steps.step*lines.distance/(1000.0)) faketime ,
  -- get a point on the line using the step
  ST_LineInterpolatePoint(
    lines.the_geom_webmercator,
    steps.step
  ) the_geom_webmercator
from lines
join steps on lines.cartodb_id = steps.cartodb_id
order by steps.step

-- AIRPORTS

cartodb_id = 1753 -- OOL
cartodb_id = 2331 -- TSV
cartodb_id = 169  -- ISA
cartodb_id = 428  -- LRE
cartodb_id = 1974 -- SYD

-- SQL Queries per layer (above is torque)
-- lines layer
SELECT * FROM qld_airports_lines 
WHERE 
  origin_city = 'OOL'  AND
  calendaryear = 2010 AND
  calendarmonth = 'April'

-- destinations layer

SELECT * FROM flight_cube_query_09_06_15_dests_corrected WHERE 
  origin_city = 'OOL'  AND
  calendaryear = 2010 AND
  calendarmonth = 'April'

-- origins layer

SELECT * FROM flight_cube_query_09_06_15_origins WHERE 
  origin_city = 'OOL'  AND
  calendaryear = 2010 AND
  calendarmonth = 'April'

--- new torque

with -- first data, main cities of the world
data as (
  select * from athompson.qld_flights_destinations_forsolutions
  where
    calendaryear = 2010  AND -- change the year
    calendarmonth = 'May' -- change the month
), -- from OOL and others
origin as (
  select * from athompson.qld_flights_origins_forsolutions where cartodb_id = 1753 -- change the id based on airport
), -- get cities closer to 14000 Km
dests as (
  select d.*,
  (ST_Distance(
    o.the_geom::geography, 
    d.the_geom::geography 
  ))/1000::int distance
  from data d, origin o
), -- generate lines using the geographic maxmimum circle
lines as(
  select
  dests.cartodb_id, dests.calendarmonth, dests.calendaryear, dests.city_pair, dests.flight_type, dests.load, dests.prevmonth_load_num, dests.prevmonth_category, dests.prevyear_load_num, dests.prevyear_category, dests.difference_prevmonth_load, dests.difference_prevyear_load, dests.distance,
  ST_Transform(
     ST_Segmentize(
       ST_MakeLine(
         ST_Transform(origin.the_geom, 953027),
         ST_Transform(dests.the_geom, 953027)
       ), 
       100000
     ), 
    3857 
   ) the_geom_webmercator
  from origin,dests
), -- steps to interpolate, 300 per route, from 0 to 1
steps as (
  select lines.cartodb_id,
    generate_series(0, 300, 1 )/300.0 step
  from lines
) -- finally the points over lines
select
  -- fake autonum
  row_number() over (partition by 1) cartodb_id,
  -- fake category (needed by torque)
  lines.city_pair,
  lines.flight_type,
  lines.load,
  lines.prevmonth_load_num,
  lines.prevmonth_category,
  lines.prevyear_load_num,
  lines.prevyear_category,
  lines.difference_prevmonth_load,
  lines.difference_prevyear_load,
  -- calculate the timing of each point starting with this date
  timestamp '2015-08-23 10:00'
    -- they will all arrive _almost_ at the same time
    -- to the destiny (1 hour would be same time)
    - interval '45 minutes' * (lines.distance/1000.0)
    -- some random exit distribution using modulus
    + interval '1 hour' * (lines.cartodb_id % 15)
    -- actual distribution across the line at 1000km/h speed
    + interval '1 hour' * (steps.step*lines.distance/(1000.0)) faketime ,
  -- get a point on the line using the step
  ST_LineInterpolatePoint(
    lines.the_geom_webmercator,
    steps.step
  ) the_geom_webmercator
from lines
join steps on lines.cartodb_id = steps.cartodb_id
order by steps.step