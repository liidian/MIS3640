import urllib.request   # urlencode function
import json


# Useful URLs (you need to add the appropriate parameters for your requests)
GMAPS_BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
MBTA_BASE_URL = "http://realtime.mbta.com/developer/api/v2/stopsbylocation"
MBTA_DEMO_API_KEY = "wX9NwuHnZU2ToO7GmGR9uw"


# A little bit of scaffolding if you want to use it

def get_json(url):
    """
    Given a properly formatted URL for a JSON web API request, return
    a Python JSON object containing the response to that request.
    """
    pass


def get_lat_long(place_name):
    """
    Given a place name or address, return a (latitude, longitude) tuple
    with the coordinates of the given place.
    See https://developers.google.com/maps/documentation/geocoding/
    for Google Maps Geocode API URL formatting requirements.
    """
    pass


def get_nearest_station(latitude, longitude):
    """
    Given latitude and longitude strings, return a (station_name, distance)
    tuple for the nearest MBTA station to the given coordinates.
    See http://realtime.mbta.com/Portal/Home/Documents for URL
    formatting requirements for the 'stopsbylocation' API in 'MBTA-realtime API v2 Documentation'.
    """
    d = {}
    k = 0
    # apikey = "wX9NwuHnZU2ToO7GmGR9uw"
    global MBTA_DEMO_API_KEY
    params = ("api_key=" + MBTA_DEMO_API_KEY +
             "&lat=" + str(latitude) +
             "&lon=" + str(longitude) +
             "&format=json")

    url = "http://realtime.mbta.com/developer/api/v2/stopsbylocation?%s" % params


    with urllib.request.urlopen(url) as f:
        p = (f.read().decode("utf-8"))
    type (p)
    # print (p)
    
    # for i in range (len(p[0]["stop"])):
    #     print (p[0]["stop"][i]['distance'])

get_nearest_station (42.352913,-71.064648)

def find_stop_near(place_name):
    """
    Given a place name or address, return the nearest MBTA stop and the 
    distance from the given place to that stop.
    """
    pass