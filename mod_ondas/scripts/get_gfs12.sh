#!/bin/bash
##################################################
# Script que realiza o Download do vento a 10 m  #
# do GFS 12 km, horário, para a rodada WW3       #
#                                                #
# JUN2019                                        #  
# Autoras: Bruna Reis                            #
#          1T(RM2-T) Andressa D'Agostini         #     
#                                                #   
##################################################
# Carrega CDO
source ~/.bashrc

# Carrega diretórios e funções
source ~/mod_ondas/fixos/dir.sh

DIRWND=${WW3DIR}/input/vento
DIRGFS12=${DIRWND}/gfs12
DIRGFSdados12=${DIRGFS12}/dados
WORKDIRGFS12=${DIRGFSdados12}/work

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do GFS     "
   echo "               12km, horário                  "
   echo "                                              "
   echo "          ./get_gfs12.sh hh yyyymmdd          "
   echo "                                              "
   echo "       ex: ./get_gfs12.sh 00 20190716         "
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

Nref=55
Flag=0
Abort=300
nt=0

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
      URL="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${AMD}/${HSIM}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"; 
											 
      wget "${URL}" -O "${DIRGFSdados12}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"

      # CHECAGEM DO DOWNLOAD
      Nvar=`${p_wgrib2} ${DIRGFSdados12}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2 | wc -l`

      if [ ${Nvar} -lt ${Nref} ];then

         Flag=1 

         while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

            sleep 60
            echo " "
            echo " Tentando o Download novamente do gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"
            echo " "

            wget "${URL}" -O "${DIRGFSdados12}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2"
	    Nvar=`${p_wgrib2} ${DIRGFSdados12}/gfs.t${HSIM}z.sfluxgrbf${HH}.grib2 | wc -l`
            
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
   ${p_wgrib2}  ${DIRGFSdados12}/${ARQ}  | grep "UGRD:10 m above ground" | ${p_wgrib2} -i ${DIRGFSdados12}/${ARQ} -append -grib ${WORKDIRGFS12}/u${HH}.grib2
   ${p_wgrib2}  ${DIRGFSdados12}/${ARQ}  | grep "VGRD:10 m above ground" | ${p_wgrib2} -i ${DIRGFSdados12}/${ARQ} -append -grib ${WORKDIRGFS12}/v${HH}.grib2
done

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
   cat ${WORKDIRGFS12}/u${HH}.grib2  >> ${WORKDIRGFS12}/wnd.grb2 
   cat ${WORKDIRGFS12}/v${HH}.grib2  >> ${WORKDIRGFS12}/wnd.grb2 
done

${p_wgrib2} ${WORKDIRGFS12}/wnd.grb2 -netcdf ${WORKDIRGFS12}/wnd.nc

# otimização arquivo
${p_ncks} -4 -L 1 ${WORKDIRGFS12}/wnd.nc ${WORKDIRGFS12}/wnd_cp.nc
#${p_nccopy} -d 7 ${WORKDIRGFS12}/wnd.nc ${WORKDIRGFS12}/wnd_cp.nc
file_nc=gfs12.${AMD}${HSIM}.nc

mv ${WORKDIRGFS12}/wnd_cp.nc ${DIRGFS12}/${file_nc}
#mv ${WORKDIRGFS12}/wnd.grb2 ${DIRGFS12}/gfs12.${AMD}${HSIM}.grb2

# Remove arquivos desnecessários

if [ -f "${DIRGFS12}/${file_nc}" ]
then

for filename in ${DIRGFSdados12}/*; do
 rm $filename
done

for filename in ${WORKDIRGFS12}/*; do
 rm $filename
done

fi

