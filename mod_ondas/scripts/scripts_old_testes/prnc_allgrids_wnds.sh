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
DATAf=20170812					
HH=00

source /data1/ww3operador/mod_ondas/wavewatch/setww3v516.sh

# Diretorios
ww3dir=/data1/ww3operador/mod_ondas/testes
workdir=$ww3dir/work
grddir=$ww3dir/input/grid.inp
fixodir=$ww3dir/fixos
gelodir=$ww3dir/input/gelo

# denominando grades
#GRD='glo25_gfs;glo15_gfs;glo25_ico;glo15_ico;met5;met3;ant5;ant3'
GRD='ant3'
nGRD=1

# denominando forçantes
WND='gfs;icon'
nWND=3

#WND='cosmo'
#nWND=1
#GRD='met5;met3'
#nGRD=2

cd $workdir

for g in `seq 1 $nGRD`
do

  grd=`echo $GRD | cut -f${g} -d";"`
  echo ""
  echo " ============================ "
  echo "      WW3 prnc " $grd
  echo " ============================"
  echo ""
  cp $grddir/mod_def.${grd} $workdir/mod_def.ww3
  cp $gelodir/seaice.${DATAi}_${DATAf}.nc $workdir/ice.nc
  cp $fixodir/ww3_prnc.inp.ice $workdir/ww3_prnc.inp
  echo " "
  echo " executando o prnc ice"
  echo " "
  ww3_prnc
  mv $workdir/ice.ww3 $gelodir/ice.${DATAi}_${DATAf}_${grd}.ice

  for filename in $workdir/*; do
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
  ventodir=$ww3dir/input/vento/${wnd}
#  if [ "$wnd" == "cosmo"]  && [ "${grd}" == "glo30" || "${grd}" == "glo15" || "${grd}" == "ant5" || "${grd}" == "ant3" ]; then
#   echo " "
#   echo " cosmo não tem area ANT "
#   echo " "
#  else
    cp ${ventodir}/${wnd}.${DATAi}_${DATAf}.nc $workdir/wnd.nc
    cp ${fixodir}/ww3_prnc.inp.${wnd} $workdir/ww3_prnc.inp
    cp $grddir/mod_def.${grd} $workdir/mod_def.ww3
    echo " "
    echo " executando o prnc "${wnd} ${grd}
    echo " "
    cd $workdir
    ww3_prnc
    mv $workdir/wind.ww3 $ventodir/wind.${DATAi}_${DATAf}_${grd}.${wnd}
    for filename in $workdir/*; do
     rm $filename
    done
#  fi

  done

done


