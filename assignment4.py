# import urllib.request
# import json
# from pprint import pprint

# url = "https://maps.googleapis.com/maps/api/geocode/json?address=Prudential%20Tower"
# f = urllib.request.urlopen(url)
# response_text = f.read().decode('utf-8')
# response_data = json.loads(response_text)

# pprint(response_data)

import urllib.request
import urllib.parse
import json


def georequest (place):
    d = {}
    k = 0
    p = place_name.split (", ")
    
    for i in p:
        d[i] = 0
        
    params = urllib.parse.urlencode(d)
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=%s" % params
    # print (url)
    # print(d)
    f = urllib.request.urlopen(url)
    response_text = f.read().decode('utf-8')
    response = json.loads(response_text)
    return response     







resppp = (georequest ("231 forest street, Babson Park, MA 02457"))


print (location(resppp))

def busstop(lat, lng):
    d = {}
    k = 0
    apikey = "wX9NwuHnZU2ToO7GmGR9uw"
    params = ("api_key=" + apikey +
             "&lat=" + str(lat) +
             "&lon=" + str(lng) +
             "&format=json")

    url = "http://realtime.mbta.com/developer/api/v2/stopsbylocation?%s" % params


    with urllib.request.urlopen(url) as f:
        p = eval (f.read().decode("utf-8"))
    name = p["stop"][0]['stop_name']
    distance = p["stop"][0]['distance']
    return name, distance

# print (busstop(42.352913,-71.064648))

    # for i in range (len(p["stop"])):
    #     print (p["stop"][i]['distance'])

# p ={"stop":[{"stop_id":"70159","stop_name":"Boylston - Outbound","parent_station":"place-boyls","parent_station_name":"Boylston","stop_lat":"42.35302","stop_lon":"-71.06459","distance":"0.00800655130296946"},{"stop_id":"70158","stop_name":"Boylston - Inbound","parent_station":"place-boyls","parent_station_name":"Boylston","stop_lat":"42.35302","stop_lon":"-71.06459","distance":"0.00800655130296946"},{"stop_id":"place-boyls","stop_name":"Boylston","parent_station":"","parent_station_name":"","stop_lat":"42.35302","stop_lon":"-71.06459","distance":"0.00800655130296946"},{"stop_id":"8279","stop_name":"Tremont St @ Boylston Station","parent_station":"","parent_station_name":"","stop_lat":"42.353247","stop_lon":"-71.064353","distance":"0.0277116596698761"},{"stop_id":"70019","stop_name":"Chinatown - Inbound","parent_station":"place-chncl","parent_station_name":"Chinatown","stop_lat":"42.352547","stop_lon":"-71.062752","distance":"0.100191049277782"},{"stop_id":"70018","stop_name":"Chinatown - Outbound","parent_station":"place-chncl","parent_station_name":"Chinatown","stop_lat":"42.352547","stop_lon":"-71.062752","distance":"0.100191049277782"},{"stop_id":"place-chncl","stop_name":"Chinatown","parent_station":"","parent_station_name":"","stop_lat":"42.352547","stop_lon":"-71.062752","distance":"0.100191049277782"},{"stop_id":"6567","stop_name":"Washington St @ Essex St","parent_station":"","parent_station_name":"","stop_lat":"42.352461","stop_lon":"-71.062552","distance":"0.11149089038372"},{"stop_id":"6537","stop_name":"Washington St @ Essex St","parent_station":"","parent_station_name":"","stop_lat":"42.352288","stop_lon":"-71.062581","distance":"0.114014588296413"},{"stop_id":"91856","stop_name":"Stuart St @ Tremont St","parent_station":"","parent_station_name":"","stop_lat":"42.351136","stop_lon":"-71.064763","distance":"0.122894078493118"},{"stop_id":"1241","stop_name":"Charles St S @ Park Plaza","parent_station":"","parent_station_name":"","stop_lat":"42.351748","stop_lon":"-71.067101","distance":"0.148577779531479"},{"stop_id":"6542","stop_name":"Kneeland St @ Washington St","parent_station":"","parent_station_name":"","stop_lat":"42.350845","stop_lon":"-71.062868","distance":"0.16936793923378"},{"stop_id":"9983","stop_name":"Stuart St @ Charles St S","parent_station":"","parent_station_name":"","stop_lat":"42.351039","stop_lon":"-71.066798","distance":"0.169407889246941"},{"stop_id":"49001","stop_name":"Temple Pl @ Washington St","parent_station":"","parent_station_name":"","stop_lat":"42.355385","stop_lon":"-71.062211","distance":"0.211329147219658"},{"stop_id":"10000","stop_name":"Tremont St opp Temple Pl","parent_station":"","parent_station_name":"","stop_lat":"42.355692","stop_lon":"-71.062911","distance":"0.21155971288681"}]}



# print (p["stop"][0]["stop_name"])
# print (p["stop"][0]["distance"])

# def findbusstop(location):
#     k = georequest(location)
#     lat, lng = location (k)
#     return busstop(lat, lng)