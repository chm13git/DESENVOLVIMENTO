#!/bin/bash
##################################################
# Interpola e configura os dados de entrada      #
# para as grades do WW3                          #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

# -----------------------------------------
# Definição diretórios raiz e do wavewatch
source ~/mod_ondas/fixos/dir.sh
source ~/wavewatch/setww3v607.sh

if [ $# -lt 2 ]
   then
   echo "+------------------Utilização----------------+"
   echo "   Script para interpolação e configuração do "
   echo "       vento ou gelo para as grades do WW3    "
   echo "                                              "
   echo " ./prnc_wnd_ice.sh (Vwnd ou ice) hh yyyymmdd  "
   echo "                                              "
   echo "   Vwnd = (gfs, icon, cosmo, gfs12, icon12)   "
   echo "                                              "
   echo "    ex: ./prnc_wnd_ice.sh gfs 00 20190716     "
   echo "+--------------------------------------------+"
   exit
fi

FORC=$1
HSIM=$2

if [ $# -eq 2 ]; then
   if [ ${FORC} = "ice" ]; then
      AMD=`cat ~/datas/datacorrente_m100`  # data do dia anterior da rodada
   else 
      AMD=`cat ~/datas/datacorrente00`
   fi
elif [ $# -eq 3 ]; then
   AMD=$3
fi

# Definindo diretorios
WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids

if [ ${FORC} = "ice" ]; then    # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/gelo
   ln -sf ${GRDDIR}/mod_def.ice ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/seaice.${AMD}.nc ${WORKDIR}/ice.nc
   ln -sf ${WW3DIR}/fixos/ww3_prnc.inp.ice ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/ice.ww3 ${FORCDIR}/ice.${AMD}.ice
elif [ ${FORC} = "gfs" ]; then    # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/gfs
   ln -sf ${GRDDIR}/mod_def.gfs ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${WW3DIR}/fixos/ww3_prnc.inp.gfs ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "gfs12" ]; then    # TESTADO e PONTOS FORA DA GRADE
   FORCDIR=${WW3DIR}/input/vento/gfs12
   ln -sf ${GRDDIR}/mod_def.gfs12 ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${WW3DIR}/fixos/ww3_prnc.inp.gfs12 ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "icon" ]; then  # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/icon
   ln -sf ${GRDDIR}/mod_def.icon ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${WW3DIR}/fixos/ww3_prnc.inp.icon ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "icon12" ]; then  # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/icon12
   ln -sf ${GRDDIR}/mod_def.icon12 ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${WW3DIR}/fixos/ww3_prnc.inp.icon12 ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
fi


#for filename in ${WORKDIR}/*; do
# rm $filename
#done
