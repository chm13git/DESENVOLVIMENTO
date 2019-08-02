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

wnd='cosmo'
#nWND=1
#GRD='met5'
#nGRD=1

cd ${workdir}
ventodir=${ww3dir}/input/vento/${wnd}
ln -sf ${ventodir}/${wnd}.${DATAi}_${DATAf}.nc ${workdir}/wnd.nc
ln -sf ${fixodir}/ww3_prnc.inp.${wnd} ${workdir}/ww3_prnc.inp
cp ${grddir}/mod_def.${wnd} ${workdir}/mod_def.ww3
#cp ${grddir}/mod_def.${grd}_${wnd} ${workdir}/mod_def.ww3
#ln -sf ${grddir}/mod_def.${grd}_${wnd} ${workdir}/mod_def.ww3
ww3_prnc

#mv ${workdir}/wind.ww3 ${ventodir}/wind.${DATAi}_${DATAf}_${grd}_NN.${wnd}
#for filename in ${workdir}/*; do
#rm $filename
#done

#nohup ./prnc_allgrids_wnds_cosmo.sh 2> prnc_tst.txt 2> prnc_tst.err &


