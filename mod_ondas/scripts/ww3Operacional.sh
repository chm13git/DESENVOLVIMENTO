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

AMDm1=`cat ~/datas/datacorrente_m100`

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
#forc4=icon13
forc5=cosmo
#FORCs=(${forc1} ${forc2} ${forc3}  ${forc4} ${forc5})
FORCs=(${forc1} ${forc2} ${forc3} ${forc5})

# Flags de tempo para o while
Abort=480  # minutos - 8 horas de limite na tentativa de rodada do WW3 
Tspended=0

OUTDIRop='/data2/operador/mod_ondas/ww3_418/output'

#if [ -e ${OUTDIRop}/ww3${forc1}/wave.${AMD}/WW3MET_${HSIM}_SAFO ] && [ -e ${OUTDIRop}/ww3${forc3}/wave.${AMD}/WW3MET_${HSIM}_SAFO ] && [ -e ${OUTDIRop}/ww3${forc5}/wave.${AMD}/WW3MET_${HSIM}_SAFO ]; then

  while [ ${Abort} -gt ${Tspended} ]; do
    for FORC in "${FORCs[@]}"; do
      if [ ${FORC} = "gfs" ] || [ ${FORC} = "gfs12" ] || [ ${FORC} = "icon" ]; then #|| [ ${FORC} = "icon13" ]; then 
        if [ ! -e ${GELODIR}/seaice.${AMDm1}.nc ]; then
          echo ' '
          echo ' Pegando e interpolando a máscara de gelo '
          echo ' '
          ${WW3DIR}/scripts/get_ice.sh
          ${WW3DIR}/scripts/prnc_wnd_ice.sh ice 00
        fi
        if [ ! -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ]; then
          echo ' '
          echo ' Pegando o vento '${FORC}' Data e HH: '${AMD}${HSIM}
          echo ' '
          ${WW3DIR}/scripts/get_${FORC}.sh ${HSIM}
        elif [ -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then
          echo ' '
          echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
          echo ' '
          ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
          ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM}
          ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM}
          if [ -e ${OURDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.met ] && [ -e ${OUTDIR}/met.t${HSIM}z.ctl ]; then
            touch ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO
          fi
        fi 
      elif [ ${FORC} = "cosmo" ]; then
        if [ ! -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ]; then
          echo ' '
          echo ' Pegando o vento '${FORC}' Data e HH: '${AMD}${HSIM}
          echo ' '
          ${WW3DIR}/scripts/get_${FORC}.sh ${HSIM}
        elif [ -e ${OUTDIR}/ww3icon/${AMD}/nest.t${HSIM}z.met5_icon ] && [ -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ] || [ -e ${OUTDIR}/ww3icon13/${AMD}/nest.t${HSIM}z.met5_icon13 ] && [ -e ${DIRWND}/${FORC}/${FORC}.${AMD}${HSIM}.nc ] && [ ! -e ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO ]; then
          echo ' '
          echo ' Iniciando a rodada do WW3'${FORC}' Data e HH: '${AMD}${HSIM}
          echo ' '
          ${WW3DIR}/scripts/prnc_wnd_ice.sh ${FORC} ${HSIM}
          ${WW3DIR}/scripts/ww3Exec_wnd.sh ${FORC} ${HSIM}
          ${WW3DIR}/scripts/pos_proc.sh ${FORC} ${HSIM}      
          if [ -e ${OURDIR}/ww3${FORC}/${AMD}/out_grd.t${HSIM}z.met ] && [ -e ${OUTDIR}/met.t${HSIM}z.ctl ]; then
            touch ${FLAGDIR}/WW3${FORC}_${AMD}${HSIM}_SAFO
          fi
        fi
#    elif [ -e ${FLAGDIR}/WW3${forc1}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc2}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc3}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc4}_${AMD}${HSIM}_SAFO ] && [ -e ${FLAGDIR}/WW3${forc5}_${AMD}${HSIM}_SAFO ]; then
      elif [ -f ${FLAGDIR}/WW3${forc1}_${AMD}${HSIM}_SAFO ] && [ -f ${FLAGDIR}/WW3${forc2}_${AMD}${HSIM}_SAFO ] && [ -f ${FLAGDIR}/WW3${forc3}_${AMD}${HSIM}_SAFO ] && [ -f ${FLAGDIR}/WW3${forc5}_${AMD}${HSIM}_SAFO ]; then
        echo ' '
        echo ' Todos WW3 terminaram de rodar! '
        echo ' '
        exit 1
      else
        continue
      fi 
    done
    echo ' '
    echo ' Aguardando Forçante de Vento chegar... sleep: '${Tspended}
    echo ' '
    sleep 60
    Aux=`expr ${Tspended} + 1`
    Tspended=${Aux}
  done

#elif [ ! -e ${OUTDIRop}/ww3${forc1}/wave.${AMD}/WW3MET_${HSIM}_SAFO ] && [ ! -e ${OUTDIRop}/ww3${forc3}/wave.${AMD}/WW3MET_${HSIM}_SAFO ] && [ ! -e ${OUTDIRop}/ww3${forc5}/wave.${AMD}/WW3MET_${HSIM}_SAFO ]; then

#  echo ' '
#  echo ' Aguardando ww3 versão 4.18 terminar de rodar... sleep: '${Tspended}
#  echo ' '
#  sleep 60
#  Aux=`expr ${Tspended} + 1`
#  Tspended=${Aux}

#fi
