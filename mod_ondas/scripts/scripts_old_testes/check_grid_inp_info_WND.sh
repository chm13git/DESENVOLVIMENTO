#!/bin/bash -x
#-----------------------------------------------------#
#                                                     #
#      Script para extrair info para o grid.inp       #
#                                                     #  
# Autora: 1T(RM2-T) Andressa D'Agostini               #
# OUT2018                                             #
#-----------------------------------------------------#

# Carrega caminhos dos diretórios
source /data1/ww3desenv/home/mod_ondas/fixos/dir.sh
#DIRWND

if ! [ $# -eq 1 ];then
	echo ""
	echo " Informe o vento e a data ex: gfs 2016060300" 
	echo ""
	exit 01
fi

wnd=$1
dat=$2
 
# ----------------------------------------
# Extraindo as variaveis de interesse

if [ ${wnd} == 'gfs12'] || [ ${wnd} == 'icon12'];then

   dados=/data1/operador/mod_ondas/ww3_418/input/vento/${wnd}/
   nc_f=${dados}${vento}.dat.nc
   #ncdump -h ${nc_f} # Lista variáveis 
   #ncks -v UGRD_10maboveground -d lon,145.7292 -d lat,-40.9972 infile.nc outfile.nc # extrai pto específico
   


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
else:
   dados = '/data1/operador/mod_ondas/ww3_418/input/vento/'+vento+'/' 
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
