-- using the selection function (which does kind of work)
select abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload('January', 2011, 'OOL-ADL') as func from flight_cube_query_09_06_15_dests_corrected_workingcopy

-- The following functions and statements are all attempts at trying to get computed category values into a category column.

--attempt at UPDATE statement which will set the category
with (select abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload('January', 2011, 'OOL-ADL') as func from flight_cube_query_09_06_15_dests_corrected_workingcopy limit 1) as prevmonthload,
UPDATE flightcube SET prevmonthtrend = CASE
   WHEN (load_num - prevmonthload) >= 0 THEN 'up'
   WHEN ((load_num - prevmonthload) < 0) AND ((load_num - prevmonthload) >= -3) THEN 'neutral'
   WHEN (load_num - prevmonthload) < -3 THEN 'down'
END
UPDATE flightcube
set prevmonth 

-- start as a possible trend/category function, instead of an UPDATE, but also doesn't work yet
CREATE OR REPLACE FUNCTION abt_flight_cube_dests_corrected_workingcopy_trend_from_prevmonth()
  RETURNS double precision AS $$
DECLARE
  row RECORD;
BEGIN
    FOR row IN SELECT * FROM flightcube ORDER BY cartodb_id LOOP
      WITH (select abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload(row.calendarmonth, row.calendaryear, row.city_pair) as func from flight_cube_query_09_06_15_dests_corrected_workingcopy limit 1) as prevmonthload,
      UPDATE flightcube SET trend_from_prevmonth = CASE
         WHEN (load_num - prevmonthload) >= 0 THEN 'up'
         WHEN ((load_num - prevmonthload) < 0) AND ((load_num - prevmonthload) >= -3) THEN 'neutral'
         WHEN (load_num - prevmonthload) < -3 THEN 'down'
      END
    END LOOP;
    RETURN prevmonthloadnum;
END
$$ language plpgsql

-- and another way
UPDATE flight_cube_query_09_06_15_dests_corrected_workingcopy SET trend_from_prevmonth = CASE
    WHEN (load_num - pml.func) >= 0 THEN 'up'
    WHEN ((load_num - pml.func < 0) AND ((load_num - pml.func) >= -3) THEN 'neutral'
    WHEN (load_num - pml.func) < -3 THEN 'down'
END
FROM (select func from (select abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload(calendarmonth, calendaryear, city_pair) as func from flight_cube_query_09_06_15_dests_corrected_workingcopy)) as pml

-- another way to try to express it
with pml as (select func from (select abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload(calendarmonth, calendaryear, city_pair) as func from athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy)),
loaddiff as (athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy.load_num - pml)
UPDATE athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy SET trend_from_prevmonth = CASE
  WHEN loaddiff >= 0 THEN 'up'
  WHEN ((loaddiff < 0) AND (loaddiff >= -3)) THEN 'neutral'
    WHEN loaddiff < -3 THEN 'down'
END
