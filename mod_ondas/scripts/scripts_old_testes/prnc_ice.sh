#!/bin/bash

############################################
#
# Interpola o gelo para as grades do ww3
#
# Autora: 1T(RM2-T) Andressa D'Agostini
# OUT2018
###########################################


if ! [ $# -eq 1 ]
then
	echo "------------------- Utilizacao ---------------------"
	echo "                                                    "
	echo "            Entre com a data da rodada              "
	echo "                                                    "
	echo "             ./prnc_ice.sh AAAAMMDD                 "
	echo "                                                    "
	echo "  OBS: a data deve ser sempre do dia anterior da    "
	echo "       rodada desejada.                             "
	echo "----------------------------------------------------"
	exit
fi

DATA=$1

#  Diretorios
ww3dir=/data1/ww3operador/home/mod_ondas
#ww3dir=/data1/ww3operador/mod_ondas
gelodir=$ww3dir/input/gelo
workdir=$ww3dir/work
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos

source ~/wavewatch/setww3v516.sh
#source $ww3dir/wavewatch/setww3v516.sh

echo " "
echo " copiando o grid e ww3_prnc.inp para o dir work"
echo " "

cp $grddir/mod_def.ice $workdir/mod_def.ww3
cp $gelodir/seaice.$DATA.nc $workdir/ice.nc
cp $fixodir/ww3_prnc.inp.ice $workdir/ww3_prnc.inp

echo " "
echo " executando o prnc ice"
echo " "

cd $workdir
ww3_prnc

mv $workdir/ice.ww3 $gelodir/ice.$DATA.ice

for filename in $workdir/*; do
 rm $filename
done
