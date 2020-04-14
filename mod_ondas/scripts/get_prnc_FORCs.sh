#!/bin/bash
##################################################
#                                                #
#  Script que realiza o download e interpola as  #
#  forçantes de vento                            #
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
   echo "          ./get_forcs.sh hh yyyymmdd          "
   echo "                                              "
   echo "        ex: ./get_forcs.sh 00 20190716        "
   echo "+--------------------------------------------+"
   exit
fi

HSIM=$1

# -----HSIM=--------------------------
#  Definindo informação de datas

if [ $# -eq 1 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 2 ]; then
   AMD=$2
fi

AMDm1=`cat ~/datas/datacorrente_m100`

echo ' Rodada '${AMD}' '${HSIM}

# -----------------------
####  Definindo diretorios

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

forc1=ico13
forc2=gfs12
forc3=cosmo

FORCs=(${forc2} ${forc1} ${forc3})

# Flags de tempo para o while
Abort=480  # minutos - 8 horas de limite na tentativa de download dos dados
Tspended=0

while [ ${Abort} -gt ${Tspended} ]; do

    if [ ${HSIM} == '00' ] && [ ! -e ${GELODIR}/ice.${AMDm1}.ice ]; then
      echo ' '
      echo ' Download e interpolação da máscara de gelo '
      echo ' '
      ${WW3DIR}/scripts/get_ice_new.sh
      ${WW3DIR}/scripts/prnc_wnd_ice.sh ice 00
    fi

  for FORC in "${FORCs[@]}"; do

    echo ' '
    echo ' FORÇANTE: '${FORC}
    echo ' '

    if [ -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ]; then
      ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
      if [ -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ]; then
        touch ${FLAGDIR}/WIND_${FORC}_${AMD}${HSIM}_safo
      fi
    fi

    if [ ! -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ]; then

      if [ ${FORC} == cosmo ] && [ ! -e ${COSMODATA}/prevdata${HSIM}/cosmo_met5_${HSIM}_${AMD}096 ]; then
        echo ' '
        echo ${FORC}' ainda não finalizou sua rodada '
        echo ' '
      else
        echo ' '
        echo ' Pegando e interpolando o vento '${FORC}' Data e HH: '${AMD}${HSIM}
        echo ' '
        ${WW3DIR}/scripts/get_${FORC}.sh ${HSIM}
        ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
        if [ -e ${DIRWND}/${FORC}/wind.${AMD}${HSIM}.${FORC} ]; then
          touch ${FLAGDIR}/WIND_${FORC}_${AMD}${HSIM}_safo
        fi
      fi
    fi

  done
 
  if [ -e ${FLAGDIR}/WIND_${forc1}_${AMD}${HSIM}_safo ] && [ -e ${FLAGDIR}/WIND_${forc2}_${AMD}${HSIM}_safo ] && [ -e ${FLAGDIR}/WIND_${forc3}_${AMD}${HSIM}_safo ]; then

    echo ' '
    echo ' Todas forçantes de vento baixaram!!! '
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
