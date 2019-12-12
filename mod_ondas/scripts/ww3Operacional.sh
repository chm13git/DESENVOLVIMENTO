#!/bin/bash
##################################################
# Script que realiza o processamento do WW3      #
#                                                #
# AGO2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

# -----------------------------------------
# Definição diretórios raiz e do wavewatch
source ~/mod_ondas/fixos/dir.sh
source ~/wavewatch/setww3v607.sh
source ~/.bashrc

if [ $# -lt 1 ]
   then
   echo "+------------------Utilização----------------+"
   echo "    Script para execução da rodada do WW3     "
   echo "                                              "
   echo "       ./ww3Operacional.sh hh yyyymmdd        "
   echo "                                              "
   echo "    ex: ./ww3Operacional.sh 00 20190716       "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1

# -------------------------------
#  Definindo informação de datas

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

AMDm1=`cat ~/datas/datacorrente_m100`

echo ' Rodada '${AMD}' '${HSIM}

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos
LOGDIR=${WW3DIR}/logs
FLAGDIR=${WW3DIR}/flags
OUTDIR=${WW3DIR}/output
GELODIR=${DIRICE}
BCKDIR=${WW3DIR}/backup

# ------------------------
#  Definindo as forçantes

forc1=gfs12
forc2=ico13
forc3=cosmo

FORCs=(${forc1} ${forc2} ${forc3})

# Flags de tempo para o while
Abort=480  # minutos - 8 horas de limite na tentativa de rodada do WW3 
Tspended=0

while [ ${Abort} -gt ${Tspended} ]; do

  for FORC in "${FORCs[@]}"; do
    
    if [ ${FORC} = "cosmo" ]; then
      if [ -e ${OUTDIR}/ww3ico13/${AMD}/nest.t${HSIM}z.met5_ico13 ] && [ -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then
        echo ' '
        echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
        echo ' '
        ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM} ${AMD}
        ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM} ${AMD} 
        if [ -e ${OUTDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.met5_${FORC} ] && [ -e ${BCKDIR}/ww3${FORC}/ww3${FORC}_met_${AMD}${HSIM}.nc ]; then
          touch ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO
        fi
      fi
    else
      if [ -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then
        echo ' '
        echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
        echo ' '
        ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM} ${AMD}
        ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM} ${AMD}
        if [ -e ${OUTDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.met5_${FORC} ] && [ -e ${OUTDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.glo_${FORC} ] && [ -e ${OUTDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.ant5_${FORC} ] && [ -e ${BCKDIR}/ww3${FORC}/ww3${FORC}_met_${AMD}${HSIM}.nc ]; then
          touch ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO
        fi
      fi
    fi
  done

  if [ -e ${FLAGDIR}/WW3${forc1}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc2}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc3}_${AMD}${HSIM}_SAFO ]; then
    echo ' '
    echo ' Todos WW3 terminaram de rodar! '
    echo ' '
    exit 1
  else
    echo ' '
    echo ' Aguardando Forçante de Vento chegar... sleep: '${Tspended}
    echo ' '
    sleep 60
    Aux=`expr ${Tspended} + 1`
    Tspended=${Aux}
  fi 

done
