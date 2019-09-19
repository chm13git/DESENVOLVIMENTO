#!/bin/bash -x

##################################################
# Script que realiza o Download do vento a 10 m  #
# do GFS12 para a rodada WW3                     #
#                                                #
# SET2019                                        #
# Autores: Bruna Reis                            #
#          1T(RM2-T) Andressa D'Agostini         #     
#                                                #   
##################################################

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

# Carrega CDO
source ~/.bashrc

# Carrega diretórios e funções
source ~/mod_ondas/fixos/dir.sh

HH=$1
HSTART=0
HSTOP=120

if [ $# -eq 1 ]; then
   datacorrente=`cat ~/datas/datacorrente${HH}`
elif [ $# -eq 2 ]; then
   datacorrente=$2
fi

dir_scripts="/data1/ww3desenv/home/mod_ondas/scripts"
dir_files=${DIRWND}/gfs12/files
dir_work=${dir_files}/work
dir_output=${DIRWND}/gfs12

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

	${dir_scripts}/get_gfs12.pl data ${datacorrente}${HH} ${HREF} ${HREF} ${HREF} ${VAR} ${LEV} ${dir_files}/

      # CHECAGEM DO DOWNLOAD
      Nvar=`${p_wgrib2} ${dir_files}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2 | wc -l`

      if [ ${Nvar} -lt ${Nref} ];then

         Flag=1 

         while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do

            sleep 60
            echo " "
            echo " Tentando o Download novamente do gfs.t${HH}z.sfluxgrbf${HREF}.grib2"
            echo " "

            ${dir_scripts}/get_gfs12.pl data ${datacorrente}${HH} ${HREF} ${HREF} ${HREF} ${VAR} ${LEV} ${dir_files}/
	    Nvar=`${p_wgrib2} ${dir_files}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2 | wc -l`
            
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

cat ${dir_files}/gfs.t${HH}z.sfluxgrbf${HREF}.grib2  >> ${dir_work}/wnd.grb2 
	
done

# conversão netcdf
${p_wgrib2} ${dir_work}/wnd.grb2 -netcdf ${dir_work}/wnd.nc
# otimização arquivo
${p_ncks} -4 -L 1 ${dir_work}/wnd.nc ${dir_work}/wnd_cp.nc

file_nc=gfs12.${datacorrente}${HH}.nc
mv ${dir_work}/wnd_cp.nc ${dir_output}/${file_nc}

# Remove arquivos desnecessários

if [ -f "${dir_output}/${file_nc}" ]
then

for filename in ${dir_files}/gfs.t*; do
 rm $filename
done

for filename in ${dir_work}/wnd*; do
 rm $filename
done

fi
