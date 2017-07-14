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
total_dust_file='total_dust_mass.nc'
total_su_file='total_su_mass.nc'
total_bc_file='total_bc_mass.nc'
#%%

Ntotal_acc_file="Ntotal_acc.nc"
mb=netcdf.netcdf_file(nc_path+Ntotal_acc_file,'r')
mb.variables
Ntotal_acc=mb.variables['Ntotal_acc'][:]

Ntotal_coarse_file="Ntotal_coarse.nc"
mb=netcdf.netcdf_file(nc_path+Ntotal_coarse_file,'r')
mb.variables
Ntotal_coarse=mb.variables['Ntotal_coarse'][:]

radious_accmode_mo_file="radious_accmode_mo.nc"
mb=netcdf.netcdf_file(nc_path+radious_accmode_mo_file,'r')
mb.variables
radious_accmode_mo=mb.variables['radious_accmode_mo'][:]

radious_coarmode_mo_file="radious_coarmode_mo.nc"
mb=netcdf.netcdf_file(nc_path+radious_coarmode_mo_file,'r')
mb.variables
radious_coarmode_mo=mb.variables['radious_coarmode_mo'][:]



radious_accmode_file="radious_accmode.nc"
mb=netcdf.netcdf_file(nc_path+radious_accmode_file,'r')
mb.variables
radious_accmode=mb.variables['radious_accmode'][:]

radious_coarmode_file="radious_coarmode.nc"
mb=netcdf.netcdf_file(nc_path+radious_coarmode_file,'r')
mb.variables
radious_coarmode=mb.variables['radious_coarmode'][:]


submicron_sea_salt_file='sea_salt_acc.nc'
mb=netcdf.netcdf_file(nc_path+submicron_sea_salt_file,'r')
mb.variables
total_ss_acc=mb.variables['sea_salt_acc'][:]

coarse_sea_salt_file='sea_salt_coarse.nc'
mb=netcdf.netcdf_file(nc_path+coarse_sea_salt_file,'r')
mb.variables
total_ss_coar=mb.variables['sea_salt_coarse'][:]



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

mb=netcdf.netcdf_file(nc_path+total_dust_file,'r')
mb.variables
total_DUST=mb.variables['total_dust_mass'][:]

mb=netcdf.netcdf_file(nc_path+total_su_file,'r')
mb.variables
total_SU=mb.variables['total_su_mass'][:]

mb=netcdf.netcdf_file(nc_path+total_bc_file,'r')
mb.variables
total_BC=mb.variables['total_bc_mass'][:]


lat=mb.variables['lat'][:]
levels=mb.variables['levels'][:]
lon=mb.variables['lon'][:]
lon180=np.copy(lon)
lon180[lon>180]=lon[lon>180]-360

months=range(1,13)

#%%





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
# miami_dataset=miami_dataset[:]
# miami_dataset.shape


# sites=list(set(miami_dataset['site'][:]))
#
# sites_long_name=list(set(miami_dataset['site.long.name']))
# lats_miami=list(set(miami_dataset['lat']))
# lons_miami=list(set(miami_dataset['lon']))

sites=[miami_dataset['site'][i*12] for i in range(len(miami_dataset)/12)]
sites_long_name=[miami_dataset['site.long.name'][i*12] for i in range(len(miami_dataset)/12)]
lats_miami=[miami_dataset['lat'][i*12] for i in range(len(miami_dataset)/12)]
lons_miami=[miami_dataset['lon'][i*12] for i in range(len(miami_dataset)/12)]

len(lats_miami)
len(lons_miami)
len(sites_long_name)
len(sites)

dmia=OrderedDict()
dmia['month']=[]
dmia['site']=[]
dmia['site.long.name']=[]
dmia['lat']=[]
dmia['lon']=[]
dmia['MOA']=[]
dmia['TOA']=[]
dmia['BC']=[]
dmia['SO4']=[]
dmia['NCL']=[]
dmia['DST']=[]
dmia['smSS']=[]
dmia['supermSS']=[]
dmia['radious_accmode']=[]
dmia['radious_coarmode']=[]
dmia['Ntotal_acc']=[]
dmia['Ntotal_coarse']=[]
# dmia['radious_accmode_mo']=[]
# dmia['radious_coarmode_mo']=[]


