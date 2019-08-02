#!/bin/bash -x
##################################################
# Script que realiza o Download do vento a 10 m  #
# do ICON para a rodada WW3                      #
#                                                #
# JUN2019                                        #
#           Bruna Reis                           #  
# 1T(RM2-T) Andressa D'Agostini                  #
#                                                #   
##################################################
# Carrega CDO
source ~/.bashrc

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
HSTOP=78

DD=09
MM=07
YYYY=2019
CURDATE=$YYYY$MM$DD

Nref=1
Flag=0
Abort=300
nt=0

VARS='u_10m v_10m'
URL="https://opendata.dwd.de/weather/nwp/icon/grib/${HSIM}"

for HH in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`;do

      for VAR in $VARS; do
        	
	if [ $VAR = 'u_10m' ]
	then
  	VV='U_10M'
	elif [ $VAR = 'v_10m' ]
	then
	VV='V_10M'
	fi

	iconfile=icon_global_icosahedral_single-level_${CURDATE}${HSIM}_${HH}_${VV}.grib2.bz2
        iconfile_grb2=icon_global_icosahedral_single-level_${CURDATE}${HSIM}_${HH}_${VV}.grib2 
										 
        wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados}/${iconfile}"
        bunzip2 ${DIRICONdados}/${iconfile}

      	# CHECAGEM DO DOWNLOAD
      	Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados}/${iconfile_grb2} | wc -l`
     if [ ${Nvar} -lt ${Nref} ];then
        Flag=1 
        
	while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do
             sleep 60
             echo " "
             echo " Tentando o Download novamente do ${iconfile_grb2}"
             echo " "

             wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados}/${iconfile}"
	     bunzip2 ${DIRICONdados}/${iconfile}
                                    
	     Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados}/${iconfile_grb2} | wc -l`
             if [ ${Nvar} -lt ${Nref} ];then
             Flag=1
             else               
             Flag=0
             echo " "
             echo " Nova tentativa de Download do dado ${iconfile_grb2} OK"
             echo " "
             fi

             nt=$((nt+1))
        done       
      else
         echo " "
         echo "Dado ${iconfile2} OK"
         echo " "
      fi
      done
done

############# INTERPOLAÇÃO PARA GRADE REGULAR ##############
# Gera o arquivo com os pesos para interpolação (roda só 1x)
cd ${DIRICONfiles} 
cdo gennn,${TARGETICON} ${GRIDICON} ${WFILEICON}
# Gera o arquivo com informação da grade a ser interpolada 
# Informacoes em ${TARGETICON}:
# CDO grid description file for global regular grid of ICON
gridtype=lonlat
xsize=2879
ysize=1441
xfirst=-180
xinc=0.125
yfirst=-90
yinc=0.125

# Interpola todos os arquivos do diretório ---
for in_file in `ls -1 ${DIRICONdados}/*.grib2`; do
out_file="${in_file/.grib2/_reg.nc}"
echo $in_file $out_file
cdo -f nc remap,${TARGETICON},${WFILEICON} ${in_file} ${out_file}
done

for VAR in $VARS; do

    if [ $VAR = 'u_10m' ]
    then
    VV='U_10M'
    elif [ $VAR = 'v_10m' ]
    then
    VV='V_10M'
    fi	

    file_nc=${WORKDIRICON}/icon_${CURDATE}${HSIM}_${VV}_reg.nc
   
    VARM=`echo "${VAR}" | awk '{print toupper($0)}'`
    cdo mergetime ${DIRICONdados}/icon_global_icosahedral_single-level_${CURDATE}${HSIM}_*_${VV}_reg.nc ${file_nc} 
   
done 
    cdo merge ${WORKDIRICON}/*_reg.nc ${WORKDIRICON}/wnd.nc
    mv ${WORKDIRICON}/wnd.nc ${DIRICON}/icon.${CURDATE}${HSIM}.nc
    cdo -v -f grb2 -copy ${DIRICON}/icon.${CURDATE}${HSIM}.nc ${DIRICON}/icon.${CURDATE}${HSIM}.grb2

# Remove arquivos desnecessários
rm -f ${DIRICONdados}/*
rm -f ${WORKDIRICON}/*


