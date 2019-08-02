#!/bin/bash
##################################################
# Interpola e configura os dados de entrada      #
# para as grades do WW3                          #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

if ! [ $# -eq 2 ]
then
	echo "------------------- Utilizacao ---------------------"
	echo "                                                    "
	echo "       Entre com a data e horario da rodada         "
	echo "                                                    "
	echo "             ./prnc_gfs.sh AAAAMMDD HH              "
	echo "                                                    "
	echo "----------------------------------------------------"
	exit
fi

DATA=$1
HH=$2

wnd=gfs

# Diretorios
ww3dir=/data1/ww3operador/home/mod_ondas
#ww3dir=/data1/ww3operador/mod_ondas
ventodir=$ww3dir/input/vento/$wnd
workdir=$ww3dir/work
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos

source ~/wavewatch/setww3v516.sh
#source $ww3dir/wavewatch/setww3v516.sh

echo " "
echo " copiando o grid e ww3_prnc.inp para o dir work"
echo " "

ln -sf $grddir/mod_def.$wnd $workdir/mod_def.ww3
ln -sf $ventodir/$wnd.$DATA$HH.nc $workdir/wnd.nc
ln -sf $fixodir/ww3_prnc.inp.$wnd $workdir/ww3_prnc.inp

echo " "
echo " executando o prnc "$wnd
echo " "

cd $workdir
ww3_prnc

mv $workdir/wind.ww3 $ventodir/wind.$DATA$HH.$wnd

for filename in $workdir/*; do
 rm $filename
done
