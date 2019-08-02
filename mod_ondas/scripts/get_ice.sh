#!/bin/bash
##################################################
# Script que realiza o Download do gelo para a   #
# rodada do WW3                                  #
#                                                #
# JUL2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
##################################################

# ---------------------
# Definição diretórios

source ~/mod_ondas/fixos/dir.sh

if [ $# -lt 0 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para realizar o download do gelo    "
   echo "   ATENÇÃO: dia anterior a data da rodada     "
   echo "                                              "
   echo "          ./get_ice.sh   yyyymmdd            "
   echo "                                              "
   echo "        ex: ./wget_ice.sh 20190716            "
   echo "+--------------------------------------------+"
   exit
fi

if [ $# -eq 0 ]; then
   AMD=`cat ~/datas/datacorrente_m100`  # data do dia anterior da rodada
elif [ $# -eq 1 ]; then
   AMD=$1
fi

# ------------------------------
# Download do gelo do NCEP/NOAA

WORKDIR=${DIRICE}/dados/work
cd ${WORKDIR}

DADO="ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/omb/prod/sice.${AMD}/seaice.t00z.grb.grib2"

/usr/bin/wget -c ${DADO}

# ------------------------------
# Checagem do download do gelo

Nref=1
Flag=0
Abort=300
nt=0ll

Nvar=`${p_wgrib2} ${WORKDIR}/seaice.t00z.grb.grib2 | wc -l`

if [ ${Nvar} -lt ${Nref} ]; then
   Flag=1 
   while [ "${Flag}" = "1" ] || [${Abort} -gt ${nt}]; do
      sleep 60
      echo " "
      echo " Tentando o Download novamente do gelo ${AMD}"
      echo " "
      /usr/bin/wget -c ${DADO}
      Nvar=`${p_wgrib2} ${WORKDIR}/seaice.t00z.grb.grib2 | wc -l`   
      if [ ${Nvar} -lt ${Nref} ]; then
         Flag=1
      else               
         Flag=0
         echo " "
         echo " Nova tentativa de Download do gelo ${AMD} --> OK"
         echo " "
      fi
      nt=$((nt+1))
   done         
else
   echo " "
   echo " Download do dado do gelo ${AMD} --> OK"
   echo " "
fi

# --------------------------------------------------
# Transformando o dado do gelo de grib2 para netcdf

ARQ=seaice.t00z.grb.grib2
${p_wgrib2} ${WORKDIR}/${ARQ} -netcdf ${DIRICE}/seaice.${AMD}.nc

if [ -e ${DIRICE}/seaice.${AMD}.nc ] ; then
   echo " "
   echo " Dado do gelo grib2 para netcdf ${AMD} --> OK"
   echo " "
else
   echo " "
   echo " Houve algum problema na transofrmação do dado de grib2 para netcdf "
   echo " "
fi 

# ------------------------
# Limpando diretório work

for file in "${WORKDIR}"/*
do
  rm "$file"
done
