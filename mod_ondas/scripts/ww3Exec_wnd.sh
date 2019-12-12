#!/bin/bash
##################################################
# Script que realiza o processamento do WW3      #
#                                                #
# JUL2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

# -----------------------------------------
# Definição diretórios raiz e do wavewatch
source ~/mod_ondas/fixos/dir.sh
source ~/wavewatch/setww3v607.sh
source ~/.bashrc

if [ $# -lt 2 ]
   then
   echo "+------------------Utilização----------------+"
   echo "    Script para execução da rodada do WW3     "
   echo "                                              "
   echo "      ./ww3Exec_wnd.sh wnd hh yyyymmdd        "
   echo "                                              "
   echo "        wnd = (gfs12, ico13, cosmo)           "
   echo "                                              "
   echo "    ex: ./ww3Exec_wnd.sh gfs12 00 20190716    "
   echo "+--------------------------------------------+"
   exit
fi

FORC=$1
HSIM=$2

# -------------------------------
#  Definindo informação de datas

if [ $# -eq 2 ]; then
   AMD=`cat ~/datas/datacorrente${HSIM}`
elif [ $# -eq 3 ]; then
   AMD=$3
fi

if [ ${FORC} = 'cosmo' ]; then
   DATAf=$(date -d "${AMD} +4 days" +%Y%m%d)
else 
   DATAf=$(date -d "${AMD} +5 days" +%Y%m%d)
fi

# Datas dos restarts a serem escritos
Dnext=$(date -d "${AMD} +1 days" +%Y%m%d)
Drest=$(date -d "${AMD} +2 days" +%Y%m%d)

if [ ${HSIM} == '00' ];then
 res=12
 rest1=${AMD}    
 rest2=${Dnext}
 rest3=${Dnext}
 rest4=${Drest}
else
 res=00
 rest1=${Dnext} 
 rest2=${Dnext}
 rest3=${Drest}
 rest4=${Drest}
fi

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
WNDDIR=${DIRWND}/${FORC}
GELODIR=${DIRICE}
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos
OUTDIR=${WW3DIR}/output/ww3${FORC}/${AMD}
RESTDIR=${WW3DIR}/restart
RESTDIRo=${WW3DIR}/restart/ww3${FORC}
LOGDIR=${WW3DIR}/logs
FLAGDIR=${WW3DIR}/flags

# --------------------------------
#  Definindo configurações de MPI

ulimit -s unlimited
ulimit -v unlimited
export MPI_REQUEST_FREE
export MPI_NTHREADS=15
export MPI_BUFS_LIMIT=32
export MPI_MSG_RETRIES=400000
export MPI_IB_RECV_MSGS=1024
export MPI_IB_RECV_BUFS=256

# -----------------------------------------------------
#  Definição das áreas e links das grades e restarts

if [ ${FORC} = "gfs12" ] || [ ${FORC} = "ico13" ]; then
  ice=ice
  area1=glo_${FORC}
  area2=met5_${FORC}
  area3=ant5_${FORC}
  AREAS=(${area1} ${area2} ${area3})
  for grd in "${AREAS[@]}"; do
     echo ' '
     echo ' Linkando mod.def da área: ' $grd
     echo ' '
     ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.${grd}
     if [ -e ${RESTDIRo}/restart.${AMD}${HSIM}.${grd} ];then
       echo ''
       echo ' Linkando e restart da área: ' ${grd}
       echo ''
       ln -sf ${RESTDIRo}/restart.${AMD}${HSIM}.${grd} ${WORKDIR}/restart.$grd
     else
       ln -sf ${RESTDIR}/restart.${grd} ${WORKDIR}/restart.${grd}
       echo ''
       echo ' ATENÇÃO: Não há restart '${AMD} ${grd}', VOU UTILIZAR UM RESTART FRIO '
       echo ''
     fi
  done 
elif [ ${FORC} = "cosmo" ]; then
   area1=met5_${FORC}
   AREAS=${area1}
   echo ' '
   echo ' Linkando mod.def da área: ' ${area1}
   echo ' '
   ln -sf ${GRDDIR}/mod_def.${area1} ${WORKDIR}/mod_def.ww3
   if [ -e ${RESTDIRo}/restart.${AMD}${HSIM}.${area1} ];then
     echo ''
     echo ' Linkando e restart da área: ' ${area1}
     echo ''
     ln -sf ${RESTDIRo}/restart.${AMD}${HSIM}.${area1} ${WORKDIR}/restart.ww3
   else
     ln -sf ${RESTDIR}/restart.${area1} ${WORKDIR}/restart.ww3
     echo ''
     echo ' ATENÇÃO: Não há restart '${AMD} ${area1}', VOU UTILIZAR UM RESTART FRIO '
     echo ''
   fi
fi

# -------------------------------------------
#  Linkando as informações para a pasta work

echo ' '
echo ' Linkando os mod.def do vento, points, ice e dados de entrada '
echo ' '

if [ -e ${WNDDIR}/wind.${AMD}${HSIM}.${FORC} ]; then
  if [ ${FORC} = "cosmo" ]; then 
    echo ''
    echo ' Linkando vento '${FORC}' '${AMD}' '${HSIM}
    echo ''
    ln -sf ${WNDDIR}/wind.${AMD}${HSIM}.${FORC} ${WORKDIR}/wind.ww3
  else
    echo ''
    echo ' Linkando vento '${FORC}' '${AMD}' '${HSIM}
    echo ''
    ln -sf ${WNDDIR}/wind.${AMD}${HSIM}.${FORC} ${WORKDIR}/wind.${FORC}
  fi
else
  echo ''
  echo ' Não há vento '${FORC}' '${AMD}' '${HSIM}
  echo ' SAINDO... '
  echo ''
  exit
fi  

if [ ${FORC} = "cosmo" ]; then 
  ln -sf ${GRDDIR}/mod_def.met5_${FORC} ${WORKDIR}/mod_def.ww3
  ln -sf ${GRDDIR}/mod_def.points  ${WORKDIR}/mod_def.points
  ln -sf ${WW3DIR}/output/ww3ico13/${AMD}/nest.t${HSIM}z.met5_ico13 ${WORKDIR}/nest.ww3
  echo ''
  echo ' Linkando arquivos nest do WW3ICON13 para a rodada do WW3/'${FORC}
  echo ''
else
  ln -sf ${GRDDIR}/mod_def.${FORC} ${WORKDIR}/mod_def.${FORC}
  ln -sf ${GRDDIR}/mod_def.points  ${WORKDIR}/mod_def.points
  num_days=6
  for i in `seq 1 $num_days`; do 
     ddd=$(date -d "${AMD} -${i} days" +%Y%m%d)
     if [ -e ${GELODIR}/ice.${ddd}.ice ]; then
        ln -sf ${GELODIR}/ice.${ddd}.ice ${WORKDIR}/ice.ice
        ln -sf ${GRDDIR}/mod_def.ice ${WORKDIR}/mod_def.ice
        echo ''
        echo ' Linkando gelo para a data: '${ddd}
        echo ''
        break
     elif [ $i == 6 ]; then
        echo ''
        echo ' Sem input de gelo, saindo.. '
        echo ''
        exit 1
     else
        echo ''
        echo ' Não há gelo para a data: '${ddd}
        echo ''
     fi
  done
fi

cd ${WORKDIR}

if [ ${FORC} = "gfs12" ] || [ ${FORC} = "ico13" ]; then 
   cp ${FIXODIR}/ww3_multi.inp ${WORKDIR}/ww3_multi.inp
   sed s/dataini/${AMD}/g ww3_multi.inp > temp_ww3multi
   sed s/datafim/${DATAf}/g temp_ww3multi > ww3_multi.inp
   sed s/restart/${Drest}/g ww3_multi.inp > temp_ww3multi
   sed s/area1/${area1}/g temp_ww3multi > ww3_multi.inp
   sed s/area2/${area2}/g ww3_multi.inp > temp_ww3multi
   sed s/area3/${area3}/g temp_ww3multi > ww3_multi.inp
   sed s/wnd/${FORC}/g ww3_multi.inp > temp_ww3multi
   sed s/ice/${ice}/g temp_ww3multi > ww3_multi.inp
   sed s/cyc/${HSIM}/g ww3_multi.inp > temp_ww3multi
   cp ${WORKDIR}/temp_ww3multi ${WORKDIR}/ww3_multi.inp
   echo ''
   echo ' Iniciando Execução WW3/'${FORC}' data: '$AMD$HSIM
   echo ''
   /usr/bin/time -p ${p_mpirun} -v `cat ${FIXODIR}/mpiarg` ww3_multi
elif [ ${FORC} = "cosmo" ]; then
   cp ${FIXODIR}/ww3_shel.inp ${WORKDIR}/ww3_shel.inp
   sed s/dataini/${AMD}/g ww3_shel.inp > temp_ww3shel
   sed s/datafim/${DATAf}/g temp_ww3shel > ww3_shel.inp
   sed s/restart/${Drest}/g ww3_shel.inp > temp_ww3shel
   sed s/wnd/${FORC}/g temp_ww3shel > ww3_shel.inp
   sed s/cyc/${HSIM}/g ww3_shel.inp > temp_ww3shel
   cp ${WORKDIR}/temp_ww3shel ${WORKDIR}/ww3_shel.inp
   echo ''
   echo ' Iniciando Execução WW3/'${FORC}' data: '${AMD}${HSIM}
   echo ''
   /usr/bin/time -p ${p_mpirun} -v `cat ${FIXODIR}/mpiarg` ww3_shel
fi 

echo ''
echo ' Copiando os arquivos de output e restarts da rodada do WW3/'${FORC}' data: '${AMD}${HSIM}
echo ''

if [ -e ${OUTDIR} ]; then
 echo ' Já existe o diretório outdir '
else
 mkdir ${OUTDIR}
fi

for grd in "${AREAS[@]}"; do
  if [ ${FORC} = "cosmo" ]; then
    echo ''
    echo ' Copiando restarts e outputs do WW3/'${FORC}' data: '${AMD}${HSIM}
    echo ''
    cp ${WORKDIR}/restart001.ww3 ${RESTDIRo}/restart.${rest1}${res}.${grd}
    cp ${WORKDIR}/restart002.ww3 ${RESTDIRo}/restart.${rest2}${HSIM}.${grd}
    cp ${WORKDIR}/restart003.ww3 ${RESTDIRo}/restart.${rest3}${res}.${grd}
    cp ${WORKDIR}/restart004.ww3 ${RESTDIRo}/restart.${rest4}${HSIM}.${grd}
    cp ${WORKDIR}/out_grd.ww3 ${OUTDIR}/out_grd.t${HSIM}z.${grd}
    cp ${WORKDIR}/log.ww3 ${LOGDIR}/log.t${HSIM}z.${grd}
    cp ${WORKDIR}/out_pnt.ww3 ${OUTDIR}/out_pnt.t${HSIM}z.points
    echo ''
    echo ' Copiando restarts e outputs do WW3/'${FORC}' grade '${grd}' data: '${AMD}${HSIM}
    echo ''
    cp ${WORKDIR}/out_grd.${grd} ${OUTDIR}/out_grd.t${HSIM}z.${grd}
    cp ${WORKDIR}/log.${grd} ${LOGDIR}/log.t${HSIM}z.${grd}
  else
    echo ''
    echo ' Copiando restarts e outputs do WW3/'${FORC}' grade '${grd}' data: '${AMD}${HSIM}
    echo ''
    cp ${WORKDIR}/restart001.${grd} ${RESTDIRo}/restart.${rest1}${res}.${grd}
    cp ${WORKDIR}/restart002.${grd} ${RESTDIRo}/restart.${rest2}${HSIM}.${grd}
    cp ${WORKDIR}/restart003.${grd} ${RESTDIRo}/restart.${rest3}${res}.${grd}
    cp ${WORKDIR}/restart004.${grd} ${RESTDIRo}/restart.${rest4}${HSIM}.${grd}
    cp ${WORKDIR}/out_grd.${grd} ${OUTDIR}/out_grd.t${HSIM}z.${grd}
    cp ${WORKDIR}/log.${grd} ${LOGDIR}/log.t${HSIM}z.${grd}
  fi
done

if [ ${FORC} != "cosmo" ]; then 
  cp ${WORKDIR}/nest.met5_${FORC} ${OUTDIR}/nest.t${HSIM}z.met5_${FORC}
  cp ${WORKDIR}/nest.ant5_${FORC} ${OUTDIR}/nest.t${HSIM}z.ant5_${FORC}
  cp ${WORKDIR}/log.* ${OUTDIR}/
  cp ${WORKDIR}/out_pnt.points ${OUTDIR}/out_pnt.t${HSIM}z.points
fi

for filename in ${WORKDIR}/*; do
 rm ${filename}
done
