#!/bin/bash -x
##################################################
# Script que realiza o Download do vento a 10 m  #
# do GFS para a rodada WW3                       #
#                                                #
# MAI2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
##################################################

if ! [ $# -eq 1 ];then

	echo ""
	echo " Informe o horario de simulacao (00, 12) "
	echo ""
	exit 01

fi

HSIM=$1
HSTART=00
HSTOP=120

DD=`date +"%d"`
MM=`date +"%m"`
YY=`date +"%Y"`

CURDATE=$YY$MM$DD
DIRGFS=/data1/ww3desenv/home/mod_ondas/input/vento/gfs12
DIRGFSdados=${DIRGFS}/dados
GFSARQ=gfs.t${HSIM}z.pgrb2.0p25.f
WORKDIR=${DIRGFSdados}/work

Nref=2
Flag=0
Abort=300
nt=0

for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do

      URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=${GFSARQ}${HH}&\
lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${CURDATE}%2F${HSIM}"

	wget wget "${URL}" -O "${DIRGFSdados}/gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}"

      # CHECAGEM DO DOWNLOAD
      Nvar=`/home/operador/bin/wgrib2 ${DIRGFSdados}/gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH} | wc -l`

      if [ ${Nvar} -lt ${Nref} ];then

         Flag=1 

         while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

            sleep 60
            echo " "
            echo " Tentando o Download novamente do gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}"
            echo " "

            URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=${GFSARQ}${HH}&\
lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${CURDATE}%2F${HSIM}"

            wget wget "${URL}" -O "${DIRGFSdados}/gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}"
            Nvar=`/home/operador/bin/wgrib2 ${DIRGFSdados}/gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH} | wc -l`
            
            if [ ${Nvar} -lt ${Nref} ];then
               Flag=1
            else               
               Flag=0
               echo " "
               echo " Nova tentativa de Download do dado gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}  OK"
               echo " "
            fi

            nt=$((nt+1))

         done         
      else
         echo " "
         echo " Dado gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}  OK"
         echo " "
      fi
done

# consulta variaveis: 
# lista var 30
# /home/operador/bin/wgrib2 -V -d 30 gfs.t00z.sfluxgrbf000.grib2
# lista variaveis com U no nome
# /home/operador/bin/wgrib2 gfs.t00z.sfluxgrbf000.grib2 | grep "U"

for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do
   ARQ=gfs.${CURDATE}${HSIM}.pgrb2.0p25.f${HH}
   /home/operador/bin/wgrib2  ${DIRGFSdados}/${ARQ}  | grep ":UGRD:10 m a" | /home/operador/bin/wgrib2 -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIR}/u${HH}.grib2
   /home/operador/bin/wgrib2  ${DIRGFSdados}/${ARQ}  | grep ":VGRD:10 m a" | /home/operador/bin/wgrib2 -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIR}/v${HH}.grib2
done

for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do
   cat ${WORKDIR}/u${HH}.grib2  >> ${WORKDIR}/wnd.grb2 
   cat ${WORKDIR}/v${HH}.grib2  >> ${WORKDIR}/wnd.grb2 
done

/home/operador/bin/wgrib2 ${WORKDIR}/wnd.grb2 -netcdf ${WORKDIR}/wnd.${CURDATE}${HSIM}.nc
mv ${WORKDIR}/wnd.${CURDATE}${HSIM}.nc ${DIRGFS}/gfs.${CURDATE}${HSIM}.nc
mv ${WORKDIR}/wnd.grb2 ${DIRGFS}/wnd.${CURDATE}${HSIM}.grb2

for file in "${WORKDIR}"/*
do
  rm "$file"
done


