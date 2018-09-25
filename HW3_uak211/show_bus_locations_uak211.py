# script to retrieve and report bus line activity from MTA
# @author: uak211

from __future__ import print_function
import sys
import requests

if not len(sys.argv) == 3:
    print ('Error: invalid number of arguments. Run as: python show_bus_locations_uak211.py <key> <bus_line>')
    sys.exit()

key = sys.argv[1]
bus_line = sys.argv[2]
url = 'http://bustime.mta.info/api/siri/vehicle-monitoring.json?key='+key+'&VehicleMonitoringDetailLevel=calls&LineRef='+bus_line

data = requests.get(url).json()

try:
    active_buses = data['Siri']['ServiceDelivery']['VehicleMonitoringDelivery'][0]['VehicleActivity'] 
except:
    print('Error: ' + data['Siri']['ServiceDelivery']['VehicleMonitoringDelivery'][0]['ErrorCondition']['Description'])
    sys.exit()


print('Bus Line : ' + bus_line + '\nNumber of Active Buses : ' + str(number_active_buses))

for i in range(len(number_active_buses)):
    print('Bus ' + str(i) + ' is at latitude ' + str(active_buses[i]['MonitoredVehicleJourney']['VehicleLocation']['Latitude']) + 
          ' and longtitude ' + str(active_buses[i]['MonitoredVehicleJourney']['VehicleLocation']['Longitude']))


