#!/bin/bash
##################################################
# Script que pegar o vento a 10 m do COSMO na    #
# DPNS31 para a rodada WW3                       #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #
##################################################

# ---------------------
# Definição diretórios
source ~/mod_ondas/fixos/dir.sh

# Carrega CDO e outras variáveis de ambiente
source ~/.bashrc

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo " Script para pegar o dado do COSMO na DPNS31  "
   echo "                7km, horario                  "
   echo "                                              "
   echo "          ./get_cosmo.sh hh yyyymmdd          "
   echo "                                              "
   echo "       ex: ./get_cosmo.sh 00 20190716         "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1  

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

# ---------------------
# Definição diretórios
DIRCOSMO=${WW3DIR}/input/vento/cosmo
WORKDIR=${DIRCOSMO}/dados/work
COSMODATAgrb=${COSMODATA}/vento${HSIM}

# Copiando arquivo para o diretório do work
tt=100
for arq in `ls ${COSMODATAgrb}/lfff0???0000 | sort -V`;do
   ${p_wgrib2} ${arq} -if ":var discipline=0 master_table=11 parmcat=2 parm=2:" -set_var UGRD -fi -if ":var discipline=0 master_table=11 parmcat=2 parm=3:" -set_var VGRD -fi -grib ${WORKDIR}/lfff_${tt}.mod
   ${p_wgrib2} ${WORKDIR}/lfff_${tt}.mod -netcdf ${WORKDIR}/wnd.${tt}.nc
   tt=$((tt + 1))
done

${p_ncrcat} ${WORKDIR}/wnd.*.nc ${WORKDIR}/cosmo.${AMD}${HSIM}.nc

mv ${WORKDIR}/cosmo.${AMD}${HSIM}.nc ${DIRCOSMO}

# Limpando o diretorio work
for file in "${WORKDIR}"/*
do
  rm "$file"
done
