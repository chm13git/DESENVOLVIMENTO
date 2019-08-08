#!/bin/bash
##################################################
# Script que faz os restarts frios para a rodada #
# do  WW3, caso não hajam mais restarts          #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

# -----------------------------------------
# Definição diretórios raiz e do wavewatch
source ~/mod_ondas/fixos/dir.sh
source ~/wavewatch/setww3v607.sh

if ! [ $# -eq 1 ];
   then
   echo "+------------------Utilização----------------+"
   echo "    Script para gerar o restart frio para     "
   echo "  rodada do WW3 quando não houverem restarts  "
   echo "                                              "
   echo "        ./make_cold_restarts.sh wnd           "
   echo "                                              "
   echo "    wnd = (gfs, icon, cosmo, gfs12, icon13)   "
   echo "                                              "
   echo "       ex: ./make_cold_restarts.sh gfs        "
   echo "+--------------------------------------------+"
   exit
fi

FORC=$1

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos
RESTDIR=${WW3DIR}/restart/

cd ${WORKDIR}

# ----------------------
#  Definição das grades

if [ ${FORC} = "gfs" ] || [ ${FORC} = "gfs12" ] || [ ${FORC} = "icon" ] || [ ${FORC} = "icon13" ]; then
   ice=ice
   area1=glo_${FORC}
   area2=met5_${FORC}
   area3=ant5_${FORC}
   AREAS=(${area1} ${area2} ${area3})
elif [ ${FORC} = "cosmo" ]; then
   area1=met5_${FORC}
   AREAS=${area1}
fi

echo ' '
echo ' Realizando os restarts frios das grades GLO MET e ANT '
echo ' ww3_strt.inp: Fetch-limited JONSWAP'
echo ' '

for grd in "${AREAS[@]}"; do
   echo ""
   echo " Restart " ${grd}
   echo ""
   ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.ww3
   ln -sf ${FIXODIR}/ww3_strt.inp ${WORKDIR}/ww3_strt.inp
   ww3_strt
   cp ${WORKDIR}/restart.ww3 ${RESTDIR}/restart.${grd}

   for filename in ${WORKDIR}/*; do
      rm $filename
   done
done
