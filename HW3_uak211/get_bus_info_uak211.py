# script to print out MTA bus stop locations
# author: uak211

from __future__ import print_function
import sys
import requests

if not len(sys.argv) == 4:
    print('Error: invalid number of arguments. Run as get_bus_info_uak211.py <key> <bus_line> <bus_line>.csv')
    sys.exit()

key = sys.argv[1]
bus_line = sys.argv[2]
url = 'http://bustime.mta.info/api/siri/vehicle-monitoring.json?key='+key+'&VehicleMonitoringDetailLevel=calls&LineRef='+bus_line

data = requests.get(url).json()

try:
    bus_progress = data['Siri']['ServiceDelivery']['VehicleMonitoringDelivery'][0]['VehicleActivity']
except:
    print('Error: ' + data['Siri']['ServiceDelivery']['VehicleMonitoringDelivery'][0]['ErrorCondition']['Description'])
    sys.exit()


with open(sys.argv[3],'w') as fout:
    fout.write('Latitude,Longitude,Stop Name,Stop Status\n') 
    for i in range(len(bus_progress)):
        lat = str(bus_progress[i]['MonitoredVehicleJourney']['VehicleLocation']['Latitude'])
        long = str(bus_progress[i]['MonitoredVehicleJourney']['VehicleLocation']['Longitude'])
        if bus_progress[i]['MonitoredVehicleJourney']['OnwardCalls'] == {}:
            stop_name = 'N/A'
            stop_status = 'N/A' 
        else:
            stop_name = str(bus_progress[i]['MonitoredVehicleJourney']['MonitoredCall']['StopPointName'])
            stop_status = str(bus_progress[i]['MonitoredVehicleJourney']['OnwardCalls']['OnwardCall'][0]['Extensions']['Distances']['PresentableDistance'])
            fout.write('{},{},{},{}\n'.format(lat, long, stop_name, stop_status))
