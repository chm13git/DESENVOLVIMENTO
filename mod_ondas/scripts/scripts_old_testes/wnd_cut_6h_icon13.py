#!/data1/ww3desenv/home/anaconda3/bin/python
# -*- coding: utf-8 -*-
# -*- coding: iso-8859-1 -*-

#---------------------------------------------------#
#   Script para gerar as forçantes de vento com a   #
#   análise de 12 horas                             #
#                                                   #  
# Autora: 1T(RM2-T) Andressa D'Agostini             #
# OUT_2018                                          #
#---------------------------------------------------#

import datetime, time
import os, sys, shutil
from  ww3Funcs import  horarios
import numpy as np
from pylab import *
import netCDF4 as nc
from netCDF4 import Dataset
import pickle

if len(sys.argv) < 2:
    print('+------------Utilização------------+')
    print('                                    ')
    print('         wnd_cut_12hrs.py wnd       ')
    print('                                    ')
    print('ex: '+sys.argv[0]+' gfs/icon/cosmo  ')
    print('+----------------------------------+')
    sys.exit(1)

wnd=sys.argv[1]
cyc  = ['00','12']
b = horarios('20170808')
base=datetime.date(int(b[0]),int(b[1]),int(b[2]))
numdays = 6
date_list = [base + datetime.timedelta(days=x) for x in range(0, numdays)]

ww3dir = '/data1/ww3desenv/home/mod_ondas/testes/'
ventodir = ww3dir+'input/vento/'+wnd+'/'
gelodir  = ww3dir+'input/gelo/'
workdir  = ww3dir+'work/'

# Setando o intervalo de 12 horas
if (wnd=='gfs'):
   intWND=4     # Vento 3h-3h 
   uwnd='UGRD_10maboveground'
   vwnd='VGRD_10maboveground'
elif (wnd=='icon'):
   intWND=2     # Vento 6h-6h
   uwnd='var0_2_2_10maboveground'
   vwnd='var0_2_3_10maboveground'
else: #(wnd=='cosmo')
   intWND=12    # Vento 1h-1h
   uwnd='UGRD_10maboveground'
   vwnd='VGRD_10maboveground'

dt=date_list[0]
dti=dt.strftime('%Y%m%d')
dt=date_list[-1]
dtf=dt.strftime('%Y%m%d')

dados = ventodir+wnd+'.'+dti+'00.nc'
nc_fid=Dataset(dados, 'r')

if (wnd=='cosmo'):
   lat=nc_fid.variables['latitude'][:,0]
   lon=nc_fid.variables['longitude'][0,:]
else:
   lat=nc_fid.variables['latitude'][:]
   lon=nc_fid.variables['longitude'][:]


UWND=[];VWND=[]; TIME=[]
for tt in range(0,numdays):
   aux=date_list[tt]
   dt=aux.strftime('%Y%m%d')
   for cc in range(0,np.size(cyc)):
      ciclo=cyc[cc]
      if (dt == dtf) and (ciclo == '00'):
         dados = ventodir+wnd+'.'+dt+ciclo+'.nc'
         nc_fid=Dataset(dados, 'r')
         u=[];v=[]
         u=nc_fid.variables[uwnd][0:1]
         v=nc_fid.variables[vwnd][0:1]
         time=nc_fid.variables['time'][0:1]
         UWND.extend(u)
         VWND.extend(v)
         TIME.extend(time)
      elif (dt == dtf) and (ciclo == '12'):
         pass
      else:
         dados = ventodir+wnd+'.'+dt+ciclo+'.nc'
         nc_fid=Dataset(dados, 'r')
         u=[];v=[]
         u=nc_fid.variables[uwnd][0:intWND]
         v=nc_fid.variables[vwnd][0:intWND]
         time=nc_fid.variables['time'][0:intWND]
         UWND.extend(u)
         VWND.extend(v)
         TIME.extend(time)


#Salvando ventos em netcdf
fnetcdf="NETCDF4"
name=wnd+'.'+dti+'_'+dtf+'.nc'
ncfile = nc.Dataset(name, "w", format=fnetcdf) 
ncfile.history=" Vento concatenado na análise (12h em 12h) "
ncfile.author = " Andressa D Agostini "

ncfile.createDimension( 'time' , np.size(TIME)) 
ncfile.createDimension( 'latitude' , np.size(lat)) 
ncfile.createDimension( 'longitude' , np.size(lon)) 

ftime = ncfile.createVariable('time',dtype('float64').char,('time',)) 
flat = ncfile.createVariable('latitude',dtype('float32').char,('latitude',)) 
flon = ncfile.createVariable('longitude',dtype('float32').char,('longitude',)) 
# units
ftime.units = 'seconds since 1970-01-01 00:00:00'; ftime.calendar = "gregorian"
flat.units = 'degrees_north'; flon.units = 'degrees_east'
# write data to coordinate vars.
flat[:] = lat ; flon[:] = lon ; ftime[:] = TIME
# create  variable
fuwnd = ncfile.createVariable('u10',dtype('float32').char,('time','latitude','longitude'),fill_value=0)
fvwnd = ncfile.createVariable('v10',dtype('float32').char,('time','latitude','longitude'),fill_value=0)
# write data to variables.
fuwnd[:,:,:]=UWND;  fvwnd[:,:,:]=VWND
# close the file
ncfile.close()
print('  --- netcdf ok')
