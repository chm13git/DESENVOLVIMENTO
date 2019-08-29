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
DIRGFS12=${DIRWND}/gfs12/teste
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
HSTOP=4 #120

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

Nref=2
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

## consulta variaveis: /home/operador/bin/wgrib2 -header file.grb2
for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do
   cat ${WORKDIRGFS12}/u${HH}.grib2  >> ${WORKDIRGFS12}/u.grb2 
   cat ${WORKDIRGFS12}/v${HH}.grib2  >> ${WORKDIRGFS12}/v.grb2 
   ${p_wgrib2} ${WORKDIRGFS12}/u.grb2 -netcdf ${WORKDIRGFS12}/u_${HH}.nc
   ${p_wgrib2} ${WORKDIRGFS12}/v.grb2 -netcdf ${WORKDIRGFS12}/v_${HH}.nc
done

cdo mergetime ${WORKDIRGFS12}/u_*.nc ${WORKDIRGFS12}/wnd.nc
cdo mergetime ${WORKDIRGFS12}/v_*.nc ${WORKDIRGFS12}/wnd.nc

#${p_wgrib2} ${WORKDIRGFS12}/wnd.grb2 -netcdf ${WORKDIRGFS12}/wnd.nc
#cdo -f nc copy ${WORKDIRGFS12}/wnd.grb2 ${WORKDIRGFS12}/wnd.nc

## Converte variável time para 'seconds since 1970-01-01'
#time_in="$(date --date "${AMD} ${HSIM}:00:00" +%s)"
#cp ${WORKDIRGFS12}/wnd.nc ${WORKDIRGFS12}/wnd_out.nc
#${p_ncap2} -O -v -s "time=${time_in}+time*3600" ${WORKDIRGFS12}/wnd_out.nc ${WORKDIRGFS12}/wnd2.nc 
#${p_ncks} -A -h -M -m -C -v time ${WORKDIRGFS12}/wnd2.nc ${WORKDIRGFS12}/wnd_out.nc
#${p_ncatted} -O -a ,time,d,, ${WORKDIRGFS12}/wnd_out.nc # deleta atributos time
## inclui atributos nas variáveis time
#${p_ncatted} -O -a units,time,o,c,'seconds since 1970-01-01 00:00:00.0 0:00' ${WORKDIRGFS12}/wnd_out.nc 
#${p_ncatted} -O -a calendar,time,o,c,'standard' ${WORKDIRGFS12}/wnd_out.nc
#${p_ncatted} -O -a _FillValue,10u,a,f,"9.999e+20" ${WORKDIRGFS12}/wnd_out.nc -o ${WORKDIRGFS12}/wnd_out.nc 
#${p_ncatted} -O -a _FillValue,10v,a,f,"9.999e+20" ${WORKDIRGFS12}/wnd_out.nc -o ${WORKDIRGFS12}/wnd_out.nc 

# otimização arquivo
${p_nccopy} -d 7 ${WORKDIRGFS12}/wnd.nc ${WORKDIRGFS12}/wnd_cp.nc
#${p_nccopy} -d 7 ${WORKDIRGFS12}/wnd_out.nc ${WORKDIRGFS12}/wnd_cp.nc
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
