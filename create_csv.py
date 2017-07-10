import numpy as np
import os
os.chdir('/Users/jesusvergaratemprado/Intercomparison_code')
from src import station_properties as stp

from scipy.io import netcdf
import pandas as pd
def find_nearest_vector_index(array, value):
    n = np.array([abs(i-value) for i in array])
    nindex=np.apply_along_axis(np.argmin,0,n)
    return nindex

factor_OC2OM=1.9

nc_path='/Users/jesusvergaratemprado/OLD_GLOMAP_NC/'

total_TOA_file="total_organic_mass.nc"
total_MOA_file='wiom_acc.nc'
total_aerosol_file='total_aerosol_mass.nc'

mb=netcdf.netcdf_file(nc_path+total_TOA_file,'r')
mb.variables
total_TOA=mb.variables['total_organic_mass'][:]
mb=netcdf.netcdf_file(nc_path+total_MOA_file,'r')
mb.variables
total_MOA=mb.variables['wiom_acc'][:]
mb=netcdf.netcdf_file(nc_path+total_aerosol_file,'r')
mb.variables
total_AM=mb.variables['total_aerosol_mass'][:]

lat=mb.variables['lat'][:]
levels=mb.variables['levels'][:]
lon=mb.variables['lon'][:]
lon180=np.copy(lon)
lon180[lon>180]=lon[lon>180]-360

months=range(1,13)


from collections import OrderedDict


d=OrderedDict()
d['model']=[]
d['OA']=[]
d['OA type']=[]
d['OC']=[]
d['OC type']=[]
d['aerosol']=[]
d['aerosol type']=[]
d['month']=[]
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
            d['OA'].append(data)
            d['OA type'].append(aer_type)
            d['OC'].append(data/factor_OC2OM)
            d['OC type'].append(aer_type[:-1]+'C')
            d['aerosol'].append(data)
            d['aerosol type'].append(aer_type)
            d['month']=imonth

df=pd.DataFrame(d)

df.to_csv('formated_data.csv')
