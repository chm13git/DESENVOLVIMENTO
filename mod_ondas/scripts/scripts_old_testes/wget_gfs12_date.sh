#!/bin/bash -x
##################################################
# Script que realiza o Download do vento a 10 m  #
# do GFS para a rodada WW3                       #
#                                                #
# JUN2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
#           Bruna Reis                           #
##################################################

# Carrega caminhos dos diretórios
source /data1/ww3desenv/home/mod_ondas/fixos/dir.sh

if ! [ $# -eq 1 ];then

	echo ""
	echo " Informe o horario de simulacao (00, 12) " 
	echo ""
	exit 01

fi

HSIM=$1  
HSTART=0
HSTOP=120

DD=08
MM=07
YYYY=2019
CURDATE=$YYYY$MM$DD

Nref=2
Flag=0
Abort=300
nt=0

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
      URL="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$YYYY$MM$DD/${HSIM}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"; 
											 
      wget "${URL}" -O "${DIRGFSdados}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"

      # CHECAGEM DO DOWNLOAD
      Nvar=`/home/operador/bin/wgrib2 ${DIRGFSdados}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2 | wc -l`

      if [ ${Nvar} -lt ${Nref} ];then

         Flag=1 

         while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

            sleep 60
            echo " "
            echo " Tentando o Download novamente do gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"
            echo " "

            wget "${URL}" -O "${DIRGFSdados}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"
	    Nvar=`/home/operador/bin/wgrib2 ${DIRGFSdados}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2 | wc -l`
            
            if [ ${Nvar} -lt ${Nref} ];then
               Flag=1
            else               
               Flag=0
               echo " "
               echo " Nova tentativa de Download do dado gfs.t${HSIM}z.sfluxgrbf${HH}.grib2  OK"
               echo " "
            fi

            nt=$((nt+1))

         done         
      else
         echo " "
         echo " Dado gfs.t${HSIM}z.sfluxgrbf${HH}.grib2 OK"
         echo " "
      fi
done

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
   ARQ=gfs.t${HSIM}z.sfluxgrbf${HH}.grib2
   /home/operador/bin/wgrib2  ${DIRGFSdados}/${ARQ}  | grep "UGRD:10 m above ground" | /home/operador/bin/wgrib2 -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIRGFS}/u${HH}.grib2
   /home/operador/bin/wgrib2  ${DIRGFSdados}/${ARQ}  | grep "VGRD:10 m above ground" | /home/operador/bin/wgrib2 -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIRGFS}/v${HH}.grib2
done

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
   cat ${WORKDIRGFS}/u${HH}.grib2  >> ${WORKDIRGFS}/wnd.grb2 
   cat ${WORKDIRGFS}/v${HH}.grib2  >> ${WORKDIRGFS}/wnd.grb2 
done

/home/operador/bin/wgrib2 ${WORKDIRGFS}/wnd.grb2 -netcdf ${WORKDIRGFS}/wnd.${CURDATE}.nc
mv ${WORKDIRGFS}/wnd.${CURDATE}.nc ${DIRGFS}/gfs.${CURDATE}${HSIM}.nc
mv ${WORKDIRGFS}/wnd.grb2 ${DIRGFS}/gfs.${CURDATE}${HSIM}.grb2


for file in "${WORKDIRGFS}"/*
do
  rm "$file"
done

for file in "${DIRGFSdados}"/*
do
  rm "$file"
done

