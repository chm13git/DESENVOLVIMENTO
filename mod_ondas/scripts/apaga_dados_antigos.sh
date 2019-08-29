#!/bin/bash
##################################################
# Script para apagar dados antigos do operacional#
#                                                #
# AGO2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
##################################################

source ~/mod_ondas/fixos/dir.sh
source ~/.bashrc

VENTODIR=${WW3DIR}/input/vento 
ICEDIR=${WW3DIR}/input/gelo

for arq in `find ${ICEDIR} -mtime +5 -name "seaice.*" `; do
  echo $arq
#  rm $arq
done

for arq in `find ${ICEDIR} -mtime +5 -name "ice.*" `; do
  echo $arq
#  rm $arq
done

forc1=gfs
forc2=gfs12
forc3=icon
forc4=icon13
forc5=cosmo
FORCs=(${forc1}  ${forc2} ${forc3}  ${forc4} ${forc5})

for FORC in "${FORCs[@]}"; do
  WNDDIR=${VENTODIR}/${FORC}
  BCKDIR=${WW3DIR}/backup/ww3${FORC}
  OUTDIR=${WW3DIR}/output/ww3${FORC}
  RESTDIR=${WW3DIR}/restart/ww3${FORC}
  for arq in `find ${WNDDIR} -mtime +3 -name "wind.*" `; do
    echo $arq
    rm $arq
  done
  for arq in `find ${WNDDIR} -mtime +3 -name "${FORC}.*.nc" `; do
    echo $arq
    rm $arq
  done
  for arq in `find ${RESTDIR} -mtime +2 -name "restart.*" `; do
    echo $arq
    rm $arq
  done
  for dir in `find ${OUTDIR} -mtime +2 -name "20*" `; do
    for arq in ${dir}/*; do
      echo $arq
      rm $arq
    done
    echo $dir
    rmdir ${dir}
  done
done

