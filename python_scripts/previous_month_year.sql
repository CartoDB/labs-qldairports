/* 
Functions on the solutions account to calculate 
the load of the previous month and year

Check the table names to adapt to other accounts.

*/

CREATE OR REPLACE FUNCTION solutions.prevmonthload(thismonth text, thisyear integer, this_city_pair text)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
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
  
  prevmonthloadnum := -1;
  
  -- do a search on the previous month path to get the old loadnum
  EXECUTE 'SELECT load_num FROM qld_flights_lines WHERE city_pair = $1 AND calendarmonth = $2 AND calendaryear = $3 LIMIT 1'
    INTO prevmonthloadnum
    USING this_city_pair, prevmonth, searchyear;
    
  RETURN prevmonthloadnum;
END
$function$



CREATE OR REPLACE FUNCTION solutions.prevyearload(thismonth text, thisyear integer, this_city_pair text)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  prevyear INTEGER;
  prevyearloadnum DOUBLE PRECISION;
BEGIN
  prevyear := thisyear -1;
   
  -- do a search on the previous month path to get the old loadnum
  EXECUTE 'SELECT load_num FROM qld_flights_lines WHERE city_pair = $1 AND calendarmonth = $2 AND calendaryear = $3 LIMIT 1'
    INTO prevyearloadnum
    USING this_city_pair, thismonth, prevyear;
    
  RETURN prevyearloadnum;
END
$function$
