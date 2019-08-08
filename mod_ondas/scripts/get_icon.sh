#!/bin/bash
##################################################
# Script que pegar o vento a 10 m do ICON na     #
# DPNS24 para a rodada WW3                       #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #
##################################################

# ---------------------
# Definição diretórios
source ~/mod_ondas/fixos/dir.sh

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "  Script para pegar o dado do ICON na DPNS24  "
   echo "               27km, 6-6 horas                "
   echo "                                              "
   echo "          ./get_icon.sh hh yyyymmdd           "
   echo "                                              "
   echo "       ex: ./get_icon.sh 00 20190716          "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1  
HSTART=0
HSTOP=120

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

# ---------------------
# Definição diretórios
DIRICON=${WW3DIR}/input/vento/icon
DIRICONdados=${DIRICON}/dados
WORKDIR=${DIRICONdados}/work
ICONDATA=/mnt/nfs/dpns24/icondata/wind${HSIM}
ICONARQz=icon_reg_to_client_bsm1_${AMD}${HSIM}.grib2.bz2
ICONARQ=icon_reg_to_client_bsm1_${AMD}${HSIM}.grib2

ICONww3Op=/data2/operador/mod_ondas/ww3_418/input/vento/icon

if [ -e ${ICONww3Op}/icon.${AMD}${HSIM}.nc ]; then
  echo ''
  echo ' Copiando vento do ww3op v4.18 '
  echo ''
  cp ${ICONww3Op}/icon.${AMD}${HSIM}.nc ${DIRICON}/icon.${AMD}${HSIM}.nc
else
  echo ''
  echo ' Pegando o vento do ICON na DPNS24 '
  echo ''
  # Copiando arquivo para o diretório do work
  cp ${ICONDATA}/${ICONARQz} ${WORKDIR}
  # Descompactando o arquivo no work
  ${p_bunzip2} -f ${WORKDIR}/${ICONARQz}
  # Transformando o arquivo em netcdf
  ${p_wgrib2} ${WORKDIR}/${ICONARQ} -netcdf ${WORKDIR}/icon.${AMD}${HSIM}.nc
  mv ${WORKDIR}/icon.${AMD}${HSIM}.nc ${DIRICON}
fi

# Limpando o diretorio work
for file in "${WORKDIR}"/*
do
  rm "$file"
done
