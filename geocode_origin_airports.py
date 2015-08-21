from cartodb import CartoDBAPIKey, CartoDBException
import requests

"""
http://ws.geonames.org/searchJSON?name_equals=MAN&fcode=AIRP&formatted=tr&lang=iata&username=demo

update table set the_geom = null
"""

API_KEY = '4783cb66597703480951f8f2259bfa7a616a7c9c'
cartodb_domain = 'athompson'
cl = CartoDBAPIKey(API_KEY, cartodb_domain)
iata_codes_origin = []

"""
End goal: SQL UPDATE query with a GeomAsWKT(POINT(),4326) to the_geom for each origin airport
x2 for each destination airport (in new table).

1. Get IATA code
2. Get lat/lng from code (geocoder)
3. Wrap lat/lng in POINT() syntax string 
4. SQL UPDATE with Point to the_geom

Optimizations:
Once I have a geocode for an IATA, I don't need to call the geocoder again if I store it somehow
Once I have an IATA, I only need to issue one UPDATE for all rows of it.

1. list = Select iata from table where the_geom is null
2. for iata in list,
	3. get a geocode, make a POINT()
	4. SQL UPDATE where iata=this_one, set the_geom to this POINT()

"""

def iata_wkt_geocoder(iata_code):
	print "geocoding iata airport: " + iata_code
	r = requests.get('http://ws.geonames.org/searchJSON?name_equals=' +
								iata_code + '&fcode=AIRP&formatted=tr&lang=iata&username=demo')
	geoinfo = r.json()
	print geoinfo
	if geoinfo['totalResultsCount'] == 0:
		raise CartoDBException('code ' + iata_code + 'not geocodeable')
	else:
		lat = geoinfo['geonames'][0]['lat']
		lng = geoinfo['geonames'][0]['lng']
		wkt = "'POINT(" + lng + ' ' + lat + ")'"
		return wkt

try:
	print "Grabbing origins"
	iata_origin = cl.sql("select distinct origin_city from athompson.flight_cube_query_09_06_15_origins")
	print "Origins grabbed!"
except CartoDBException as e:
	print ("some error occured with origin grab", e)

for row in iata_origin['rows']:
	iata_codes_origin.append(row['origin_city'])

try:
	print "Geocoding origins"
	for code in iata_codes_origin:
		if code in ['TEV', 'OSB']:
			print "passing " + code
			pass
		else:
			print "geocoding origin " + code
			iata_wkt_point = iata_wkt_geocoder(code)
			print "geocode good, now for update " + code
			query = ("update athompson.flight_cube_query_09_06_15_origins set the_geom = ST_GeomFromText(" +
					iata_wkt_point + ",4326) where origin_city like '" + code + "'")
			print query
			update_origin = cl.sql(query)
			print "update good " + code
	print "Origins geocoded and updated in CartoDB!"
except CartoDBException as e:
	print ("some error occured with origin geocode", e)

print "We're done!"