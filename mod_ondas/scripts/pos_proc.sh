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

# Carrega CDO e outras variáveis de ambiente
source ~/.bashrc

if [ $# -lt 2 ]
   then
   echo "+------------------Utilização----------------+"
   echo "  Script para realização do pós processamento "
   echo " do WW3: transformação para ctl/grads, netcdf "
   echo "                                              "
   echo "        ./pos_proc.sh wnd hh yyyymmdd         "
   echo "                                              "
   echo "    wnd = (gfs, icon, cosmo, gfs12, icon13)   "
   echo "                                              "
   echo "       ex: ./pos_proc.sh gfs 00 20190731      "
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

# -----------------------
#  Definindo diretorios

WORKDIR=${WW3DIR}/work
GRDDIR=${WW3DIR}/grids
FIXODIR=${WW3DIR}/fixos
OUTDIR=${WW3DIR}/output/ww3${FORC}/${AMD}
LOGDIR=${WW3DIR}/logs
FLAGDIR=${WW3DIR}/flags
BCKDIR=${WW3DIR}/backup/ww3${FORC}

# ----------------------
#  Definição das áreas

if [ ${FORC} = "gfs" ] || [ ${FORC} = "gfs12" ] || [ ${FORC} = "icon" ] || [ ${FORC} = "icon13" ]; then
   area1=met5_${FORC}
   area2=ant5_${FORC}
   AREAS=(${area1} ${area2})
elif [ ${FORC} = "cosmo" ]; then
   area1=met5_${FORC}
   AREAS=${area1}
fi

# ----------------------------------
#  Definição das variáveis de Datas

if [ ${FORC} = 'cosmo' ]; then
 dnext1=$(date -d "${AMD} +1 days" +%Y%m%d)
 dnext2=$(date -d "${AMD} +2 days" +%Y%m%d)
 dnext3=$(date -d "${AMD} +3 days" +%Y%m%d)
 dnext4=$(date -d "${AMD} +4 days" +%Y%m%d)
else
 dnext1=$(date -d "${AMD} +1 days" +%Y%m%d)
 dnext2=$(date -d "${AMD} +2 days" +%Y%m%d)
 dnext3=$(date -d "${AMD} +3 days" +%Y%m%d)
 dnext4=$(date -d "${AMD} +4 days" +%Y%m%d)
 dnext5=$(date -d "${AMD} +5 days" +%Y%m%d)
fi

cd ${WORKDIR}

# -----------------------------------------------------------------#
#      gx_outf: saídas binárias do WW3 para .ctl e .grads          #
# -----------------------------------------------------------------#

echo ' --------------------------------------------------------------------------------- '
echo '                gx_outf: saídas binárias do WW3 para .ctl e .grads                 '
echo ' --------------------------------------------------------------------------------- '

for grd in "${AREAS[@]}"; do

  echo ' '
  echo ' Linkando mod.def da área: ' ${grd}
  echo ' '

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.${grd}
  ln -sf ${OUTDIR}/out_grd.${grd} ${WORKDIR}/out_grd.ww3
  cp ${FIXODIR}/gx_outf.inp ${WORKDIR}/gx_outf.inp
  sed s/dataini/${AMD}/g gx_outf.inp > temp_gxoutf
  sed s/cyc/${HSIM}/g temp_gxoutf > gx_outf.inp

  echo ' '
  echo ' Executando ww3_ounf área: ' ${grd} ' '${AMD}${HSIM}
  echo ' '

  gx_outf

  echo ' '
  echo ' Movendo as saídas em netcdf para a pasta Backup '
  echo ' '

  cp ${WORKDIR}/ww3.ctl ${OUTDIR}/${grd}.t${HSIM}z.ctl
  cp ${WORKDIR}/ww3.grads ${OUTDIR}/${grd}.t${HSIM}z.grads

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

done

# -----------------------------------------------------------------#
#         ww3_ounf: saídas binárias do WW3 para NETCDF             #
# -----------------------------------------------------------------#

echo ' --------------------------------------------------------------------------------- '
echo '                   ww3_ounf: saídas binárias do WW3 para NETCDF                    '
echo ' --------------------------------------------------------------------------------- '

for grd in "${AREAS[@]}"; do

  echo ' '
  echo ' Linkando mod.def da área: ' ${grd}
  echo ' '

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.${grd}
  ln -sf ${OUTDIR}/out_grd.${grd} ${WORKDIR}/out_grd.ww3
  cp ${FIXODIR}/ww3_ounf.inp ${WORKDIR}/ww3_ounf.inp
  sed s/dataini/${AMD}/g ww3_ounf.inp > temp_ww3ounf
  sed s/cyc/${HSIM}/g temp_ww3ounf > ww3_ounf.inp
  sed s/area/${grd}/g ww3_ounf.inp > temp_ww3ounf
  mv ${WORKDIR}/temp_ww3ounf ${WORKDIR}/ww3_ounf.inp

  echo ' '
  echo ' Executando ww3_ounf área: ' ${grd} ' '${AMD}${HSIM}
  echo ' '

  ww3_ounf

  echo ' '
  echo ' Movendo as saídas em netcdf para a pasta Backup '
  echo ' '

  if [ ${FORC} = 'cosmo' ]; then
    cdo mergetime ${grd}${AMD}.nc ${grd}${dnext1}.nc ${grd}${dnext2}.nc ${grd}${dnext3}.nc ${grd}${dnext4}.nc ww3${FORC}_${grd}_${AMD}${HSIM}.nc
  else
    cdo mergetime ${grd}${AMD}.nc ${grd}${dnext1}.nc ${grd}${dnext2}.nc ${grd}${dnext3}.nc ${grd}${dnext4}.nc ${grd}${dnext5}.nc ww3${FORC}_${grd}_${AMD}${HSIM}.nc
  fi

  cp ${WORKDIR}/ww3${FORC}_${grd}_${AMD}${HSIM}.nc ${BCKDIR}/ww3${FORC}_${grd}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

done

# ---------------------------------------------------------------------------------------#
#  ww3_ounp: pós-processamento da saída .points do WW3 para espectros e ondogramas (tab) #
# ---------------------------------------------------------------------------------------#

echo ' --------------------------------------------------------------------------------- '
echo '  ww3_ounp: pós-processamento da saída .points do WW3 para espectros e ondogramas  '
echo ' --------------------------------------------------------------------------------- '

for grd in "${AREAS[@]}"; do

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.${grd}
  ln -sf ${OUTDIR}/out_pnt.t${HSIM}z.points ${WORKDIR}/out_pnt.ww3
  cp ${FIXODIR}/ww3_ounp_spec.inp ${WORKDIR}/ww3_ounp_spec.inp
  sed s/dataini/${AMD}/g ww3_ounp_spec.inp > temp_ww3ounp
  sed s/cyc/${HSIM}/g temp_ww3ounp > ww3_ounp_spec.inp
  mv ${WORKDIR}/ww3_ounp_spec.inp ${WORKDIR}/ww3_ounp.inp

  echo ' '
  echo ' Executando ww3_ounp espectro da área: ' ${grd} ' '${AMD}${HSIM}
  echo ' '

  ww3_ounp

  echo ' '
  echo ' Movendo os espectros para a pasta Backup '
  echo ' '

  cp ${WORKDIR}/espectro.${AMD}T${HSIM}Z_spec.nc ${BCKDIR}/espectros/spec_ww3${FORC}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.${grd}
  ln -sf ${OUTDIR}/out_pnt.t${HSIM}z.points ${WORKDIR}/out_pnt.ww3
  cp ${FIXODIR}/ww3_ounp_ondog.inp ${WORKDIR}/ww3_ounp_ondog.inp
  sed s/dataini/${AMD}/g ww3_ounp_ondog.inp > temp_ww3ounp
  sed s/cyc/${HSIM}/g temp_ww3ounp > ww3_ounp_ondog.inp
  mv ${WORKDIR}/ww3_ounp_ondog.inp ${WORKDIR}/ww3_ounp.inp

  echo ' '
  echo ' Executando ww3_ounp ondograma da área: ' ${grd} ' '${AMD}${HSIM}
  echo ' '

  ww3_ounp

  echo ' '
  echo ' Movendo os ondogramas em netcdf para a pasta Backup '
  echo ' '

  cp ${WORKDIR}/ondograma.${AMD}T${HSIM}Z_tab.nc ${BCKDIR}/espectros/ondog_ww3${FORC}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

done