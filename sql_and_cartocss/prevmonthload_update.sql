CREATE OR REPLACE FUNCTION athompson.abt_flight_cube_dests_corrected_workingcopy_prevmonthload_updat(thismonth text, thisyear integer, this_city_pair text)
 RETURNS double precision
 LANGUAGE plpgsql
AS $function$
DECLARE
  prevmonth TEXT;
  searchyear INTEGER;
  prevmonthloadnum DOUBLE PRECISION;
  resultcount INTEGER;
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
  ELSE      NULL;
  END IF;  resultcount := (SELECT count(load_num) FROM athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy WHERE city_pair = this_city_pair AND calendarmonth = prevmonth AND calendaryear = searchyear);

  IF resultcount = 1 THEN
      prevmonthloadnum := (SELECT load_num FROM athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy WHERE city_pair = this_city_pair AND calendarmonth = prevmonth AND calendaryear = searchyear);
      EXECUTE 'UPDATE athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy SET prevmonthload = '
        || quote_literal(prevmonthloadnum)
        || 'WHERE city_pair = ' 
        || quote_literal(this_city_pair)
        || 'AND calendarmonth = '
        || quote_literal(thismonth)
        || 'AND calendaryear = '
        || quote_literal(thisyear);
  ELSE
    prevmonthloadnum := 1000;
    EXECUTE 'UPDATE athompson.flight_cube_query_09_06_15_dests_corrected_workingcopy SET prevmonthload = '
      || quote_literal(prevmonthloadnum)
      || 'WHERE city_pair = ' 
      || quote_literal(this_city_pair)
      || 'AND calendarmonth = '
      || quote_literal(thismonth)
      || 'AND calendaryear = '
      || quote_literal(thisyear);
  END IF;

  RETURN prevmonthloadnum;
END
$function$