dmia['total.aerosol']=[]

iobs
len(lats_miami)
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
        dmia['DST'].append(total_DUST[isurf,ilat,ilon,imonth])
        dmia['SO4'].append(total_SU[isurf,ilat,ilon,imonth])
        dmia['BC'].append(total_BC[isurf,ilat,ilon,imonth])
        dmia['smSS'].append(total_ss_acc[isurf,ilat,ilon,imonth])
        dmia['supermSS'].append(total_ss_coar[isurf,ilat,ilon,imonth])
        dmia['radious_accmode'].append(radious_accmode[isurf,ilat,ilon,imonth])
        dmia['radious_coarmode'].append(radious_coarmode[isurf,ilat,ilon,imonth])
        dmia['Ntotal_acc'].append(Ntotal_acc[isurf,ilat,ilon,imonth])
        dmia['Ntotal_coarse'].append(Ntotal_coarse[isurf,ilat,ilon,imonth])

        # dmia['radious_accmode_mo'].append(radious_accmode_mo[isurf,ilat,ilon,imonth])
        # dmia['radious_coarmode_mo'].append(radious_coarmode_mo[isurf,ilat,ilon,imonth])
        #
        dmia['total.aerosol'].append(total_AM[isurf,ilat,ilon,imonth])
        dmia['month'].append(months_str[imonth])
        dmia['site'].append(sites[iobs])
        dmia['site.long.name'].append(sites_long_name[iobs])
        # print ilat, ilon, sites_long_name[iobs]

for iobs in range(len(stp.lons)):
    for imonth in range(len(months_str)):
        lat_point=stp.lats[iobs]
        lon_point=stp.lons[iobs]

        ilat=find_nearest_vector_index(lat,lat_point)
        if lon_point<0:
            ilon=find_nearest_vector_index(lon180,lon_point)
        else:
            ilon=find_nearest_vector_index(lon,lon_point)
        data=total_TOA[isurf,ilat,ilon,imonth-1]
        dmia['lat'].append(lat_point)
        dmia['lon'].append(lon_point)
        dmia['MOA'].append(total_MOA[isurf,ilat,ilon,imonth])
        dmia['TOA'].append(total_TOA[isurf,ilat,ilon,imonth])
        dmia['NCL'].append(total_SS[isurf,ilat,ilon,imonth])
        dmia['DST'].append(total_DUST[isurf,ilat,ilon,imonth])
        dmia['SO4'].append(total_SU[isurf,ilat,ilon,imonth])
        dmia['BC'].append(total_BC[isurf,ilat,ilon,imonth])
        dmia['smSS'].append(total_ss_acc[isurf,ilat,ilon,imonth])
        dmia['supermSS'].append(total_ss_coar[isurf,ilat,ilon,imonth])
        dmia['radious_accmode'].append(radious_accmode[isurf,ilat,ilon,imonth])
        dmia['radious_coarmode'].append(radious_coarmode[isurf,ilat,ilon,imonth])
        # dmia['radious_accmode_mo'].append(radious_accmode_mo[isurf,ilat,ilon,imonth])
        # dmia['radious_coarmode_mo'].append(radious_coarmode_mo[isurf,ilat,ilon,imonth])

        dmia['Ntotal_acc'].append(Ntotal_acc[isurf,ilat,ilon,imonth])
        dmia['Ntotal_coarse'].append(Ntotal_coarse[isurf,ilat,ilon,imonth])

        dmia['total.aerosol'].append(total_AM[isurf,ilat,ilon,imonth])
        dmia['month'].append(months_str[imonth])
        dmia['site'].append(stp.names[iobs])
        dmia['site.long.name'].append(stp.names[iobs])
iobs


dmiaf=pd.DataFrame(dmia)

dmiaf.to_csv('model_data/GLOMAP_UMiami_stations.csv',mode = 'w', index=False)
















#
