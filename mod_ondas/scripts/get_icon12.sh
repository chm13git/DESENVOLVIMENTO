#!/bin/bash -x
##################################################
# Script que realiza o Download do vento a 10 m  #
# do ICON para a rodada WW3                      #
#                                                #
# JUN2019                                        #
# Autoras: Bruna Reis                            #
#          1T(RM2-T) Andressa D'Agostini         #     
#                                                #   
##################################################
# Carrega CDO
source ~/.bashrc

# Carrega caminhos dos diretórios
source ~/mod_ondas/fixos/dir.sh

DIRWND=${WW3DIR}/input/vento
DIRICON12=${DIRWND}/icon12
DIRICONdados12=${DIRICON12}/dados
WORKDIRICON12=${DIRICONdados12}/work
# Informações para interpolação da grade triangular para grade regular
# Download dos arquivos abaixo em https://opendata.dwd.de/weather/lib/cdo/
DIRICONfiles12=${DIRICONdados12}/files
TARGETICON12=${DIRICONfiles12}/target_grid_world_0125.txt
GRIDICON12=${DIRICONfiles12}/icon_grid_0026_R03B07_G.nc
WFILEICON12=${DIRICONfiles12}/weights_icogl2world_0125.nc

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do ICON    "
   echo "               12km, horário                  "
   echo "                                              "
   echo "          ./get_icon12.sh hh yyyymmdd         "
   echo "                                              "
   echo "       ex: ./get_icon12.sh 00 20190716        "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1  
HSTART=0
HSTOP=78

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

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

	iconfile=icon_global_icosahedral_single-level_${AMD}${HSIM}_${HH}_${VV}.grib2.bz2
        iconfile_grb2=icon_global_icosahedral_single-level_${AMD}${HSIM}_${HH}_${VV}.grib2 
										 
        wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados12}/${iconfile}"
        bunzip2 ${DIRICONdados12}/${iconfile}

      	# CHECAGEM DO DOWNLOAD
      	Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados12}/${iconfile_grb2} | wc -l`
     if [ ${Nvar} -lt ${Nref} ];then
        Flag=1 
        
	while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do
             sleep 60
             echo " "
             echo " Tentando o Download novamente do ${iconfile_grb2}"
             echo " "

             wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados12}/${iconfile}"
	     bunzip2 ${DIRICONdados12}/${iconfile}
                                    
	     Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados12}/${iconfile_grb2} | wc -l`
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
cd ${DIRICONfiles12} 
cdo gennn,${TARGETICON12} ${GRIDICON12} ${WFILEICON12}
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
for in_file in `ls -1 ${DIRICONdados12}/*.grib2`; do
    out_file="${in_file/.grib2/_reg.nc}"
    echo $in_file $out_file
    cdo -f nc remap,${TARGETICON12},${WFILEICON12} ${in_file} ${out_file}
done

for VAR in $VARS; do

    if [ $VAR = 'u_10m' ]
    then
    VV='U_10M'
    elif [ $VAR = 'v_10m' ]
    then
    VV='V_10M'
    fi	

    file_nc=${WORKDIRICON12}/icon_${AMD}${HSIM}_${VV}_reg.nc
   
    VARM=`echo "${VAR}" | awk '{print toupper($0)}'`
    cdo mergetime ${DIRICONdados12}/icon_global_icosahedral_single-level_${AMD}${HSIM}_*_${VV}_reg.nc ${file_nc} 
   
done 
    
cdo merge ${WORKDIRICON12}/*_reg.nc ${WORKDIRICON12}/wnd.nc

# otimização arquivo
nccopy -d 7 ${WORKDIRICON12}/wnd.nc ${WORKDIRICON12}/wnd_cp.nc
#minsize=1253694160
#size=$(wc -c <"${WORKDIRICON12}/wnd_cp.nc")
file=icon12.${AMD}${HSIM}.nc    

#if [ $size -ge $minsize ] 
#   then
   mv ${WORKDIRICON12}/wnd_cp.nc ${DIRICON12}/${file}
   #cdo -v -f grb2 -copy ${DIRICON12}/icon12.${AMD}${HSIM}.nc ${DIRICON12}/icon12.${AMD}${HSIM}.grb2
   # Remove arquivos desnecessários
   if [ -f "${DIRICON12}/${file}" ]
   then
   rm -f ${DIRICONdados12}/*
   rm -f ${WORKDIRICON12}/*
   fi
#else 
#   echo "Arquivo incompleto"
#fi 
