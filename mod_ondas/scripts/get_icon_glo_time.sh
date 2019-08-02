#!/bin/bash
#  Script para download da previsão do ICON/DWD via aria2c            #
#  Interpola das grades triangulares para grade regular lat/lon (cdo) #
#  Ronaldo Palmeira                                                   #
#  Adaptado Bruna Reis                                                #
#  Dez/2018                                                           #
#######################################################################

# Recebe as datas
source ~/.bashrc
YEAR=`date +'%Y'`
MONTH=`date +'%m'`
DAY=`date +'%d'`
start="0"
end="180" 
end2="5"
CYC='00 06 12 18' 
VARS='u_10m v_10m'
SERVER="https://opendata.dwd.de/weather/nwp/icon/grib"

WDIR=~/mod_ondas/input/vento/icon_1h/global
mkdir -p $WDIR/icon.$YEAR$MONTH$DAY
MDIR=$WDIR/icon.$YEAR$MONTH$DAY
cd $MDIR/

## --- INFORMAÇOES PARA INTERPOLACAO DA GRADE TRIANGULAR PARA GRADE REGULAR LAT/LON ---
## download dos arquivos abaixo em https://opendata.dwd.de/weather/lib/cdo/
IDIR=${WDIR}/files
TARGET=${IDIR}/target_grid_world_0125.txt
GRID_FILE=${IDIR}/icon_grid_0026_R03B07_G.nc
WFILE=${IDIR}/weights_icogl2world_0125.nc

## --- Gera o arquivo com os pesos para interpolação (roda só 1x)---
cd ${IDIR} #${WDIR}
cdo gennn,${TARGET} ${GRID_FILE} ${WFILE}

## --- Gerando arquivo com informação da grade a seinterpolada ---
# informacoes em target_grid_world_0125.txt
# CDO grid description file for global regular grid of ICON.
gridtype=lonlat
xsize=2879
ysize=1441
xfirst=-180
xinc=0.125
yfirst=-90
yinc=0.125

# EOF
## --- SURFACE PARAMETERS ---icon.20190515

for CC in $CYC; do

mkdir -p $MDIR/$CC
CDIR=$MDIR/$CC
cd $CDIR/

for VAR in $VARS; do
        	
	if [ $VAR = 'u_10m' ]
	then
  	VV='U_10M'
	elif [ $VAR = 'v_10m' ]
	then
	VV='V_10M'
	fi

    mkdir -p $CDIR/$VV
	VDIR=$CDIR/$VV
	cd ${VDIR}

        if [ $CC = '00' ] || [ $CC = '12' ]	
        then
	for HH in `seq -s " " -f %03g $start $end`; do
	   wget "${SERVER}/${CC}/${VAR}/icon_global_icosahedral_single-level_${YEAR}${MONTH}${DAY}${CC}_${HH}_${VV}.grib2.bz2"
	done
	elif [ $CC = '06' ] || [ $CC = '18' ]
	then
	for HH in `seq -s " " -f %03g $start $end2`; do
	   wget "${SERVER}/${CC}/${VAR}/icon_global_icosahedral_single-level_${YEAR}${MONTH}${DAY}${CC}_${HH}_${VV}.grib2.bz2"
	done
	fi

	echo "Descompactando os arquivos .bz2... "
	bunzip2 *.bz2

	## --- Interpola todos os arquivos do diretório ---
 	for in_file in `ls -1 *.grib2`; do
 	out_file="${in_file/.grib2/_reg.nc}"
 	echo $in_file $out_file
 	cdo -f nc remap,${TARGET},${WFILE} ${in_file} ${out_file}
 	done
	
   	VARM=`echo "${VAR}" | awk '{print toupper($0)}'`
	file=icon_${VAR}_${CC}.nc
        #filec=icon.${VAR}_${CC}.nc
   	#cdo mergetime icon_global_icosahedral_single-level_${YEAR}${MONTH}${DAY}${CC}_*_${VV}_reg.nc ${file} 
        cdo mergetime icon_global_icosahedral_single-level_${YEAR}${MONTH}${DAY}${CC}_*_${VV}_reg.nc wnd.nc

        # Converte variável time 
        time_in="$(date --date "${YEAR}${MONTH}${DAY} ${CC}:00:00" +%s)"
        cp wnd.nc wnd_out.nc
        ~/anaconda3/bin/ncap2 -O -v -s "time=${time_in}+time*60" wnd_out.nc wnd2.nc 
        ~/anaconda3/bin/ncks -A -h -M -m -C -v time wnd2.nc wnd_out.nc        
 
        # Otimiza arquivo
        nccopy -d 7 wnd_out.nc wnd_cp.nc 

        mv ${VDIR}/wnd_cp.nc ${MDIR}/${file}
        # Remove arquivos desnecessários
        if [ -f "${MDIR}/${file}" ]
        then
        rm -f ${VDIR}/*
        fi 	
done 
        rmdir -p ${CDIR}/*
 	
done 

