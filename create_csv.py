import numpy as np
import os
os.chdir('/Users/jesusvergaratemprado/Intercomparison_code')
from src import station_properties as stp
stp.names
from scipy.io import netcdf
import pandas as pd
from collections import OrderedDict
def find_nearest_vector_index(array, value):
    n = np.array([abs(i-value) for i in array])
    nindex=np.apply_along_axis(np.argmin,0,n)
    return nindex

factor_OC2OM=1.9

nc_path='/Users/jesusvergaratemprado/OLD_GLOMAP_NC/'

total_TOA_file="total_organic_mass.nc"
total_MOA_file='wiom_acc.nc'
total_aerosol_file='total_aerosol_mass.nc'
total_sea_salt_file='total_sea_salt.nc'

mb=netcdf.netcdf_file(nc_path+total_TOA_file,'r')
mb.variables
total_TOA=mb.variables['total_organic_mass'][:]


mb=netcdf.netcdf_file(nc_path+total_MOA_file,'r')
mb.variables
total_MOA=mb.variables['wiom_acc'][:]


mb=netcdf.netcdf_file(nc_path+total_aerosol_file,'r')
mb.variables
total_AM=mb.variables['total_aerosol_mass'][:]

mb=netcdf.netcdf_file(nc_path+total_sea_salt_file,'r')
mb.variables
total_SS=mb.variables['total_sea_salt'][:]

#%%

lat=mb.variables['lat'][:]
levels=mb.variables['levels'][:]
lon=mb.variables['lon'][:]
lon180=np.copy(lon)
lon180[lon>180]=lon[lon>180]-360

months=range(1,13)




d=OrderedDict()
d['model']=[]
d['OA']=[]
d['OAtype']=[]
d['OC']=[]
d['OCtype']=[]
d['aerosol']=[]
d['aerosoltype']=[]
d['month']=[]
d['station']=[]
d['lat']=[]
d['lon']=[]

iobs=54
isurf=30
types=["TOA","MOA"]
for iobs in range(len(stp.lons)):
    for imonth in months:

        for aer_type in types:
            # print iobs
            lat_point=stp.lats[iobs]
            lon_point=stp.lons[iobs]

            ilat=find_nearest_vector_index(lat,lat_point)
            if lon_point<0:
                ilon=find_nearest_vector_index(lon180,lon_point)
            else:
                ilon=find_nearest_vector_index(lon,lon_point)

            if aer_type is "MOA":data=total_MOA[isurf,ilat,ilon,imonth-1]
            if aer_type is "TOA":data=total_TOA[isurf,ilat,ilon,imonth-1]
            d['model'].append('GLOMAP')
            d['lat'].append(lat_point)
            d['lon'].append(lon_point)
            d['OA'].append(data*1e3)#ng/m3
            d['OAtype'].append(aer_type)
            d['OC'].append(data/factor_OC2OM*1e3)#ng/m3
            d['OCtype'].append(aer_type[:-1]+'C')
            d['aerosol'].append(data)
            d['aerosoltype'].append(aer_type)
            d['month'].append(imonth)
            d['station'].append(stp.names[iobs])

df=pd.DataFrame(d)

df.to_csv('model_data/GLOMAP_TOA_station.csv',mode = 'w', index=False)


#%%
months_str=["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]

miami_dataset=pd.read_csv('model_data/ACMEv0-OCEANFILMS_mix3_UMiami_stations.csv')
sites=list(set(miami_dataset['site'][:]))
sites_long_name=list(set(miami_dataset['site.long.name']))
lats_miami=list(set(miami_dataset['lat']))
lons_miami=list(set(miami_dataset['lon']))
len(lats_miami)
len(lons_miami)
len(sites_long_name)

dmia=OrderedDict()
dmia['month']=[]
dmia['site']=[]
dmia['site.long.name']=[]
dmia['lat']=[]
dmia['lon']=[]
dmia['MOA']=[]
dmia['TOA']=[]
dmia['NCL']=[]
dmia['total.aerosol']=[]


for iobs in range(len(sites)):
    for imonth in range(len(months_str)):

        # print iobs
        lat_point=lats_miami[iobs]
        lon_point=lons_miami[iobs]

        ilat=find_nearest_vector_index(lat,lat_point)
        if lon_point<0:
            ilon=find_nearest_vector_index(lon180,lon_point)
        else:
            ilon=find_nearest_vector_index(lon,lon_point)

        data=total_MOA[isurf,ilat,ilon,imonth-1]
        dmia['lat'].append(lat_point)
        dmia['lon'].append(lon_point)
        dmia['MOA'].append(total_MOA[isurf,ilat,ilon,imonth])
        dmia['TOA'].append(total_TOA[isurf,ilat,ilon,imonth])
        dmia['NCL'].append(total_SS[isurf,ilat,ilon,imonth])
        dmia['total.aerosol'].append(total_AM[isurf,ilat,ilon,imonth])
        dmia['month'].append(month_str[imonth])
        dmia['site'].append(sites[iobs])
        dmia['site.long.name'].append(sites_long_name[iobs])

dmiaf=pd.DataFrame(dmia)

dmiaf.to_csv('model_data/GLOMAP_UMiami_stations.csv',mode = 'w', index=False)
















#
