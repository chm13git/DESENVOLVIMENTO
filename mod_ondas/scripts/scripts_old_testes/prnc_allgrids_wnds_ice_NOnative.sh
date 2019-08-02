#!/bin/bash

#####################################################
#
# Interpola as forçantes de ventos e máscara de gelo
# para as grades do ww3
#
# Autora: 1T(RM2-T) Andressa D'Agostini
# DEZ2018
#
#####################################################

DATAi=20170808
DATAf=20170813
HH=00

source /data1/ww3desenv/home/wavewatch/setww3v607.sh

# Diretorios
ww3dir=/data1/ww3desenv/home/mod_ondas
workdir=$ww3dir/work
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos
gelodir=$ww3dir/input/gelo

# denominando grades
#'glo25_gfs;glo15_gfs;glo25_ico;glo15_ico;met5;met3;ant5;ant3'
#GRD='glo25;glo15'
#nGRD=2

# denominando forçantes
#WND='gfs;icon'
#nWND=2

WND='gfs'
nWND=1
GRD='glo25'
nGRD=1

cd ${workdir}

for g in `seq 1 $nGRD`
do

  grd=`echo $GRD | cut -f${g} -d";"`
  echo ""
  echo " ============================ "
  echo "      WW3 prnc " $grd
  echo " ============================"
  echo ""
  ln -sf $grddir/mod_def.ice_${grd} ${workdir}/mod_def.ww3
  ln -sf $gelodir/seaice.${DATAi}_${DATAf}.nc ${workdir}/ice.nc
  cp $fixodir/ww3_prnc.inp.ice ${workdir}/ww3_prnc.inp
  echo " "
  echo " executando o prnc ice"
  echo " "
  ww3_prnc
  mv ${workdir}/ice.ww3 $gelodir/ice.${DATAi}_${DATAf}_${grd}_NN.ice

  for filename in ${workdir}/*; do
   rm $filename
  done

  for v in `seq 1 $nWND`
  do

    wnd=`echo $WND | cut -f${v} -d";"`
    echo ""
    echo " ============================ "
    echo "      WW3 vento " $wnd
    echo " ============================"
    echo ""
    ventodir=${ww3dir}/input/vento/${wnd}
    ln -sf ${ventodir}/${wnd}.${DATAi}_${DATAf}.nc ${workdir}/wnd.nc
    ln -sf ${fixodir}/ww3_prnc.inp.${wnd} ${workdir}/ww3_prnc.inp
    ln -sf ${grddir}/mod_def.${wnd}_${grd} ${workdir}/mod_def.ww3
    echo " "
    echo " executando o prnc "${wnd} ${grd}
    echo " "
    cd ${workdir}
    ww3_prnc

    mv ${workdir}/wind.ww3 ${ventodir}/wind.${DATAi}_${DATAf}_${grd}_NN.${wnd}
    for filename in ${workdir}/*; do
     rm $filename
    done
  done
done


