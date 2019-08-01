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

if [ $# -eq 2 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 3 ]; then
   AMD=$3
fi

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos
LOGDIR=${WW3DIR}/logs
FLAGDIR=${WW3DIR}/flags
OUTDIR=${WW3DIR}/output
GELODIR=${DIRICE}

# ------------------------
#  Definindo as forçantes

forc1=gfs
forc2=gfs12
forc3=icon
forc4=icon13
forc5=cosmo
FORCs=(${forc1} ${forc2} ${forc3}  ${forc4} ${forc5})

# Flags de tempo para o while
Abort=480  # minutos - 8 horas de limite na tentativa de rodada do WW3 
Tspended=0

${WW3DIR}/scripts/prnc_wnd_ice.sh ice 00

while [ ${Abort} -gt ${Tspended} ]; do

  for FORC in "${FORCs[@]}"; do
         
    if [ ${FORC} = "gfs" ] || [ ${FORC} = "gfs12" ] || [ ${FORC} = "icon" ] || [ ${FORC} = "icon13" ]; then 

      if [ -e ${WNDDIR}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then

        echo ' '
        echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
        echo ' '
        ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
        ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM}
#        ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM}

    elif [ ${FORC} = "cosmo" ]

      if [ -e ${OUTDIR}/icon/nest.t${HSIM}z.met5_icon ] && [ -e ${WNDDIR}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ] || [ -e ${OUTDIR}/icon13/nest.t${HSIM}z.met5_icon13 ] && [ -e ${WNDDIR}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then

        echo ' '
        echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
        echo ' '
        ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
        ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM}
#        ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM}

    elif [ -e ${FLAGDIR}/WW3${forc1}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc2}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc3}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc4}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc5}_${AMD}${HSIM}_SAFO ]; then

      echo ' '
      echo ' Todos WW3 terminaram de rodar! '
      echo ' '
      exit 1

    else

      continue

    fi
    
  done

  echo ' '
  echo ' Aguardando Forçante de Vento chegar... sleep'
  echo ' '
  sleep 60
  Tspended = ${Tspended}+1

done
