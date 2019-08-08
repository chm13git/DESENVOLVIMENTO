#!/bin/bash
##################################################
# Script que realiza o Download do vento a 10 m  #
# do GFS para a rodada WW3                       #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #
##################################################

# ---------------------------
# Definição diretórios raiz
source ~/mod_ondas/fixos/dir.sh

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do GFS     "
   echo "               27km, 3-3 horas                "
   echo "                                              "
   echo "          ./get_gfs.sh hh yyyymmdd            "
   echo "                                              "
   echo "       ex: ./get_gfs.sh 00 20190716           "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1  
HSTART=0
HSTOP=120

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi


# ---------------------
# Definição diretórios
DIRGFS=${WW3DIR}/input/vento/gfs
DIRGFSdados=${DIRGFS}/dados
GFSARQ=gfs.t${HSIM}z.pgrb2.0p25.f
WORKDIR=${DIRGFSdados}/work

Nref=2
Flag=0
Abort=300
nt=0

GFSww3Op=/data2/operador/mod_ondas/ww3_418/input/vento/gfs

if [ -e ${GFSww3Op}/gfs.${AMD}${HSIM}.nc ]; then

  cp ${GFSww3Op}/gfs.${AMD}${HSIM}.nc ${DIRGFS}/gfs.${AMD}${HSIM}.nc
  exit 1

else
  for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do
	
    URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=${GFSARQ}${HH}&\
lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${AMD}%2F${HSIM}"

    wget wget "${URL}" -O "${DIRGFSdados}/gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}"

    # CHECAGEM DO DOWNLOAD
    Nvar=`${p_wgrib2} ${DIRGFSdados}/gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH} | wc -l`

    if [ ${Nvar} -lt ${Nref} ];then

       Flag=1 

       while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

         sleep 60
         echo " "
         echo " Tentando o Download novamente do gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}"
         echo " "
         URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=${GFSARQ}${HH}&\
lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${AMD}%2F${HSIM}"

         wget wget "${URL}" -O "${DIRGFSdados}/gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}"
         Nvar=`${p_wgrib2} ${DIRGFSdados}/gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH} | wc -l`
            
         if [ ${Nvar} -lt ${Nref} ];then
           Flag=1
           echo " "
           echo " Nova tentativa de Download do dado gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}  OK"
           echo " "
         else               
           Flag=0
         fi

         nt=$((nt+1))

       done         
    else

      echo " "
      echo " Dado gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}  OK"
      echo " "

    fi

  done
fi

for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do
   ARQ=gfs.${AMD}${HSIM}.pgrb2.0p25.f${HH}
   ${p_wgrib2}  ${DIRGFSdados}/${ARQ}  | grep ":UGRD:10 m a" | ${p_wgrib2} -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIR}/u${HH}.grib2
   ${p_wgrib2}  ${DIRGFSdados}/${ARQ}  | grep ":VGRD:10 m a" | ${p_wgrib2} -i ${DIRGFSdados}/${ARQ} -append -grib ${WORKDIR}/v${HH}.grib2
done

for HH in `seq -f "%03g" ${HSTART} 3 ${HSTOP}`;do
   cat ${WORKDIR}/u${HH}.grib2  >> ${WORKDIR}/wnd.grb2 
   cat ${WORKDIR}/v${HH}.grib2  >> ${WORKDIR}/wnd.grb2 
done

${p_wgrib2} ${WORKDIR}/wnd.grb2 -netcdf ${WORKDIR}/wnd.${AMD}${HSIM}.nc
mv ${WORKDIR}/wnd.${AMD}${HSIM}.nc ${DIRGFS}/gfs.${AMD}${HSIM}.nc
mv ${WORKDIR}/wnd.grb2 ${DIRGFS}/wnd.${AMD}${HSIM}.grb2

for file in "${WORKDIR}"/*
do
  rm "$file"
done

