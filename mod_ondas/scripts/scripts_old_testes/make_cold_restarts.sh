#!/bin/bash

#####################################################
#
# Confecciona os restarts frios para as grades do ww3
#
# Autora: 1T(RM2-T) Andressa D'Agostini
# OUT2018
#
#####################################################


source /data1/ww3desenv/home/wavewatch/setww3v607.sh

#  Diretorios
ww3dir=/data1/ww3desenv/home/mod_ondas
grddir=$ww3dir/grids
workdir=$ww3dir/work
fixodir=$ww3dir/fixos
restdir=$ww3dir/restart

echo " "
echo " Fazendo restarts GLO MET e ANT "
echo " ww3_strt.inp: Fetch-limited JONSWAP"
echo " "

#GRD_all='glo25_gfs,glo25_ico,met5,ant5,glo15_gfs,glo15_ico,met5,ant5,met3,ant3'
GRD_all='glo25_gfs,met5,ant5'
#GRD_all='glo15_gfs,met3,ant3'
nG=3

# Montando os restarts frios ww3_strt.inp: Fetch-limited JONSWAP "3"
cd ${workdir}

for i in `seq 1 $nG`
do

 AREA=`echo $GRD_all | cut -f$i -d","`
 echo ""
 echo " Restart " $AREA
 echo ""
 cp ${grddir}/mod_def.${AREA} $workdir/mod_def.ww3
 cp ${fixodir}/ww3_strt.inp $workdir/ww3_strt.inp
 ww3_strt
 mv $workdir/restart.ww3 $restdir/restart.${AREA}

 for filename in $workdir/*; do
  rm $filename
 done

done


