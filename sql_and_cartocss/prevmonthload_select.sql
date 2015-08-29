CREATE OR REPLACE FUNCTION abt_flight_cube_query_09_06_15_dests_corrected_workingcopy_prevmonthload(thismonth TEXT, thisyear INTEGER, this_city_pair TEXT)
  RETURNS numeric AS $$
DECLARE
  prevmonth TEXT;
  searchyear INTEGER;
  prevmonthloadnum DOUBLE PRECISION;
BEGIN
 
  IF thismonth = 'January' THEN
      prevmonth := 'December';
      searchyear := thisyear - 1;
  ELSIF thismonth = 'February' THEN
      prevmonth := 'January';
      searchyear := thisyear;
  ELSIF thismonth = 'March' THEN
      prevmonth := 'February';
      searchyear := thisyear;
  ELSIF thismonth = 'April' THEN
      prevmonth := 'March';
      searchyear := thisyear;
  ELSIF thismonth = 'May' THEN
      prevmonth := 'April';
      searchyear := thisyear;
  ELSIF thismonth = 'June' THEN
      prevmonth := 'May';
      searchyear := thisyear;
  ELSIF thismonth = 'July' THEN
      prevmonth := 'June';
      searchyear := thisyear;
  ELSIF thismonth = 'August' THEN
      prevmonth := 'July';
      searchyear := thisyear;
  ELSIF thismonth = 'September' THEN
      prevmonth := 'August';
      searchyear := thisyear;
  ELSIF thismonth = 'October' THEN
      prevmonth := 'September';
      searchyear := thisyear;
  ELSIF thismonth = 'November' THEN
      prevmonth := 'October';
      searchyear := thisyear;
  ELSIF thismonth = 'December' THEN
      prevmonth := 'November';
      searchyear := thisyear;
  ELSE
      -- hmm, the only other possibility is that the month was spelled wrong
      NULL;
  END IF;

  -- do a search on the previous month path to get the old loadnum
  EXECUTE 'SELECT load_num FROM athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy WHERE city_pair = $1 AND calendarmonth = $2 AND calendaryear = $3 LIMIT 1'
    INTO STRICT prevmonthloadnum
    USING this_city_pair, prevmonth, searchyear;
   RETURN prevmonthloadnum;
END
$$ language plpgsql
