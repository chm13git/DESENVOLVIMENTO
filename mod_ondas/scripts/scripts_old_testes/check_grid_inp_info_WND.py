#!/usr/local/lib/.pyenv/versions/anaconda3-5.1.0/bin/python
# -*- coding: utf-8 -*-
# -*- coding: iso-8859-1 -*-
#-----------------------------------------------------#
#                                                     #
#      Script para extrair info para o grid.inp       #
#                                                     #  
# Autora: 1T(RM2-T) Andressa D'Agostini               #
# OUT2018                                             #
#-----------------------------------------------------#

import datetime, time
import os, sys, shutil
PATHWND='/data1/ww3desenv/home/mod_ondas/input/vento/'
os.chdir('/data1/ww3desenv/home/mod_ondas/input/vento/')
os.getcwd()

if len(sys.argv) < 2:
    print('+------------Utilização--------------+')
    print('                                      ')
    print(' check_grid_inp_WND.py Vento DataHH   ')
    print('                                      ')
    print('  ex: '+sys.argv[0]+' gfs 2019070100')
    print('+------------------------------------+')
    sys.exit(1)

vento = sys.argv[1]
datahh  = sys.argv[2]

import numpy as np
from netCDF4 import Dataset
import scipy
from numpy import ma
import os

# ----------------------------------------
# Extraindo as variaveis de interesse

if (vento == 'gfs') or (vento == 'icon'):
   dados = '/data1/ww3desenv/home/mod_ondas/input/vento/'+vento+'/' 
   nc_f=dados+vento+'.'+datahh+'.nc'
   nc_fid=Dataset(nc_f, 'r')
   lat=nc_fid.variables['latitude'][:]
   lon=nc_fid.variables['longitude'][:]
   size_lon=np.size(lon); size_lat=np.size(lat)
   res_y=lon[1]-lon[0]; res_x=lat[1]-lat[0]
   lon_min=lon[0]; lat_min=lat[0]
   pts=size_lon*size_lat 
   print('')
   print(' Pontos em Y (lon) = '+str(size_lon))
   print(' Pontos em X (lat) = '+str(size_lat))
   print(' Resolucao em Y (em graus) = '+str(res_y))
   print(' Resolucao em X (em graus) = '+str(res_x))
   print(' Lon min = '+str(lon_min))
   print(' Lat min = '+str(lat_min))
   print(' Numero total de pontos = '+str(pts))
   print('')
elif (vento == 'gfs12') or (vento == 'icon13'):
   dados = '/data1/ww3desenv/home/mod_ondas/input/vento/'+vento+'/' 

   if (vento == 'gfs12'):
      nc_f=dados+'gfs12.'+datahh+'.nc'
   else:
      nc_f=dados+'icon13.'+datahh+'.nc'

   nc_fid=Dataset(nc_f, 'r')
   
   if (vento == 'icon13'):
      lat=nc_fid.variables['lat'][:]
      lon=nc_fid.variables['lon'][:]
   else:
      lat=nc_fid.variables['latitude'][:]
      lon=nc_fid.variables['longitude'][:]

   size_lon=np.size(lon); size_lat=np.size(lat)
   res_y=lon[1]-lon[0]; res_x=lat[1]-lat[0]
   lon_min=lon[0]; lat_min=lat[0]
   lon_max=lon[-1]; lat_max=lat[-1]
   pts=size_lon*size_lat 
   print('')
   print(' Pontos em Y (lon) = '+str(size_lon))
   print(' Pontos em X (lat) = '+str(size_lat))
   print(' Resolucao em Y (em graus) = '+str(res_y))
   print(' Resolucao em X (em graus) = '+str(res_x))
   print(' Lon min = '+str(lon_min))
   print(' Lat min = '+str(lat_min))
   print(' Lon max = '+str(lon_max))
   print(' Lat max = '+str(lat_max))
   print(' Numero total de pontos = '+str(pts))
   print('')
else:
   dados = '/data1/ww3desenv/home/mod_ondas/input/vento/'+vento+'/' 
   nc_f=dados+vento+'.'+datahh+'.nc'
   nc_fid=Dataset(nc_f, 'r')
   X=nc_fid.variables['x'][:]; Y=nc_fid.variables['y'][:]
   lat=nc_fid.variables['latitude'][:]; lon=nc_fid.variables['longitude'][:]
   size_x=np.size(X); size_y=np.size(Y)
   lon0=lon[0];lon1=lon[1];lat0=lat[0];lat1=lat[1];
   res_y=lon0[1]-lon0[0]; res_x=lat1[0]-lat0[0]
   lon1=lon[0]; lon_min=lon1[0] 
   lat1=lat[0]; lat_min=lat1[0]
   pts=size_y*size_x  
   print('')
   print(' Pontos em Y (lon) = '+str(size_y))
   print(' Pontos em X (lat) = '+str(size_x))
   print(' Resolucao em Y (em graus) = '+str(res_y))
   print(' Resolucao em X (em graus) = '+str(res_x))
   print(' Lon min = '+str(lon_min))
   print(' Lat min = '+str(lat_min))
   print(' Numero total de pontos = '+str(pts))
   print('')

quit()
