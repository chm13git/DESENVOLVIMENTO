#!/bin/bash -x

############################################
#
# Este é o local onde atualmente pegamos os dados do GFS. Será preciso alterar o URL do get_gfs.pl se o local do dado mudar.
# URL='https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$YYYY$MM$DD$HH/'
#
# Este é o nome do grib que é baixado e encontrado no get_gfs.pl
# grb='gfs.t${HH}z.pgrb2.0p25.f${HREF}'
#
#############################################################################################

if ! [ $# -eq 1 ]
then
        echo
        echo " Entre com o horario de simulacao (00, 12) "
        echo
        exit
fi

# Carrega CDO
source ~/.bashrc

# Carrega diretórios e funções
source ~/mod_ondas/fixos/dir.sh

HH=$1
HSTART=0
HSTOP=3 #120

if [ $# -eq 1 ]; then
   datacorrente=`cat ~/datas/datacorrente${HH}`
elif [ $# -eq 2 ]; then
   datacorrente=$2
fi

#datacorrente=`date +%Y%m%d`
dir_scripts="/data1/ww3desenv/home/mod_ondas/scripts/gfs12"
mkdir ${dir_scripts}/gfs12.${datacorrente}
dir_output=${dir_scripts}/gfs12.${datacorrente}

############
# VAR = A lista de variáveis que o WRF necessita do downloado dos dados do GFS
VAR="UGRD:VGRD"
LEV='10_m'
######################################################
Nref=2
Flag=0
Abort=300
nt=0

for HREF in `seq -f "%03g" $HSTART 1 $HSTOP` ;do

	${dir_scripts}/get_gfs.pl data ${datacorrente}${HH} ${HREF} ${HREF} ${HREF} ${VAR} ${LEV} ${dir_output}/

      # CHECAGEM DO DOWNLOAD
      Nvar=`${p_wgrib2} ${dir_output}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2 | wc -l`

      if [ ${Nvar} -lt ${Nref} ];then

         Flag=1 

         while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

            sleep 60
            echo " "
            echo " Tentando o Download novamente do gfs.t${HH}z.sfluxgrbf${HREF}.grib2"
            echo " "

            ${dir_scripts}/get_gfs.pl data ${datacorrente}${HH} ${HREF} ${HREF} ${HREF} ${VAR} ${LEV} ${dir_output}/
	    Nvar=`${p_wgrib2} ${dir_output}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2 | wc -l`
            
            if [ ${Nvar} -lt ${Nref} ];then
               Flag=1
            else               
               Flag=0
               echo " "
               echo " Nova tentativa de Download do dado gfs.t${HH}z.sfluxgrbf${HREF}.grib2  OK"
               echo " "
            fi

            nt=$((nt+1))

         done         
      else
         echo " "
         echo " Dado gfs.t${HH}z.sfluxgrbf${HREF}.grib2 OK"
         echo " "
      fi

cat ${dir_output}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2  >> ${dir_output}/wnd.grb2 
	
done

# conversão netcdf
${p_wgrib2} ${dir_output}/wnd.grb2 -netcdf ${dir_output}/wnd.nc
# otimização arquivo
${p_ncks} -4 -L 1 ${dir_output}/wnd.nc ${dir_output}/wnd_cp.nc

file_nc=gfs12.${datacorrente}${HH}.nc
mv ${dir_output}/wnd_cp.nc ${dir_output}/${file_nc}

# Remove arquivos desnecessários

if [ -f "${dir_output}/${file_nc}" ]
then

for filename in ${dir_output}/gfs.t*; do
 rm $filename
done

for filename in ${dir_output}/wnd*; do
 rm $filename
done

fi
