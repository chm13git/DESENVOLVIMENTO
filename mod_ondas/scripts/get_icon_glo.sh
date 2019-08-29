#!/bin/bash
#  Script para download da previsão do ICON/DWD                       #
#  Interpola das grades triangulares para grade regular lat/lon (cdo) #
#  Bruna Reis                                                         #
#  Mai/2019                                                           #
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
mkdir -p $MDIR/work
WKDIR=$MDIR/work
cd $WKDIR/

## --- INFORMAÇOES PARA INTERPOLACAO DA GRADE TRIANGULAR PARA GRADE REGULAR LAT/LON ---
## download dos arquivos abaixo em https://opendata.dwd.de/weather/lib/cdo/
IDIR=${WDIR}/files
TARGET=${IDIR}/target_grid_world_0125.txt
GRID_FILE=${IDIR}/icon_grid_0026_R03B07_G.nc
WFILE=${IDIR}/weights_icogl2world_0125.nc

## --- Gera o arquivo com os pesos para interpolação (roda só 1x)---
#cd ${WDIR}
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
## --- SURFACE PARAMETERS ---

for CC in $CYC; do


for VAR in $VARS; do
        	
	if [ $VAR = 'u_10m' ]
	then
  	VV='U_10M'
	elif [ $VAR = 'v_10m' ]
	then
	VV='V_10M'
	fi


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
	file=icon.${YEAR}${MONTH}${DAY}${CC}
        cdo mergetime icon_global_icosahedral_single-level_${YEAR}${MONTH}${DAY}${CC}_*_${VV}_reg.nc ${file}_${VV}.nc
              
done 
        cdo merge ${file}*.nc ${file}.nc
        ~/anaconda3/bin/ncks -4 -L 1 ${file}.nc ${file}_cp.nc

      # Converte variável time de minutos para 'seconds since 1970-01-01'

        time_in="$(date --date "${AMD} ${CC}:00:00" +%s)"

        cp ${file}_cp.nc ${file}_out.nc

       ~/anaconda3/bin/ncap2 -O -v -s "time=${time_in}+time*60" ${file}_out.nc ${file}_out2.nc
       ~/anaconda3/bin/ncks -A -h -M -m -C -v time ${file}_out2.nc ${file}_out.nc 
       ~/anaconda3/bin/ncatted -O -a ,time,d,, ${file}_out.nc # deleta atributos time
        # inclui atributos nas variáveis time, 10u e 10v
       ~/anaconda3/bin/ncatted -O -a units,time,o,c,'seconds since 1970-01-01 00:00:00.0 0:00' ${file}_out.nc
       ~/anaconda3/bin/ncatted -O -a calendar,time,o,c,'standard' ${file}_out.nc
       ~/anaconda3/bin/ncatted -O -a _FillValue,10u,a,f,"9.999e+20" ${file}_out.nc -o ${file}_out.nc 
       ~/anaconda3/bin/ncatted -O -a _FillValue,10v,a,f,"9.999e+20" ${file}_out.nc -o ${file}_out.nc

        if [ -f "${file}_out.nc" ]
        then
        mv ${file}_out.nc ${MDIR}/${file}.nc
        fi
done 

# Remove arquivos desnecessarios
for filename in ${WKDIR}/*; do
rm $filename
done      
rmdir ${WKDIR}

