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
TARGETICON13=${DIRICONfiles13}/target_grid_world_0125.txt
GRIDICON13=${DIRICONfiles13}/icon_grid_0026_R03B07_G.nc
WFILEICON13=${DIRICONfiles13}/weights_icogl2world_0125.nc

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do ICON    "
   echo "               12km, horário                  "
   echo "                                              "
   echo "          ./teste_time.sh hh yyyymmdd         "
   echo "                                              "
   echo "       ex: ./teste_time.sh 00 20190716        "
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

echo $AMD

