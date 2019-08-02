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
DIRICON13=${DIRWND}/icon13/teste
DIRICONdados13=${DIRICON13}/dados
WORKDIRICON13=${DIRICONdados13}/work

# Informações para interpolação da grade triangular para grade regular
# Download dos arquivos abaixo em https://opendata.dwd.de/weather/lib/cdo/
DIRICONfiles13=${DIRICONdados13}/files
TARGETICON13=${DIRICONfiles13}/target_grid_world_0135.txt
GRIDICON13=${DIRICONfiles13}/icon_grid_0026_R03B07_G.nc
WFILEICON13=${DIRICONfiles13}/weights_icogl2world_0135.nc

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do ICON    "
   echo "               13km, horário                  "
   echo "                                              "
   echo "          ./get_icon13.sh hh yyyymmdd         "
   echo "                                              "
   echo "       ex: ./get_icon13.sh 00 20190716        "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1  
HSTART=0
HSTOP=3 #180 78

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente00`
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
										 
        wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados13}/${iconfile}"
        bunzip2 ${DIRICONdados13}/${iconfile}

      	# CHECAGEM DO DOWNLOAD
      	Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados13}/${iconfile_grb2} | wc -l`
     if [ ${Nvar} -lt ${Nref} ];then
        Flag=1 
        
	while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do
             sleep 60
             echo " "
             echo " Tentando o Download novamente do ${iconfile_grb2}"
             echo " "

             wget "${URL}/${VAR}/${iconfile}" -O "${DIRICONdados13}/${iconfile}"
	     bunzip2 ${DIRICONdados13}/${iconfile}
                                    
	     Nvar=`/home/operador/bin/wgrib2 ${DIRICONdados13}/${iconfile_grb2} | wc -l`
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
cd ${DIRICONfiles13} 
cdo gennn,${TARGETICON13} ${GRIDICON13} ${WFILEICON13}
# Gera o arquivo com informação da grade a ser interpolada 
# Informacoes em ${TARGETICON}:
# CDO grid description file for global regular grid of ICON
gridtype=lonlat
xsize=2879
ysize=1441
xfirst=-180
xinc=0.135
yfirst=-90
yinc=0.135

# Interpola todos os arquivos do diretório ---
for in_file in `ls -1 ${DIRICONdados13}/*.grib2`; do
    out_file="${in_file/.grib2/_reg.nc}"
    echo $in_file $out_file
    cdo -f nc remap,${TARGETICON13},${WFILEICON13} ${in_file} ${out_file}
done

for VAR in $VARS; do

    if [ $VAR = 'u_10m' ]
    then
    VV='U_10M'
    elif [ $VAR = 'v_10m' ]
    then
    VV='V_10M'
    fi	

    file_nc=${WORKDIRICON13}/icon_${AMD}${HSIM}_${VV}_reg.nc
   
    VARM=`echo "${VAR}" | awk '{print toupper($0)}'`
    cdo mergetime ${DIRICONdados13}/icon_global_icosahedral_single-level_${AMD}${HSIM}_*_${VV}_reg.nc ${file_nc} 
   
done 
    
cdo merge ${WORKDIRICON13}/*_reg.nc ${WORKDIRICON13}/wnd.nc

# Converte variável time 
time_in="$(date --date "${AMD} ${HSIM}:00:00" +%s)"
cp ${WORKDIRICON13}/wnd.nc ${WORKDIRICON13}/wnd_out.nc
#~/anaconda3/bin/ncks -h -M -m -O -C -v time,lon,lat,10u,10v ${WORKDIRICON13}/wnd.nc ${WORKDIRICON13}/wnd_out.nc
~/anaconda3/bin/ncap2 -O -v -s "time=${time_in}+time*60" ${WORKDIRICON13}/wnd_out.nc ${WORKDIRICON13}/wnd2.nc 
~/anaconda3/bin/ncks -A -h -M -m -C -v time ${WORKDIRICON13}/wnd2.nc ${WORKDIRICON13}/wnd_out.nc
~/anaconda3/bin/ncatted -O -a ,time,d,, ${WORKDIRICON13}/wnd_out.nc # deleta atributos time
~/anaconda3/bin/ncatted -O -a units,time,o,c,'seconds since 1970-01-01 00:00:00.0 0:00' ${WORKDIRICON13}/wnd_out.nc # inclui atributo units
~/anaconda3/bin/ncatted -O -a calendar,time,o,c,'standard' ${WORKDIRICON13}/wnd_out.nc # inclui atributo calendar
#cdo setmissval,0 ${WORKDIRICON13}/wnd_out.nc ${WORKDIRICON13}/teste.nc
~/anaconda3/bin/ncatted -O -a _FillValue,10u,a,c,0 ${WORKDIRICON13}/wnd_out.nc -o ${WORKDIRICON13}/wnd_out.nc 
~/anaconda3/bin/ncatted -O -a _FillValue,10v,a,c,0 ${WORKDIRICON13}/wnd_out.nc -o ${WORKDIRICON13}/wnd_out.nc
 
# Otimiza arquivo
#nccopy -d 7 ${WORKDIRICON13}/wnd_out.nc ${WORKDIRICON13}/wnd_cp.nc
#file_nc=icon13.${AMD}${HSIM}.nc   
##file_grb2=icon13.${AMD}${HSIM}.grb2 

# Remove arquivos desnecessários
#mv ${WORKDIRICON13}/wnd_cp.nc ${DIRICON13}/${file_nc}
##cdo -v -f grb2 -copy ${DIRICON13}/icon13.${AMD}${HSIM}.nc ${DIRICON13}/${file_grb2}
#if [ -f "${DIRICON13}/${file_nc}" ]
#then
#rm -f ${DIRICONdados13}/*
#rm -f ${WORKDIRICON13}/*
#fi
