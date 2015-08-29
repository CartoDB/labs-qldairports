with -- first data, all routes from a given city and month
data as (
  select * from athompson.flight_cube_query_09_06_15_dests_corrected
  where
    origin_city = 'OOL' AND -- change the airport
    calendaryear = 2010  AND -- change the year
    calendarmonth = 'April' -- change the month
), -- from OOL and others
origin as (
  select * from athompson.flight_cube_query_09_06_15_origins where cartodb_id = 1753 -- change the id based on airport
), -- get destinations
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
         ST_Transform(origin.the_geom, 953027),-- this projection worked well for the Australia data
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
  -- fake category (needed by torque) - this will eventually need to be our increase/decrease/neutral category
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

-- AIRPORT ID's: for determining the origin point in the above Torque SQL

cartodb_id = 1753 -- OOL
cartodb_id = 2331 -- TSV
cartodb_id = 169  -- ISA
cartodb_id = 428  -- LRE
cartodb_id = 1974 -- SYD

-- SQL Queries per layer. Each of these would be updated with setSQL based on the user-submitted form
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
