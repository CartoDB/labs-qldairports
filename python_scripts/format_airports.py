from cartodb import CartoDBAPIKey, CartoDBException

'''
UPDATE athompson.flight_cube_query_09_06_15 SET origin_city = 'ISA' where city_pair like 'ISA%';
select * from athompson.flight_cube_query_09_06_15 where origin_city is null order by city_pair asc
'''

API_KEY = '4783cb66597703480951f8f2259bfa7a616a7c9c'
cartodb_domain = 'athompson'
cl = CartoDBAPIKey(API_KEY, cartodb_domain)
iata_codes_origin = []
iata_codes_dest = []

try:
	print "Grabbing origins"
	pair_origin = cl.sql("select distinct substring(city_pair from '^.{3}') from athompson.flight_cube_query_09_06_15")
	print "Origins grabbed!"
except CartoDBException as e:
	print ("some error occured with origin grab", e)

for row in pair_origin['rows']:
	iata_codes_origin.append(row['substring'])

try:
	print "Origins processed, pushing updates to cartodb"
	for code in iata_codes_origin:
		print "updating origin " + code
		update_origin = cl.sql("update athompson.flight_cube_query_09_06_15 set origin_city = '" + code + 
								"' where city_pair like '" + code + "%'")
	print "Origins updated in CartoDB!"
except CartoDBException as e:
	print ("some error occured with origin update", e)

try:
	print "Grabbing destinations"
	pair_dest = cl.sql("select distinct substring(city_pair from '.{3}$') from athompson.flight_cube_query_09_06_15")
	print "Destinations grabbed!"
except CartoDBException as e:
	print ("some error occured with destinations grab", e)

for row in pair_dest['rows']:
	iata_codes_dest.append(row['substring'])

try:
	print "Dests processed, pushing updates to CartoDB!"
	for code in iata_codes_dest:
		print "updating dest " + code
		update_dest = cl.sql("update athompson.flight_cube_query_09_06_15 set destination_city = '" + code +
								"' where city_pair like '%" + code + "'")
	print "Dests updated in CartoDB!"
except CartoDBException as e:
	print ("some error occured with destinations update", e)

print "We're done!"