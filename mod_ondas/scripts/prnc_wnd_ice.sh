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
      AMD=`cat ~/datas/datacorrente_m1${HSIM}`  # data do dia anterior da rodada
   else 
      AMD=`cat ~/datas/datacorrente${HSIM}`
   fi
elif [ $# -eq 3 ]; then
   AMD=$3
fi

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos

# -----------------------
#  Realização do prnc

if [ ${FORC} = "ice" ]; then    # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/gelo
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/seaice.${AMD}.nc ${WORKDIR}/ice.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/ice.ww3 ${FORCDIR}/${FORC}.${AMD}.${FORC}
elif [ ${FORC} = "gfs" ]; then    # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/${FORC}
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "gfs12" ]; then    # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/${FORC}
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/gfs.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "icon" ]; then  # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/${FORC}
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "icon12" ]; then  # TESTADO e TIME INCORRETO.. Bruna consertando a variável de tempo
   FORCDIR=${WW3DIR}/input/vento/${FORC}
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
elif [ ${FORC} = "cosmo" ]; then  # TESTADO e CORRETO
   FORCDIR=${WW3DIR}/input/vento/${FORC}
   ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.ww3
   ln -sf ${FORCDIR}/${FORC}.${AMD}${HSIM}.nc ${WORKDIR}/wnd.nc
   ln -sf ${FIXODIR}/ww3_prnc.inp.${FORC} ${WORKDIR}/ww3_prnc.inp
   echo " "
   echo " Executando o prnc "${FORC} ${AMD}${HSIM}
   echo " "
   cd ${WORKDIR}
   ww3_prnc
   mv ${WORKDIR}/wind.ww3 ${FORCDIR}/wind.${AMD}${HSIM}.${FORC}
fi


for filename in ${WORKDIR}/*; do
 rm $filename
done