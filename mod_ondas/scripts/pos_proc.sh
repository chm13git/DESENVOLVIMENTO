#!/bin/bash
##################################################
# Pós-processamento do WW3                       #
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
   echo "    wnd = (gfs, icon, cosmo, gfs12, ico13)    "
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

if [ ${FORC} = "gfs" ] || [ ${FORC} = "gfs12" ] || [ ${FORC} = "icon" ] || [ ${FORC} = "ico13" ]; then
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
#         ww3_ounf: saídas binárias do WW3 para NETCDF             #
# -----------------------------------------------------------------#

echo ' --------------------------------------------------------------------------------- '
echo '                   ww3_ounf: saídas binárias do WW3 para NETCDF                    '
echo ' --------------------------------------------------------------------------------- '

for grd in "${AREAS[@]}"; do

  echo ' '
  echo ' Linkando mod.def da área: ' ${grd}
  echo ' '

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.ww3
  ln -sf ${OUTDIR}/out_grd.t${HSIM}z.${grd} ${WORKDIR}/out_grd.ww3
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
    cdo -s mergetime ${grd}${AMD}.nc ${grd}${dnext1}.nc ${grd}${dnext2}.nc ${grd}${dnext3}.nc ${grd}${dnext4}.nc ww3${FORC}_${grd}_${AMD}${HSIM}.nc
  else
    cdo -s mergetime ${grd}${AMD}.nc ${grd}${dnext1}.nc ${grd}${dnext2}.nc ${grd}${dnext3}.nc ${grd}${dnext4}.nc ${grd}${dnext5}.nc ww3${FORC}_${grd}_${AMD}${HSIM}.nc
  fi

  GRD=` echo ${grd} | cut -f1 -d"5" `
  ${p_ncks} -4 -L 1 ${WORKDIR}/ww3${FORC}_${grd}_${AMD}${HSIM}.nc ${BCKDIR}/ww3${FORC}_${GRD}_${AMD}${HSIM}.nc
#  cp ${WORKDIR}/ww3${FORC}_${grd}_${AMD}${HSIM}.nc ${BCKDIR}/ww3${FORC}_${GRD}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

done

# -----------------------------------------------------------------#
#      gx_outf: saídas binárias do WW3 para .ctl e .grads          #
# -----------------------------------------------------------------#

echo ' --------------------------------------------------------------------------------- '
echo '                gx_outf: saídas binárias do WW3 para .ctl e .grads                 '
echo ' --------------------------------------------------------------------------------- '

if [ ${FORC} = 'ico13' ] || [ ${FORC} = 'gfs12' ] || [ ${FORC} = 'cosmo' ]; then

 if [ ${FORC} = 'ico13' ] || [ ${FORC} = 'gfs12' ]; then
  area1=met5_${FORC}
  area2=ant5_${FORC}
  area3=glo_${FORC}
  AREAS=(${area1} ${area2} ${area3})
 fi

 for grd in "${AREAS[@]}"; do

  echo ' '
  echo ' Linkando mod.def da área: ' ${grd}
  echo ' '

  ln -sf ${GRDDIR}/mod_def.${grd} ${WORKDIR}/mod_def.ww3
  ln -sf ${OUTDIR}/out_grd.t${HSIM}z.${grd} ${WORKDIR}/out_grd.ww3
  cp ${FIXODIR}/gx_outf.inp ${WORKDIR}/gx_outf.inp
  sed s/dataini/${AMD}/g gx_outf.inp > temp_gxoutf
  sed s/cyc/${HSIM}/g temp_gxoutf > gx_outf.inp

  echo ' '
  echo ' Executando gx_outf área: ' ${grd} ' '${AMD}${HSIM}
  echo ' '

  gx_outf

  echo ' '
  echo ' Movendo as saídas ctl e grads para a pasta Output '
  echo ' '
  GRD=` echo $grd | cut -c1-3 `
  cp ${WORKDIR}/ww3.ctl ${OUTDIR}/${GRD}.t${HSIM}z.ctl
  cp ${WORKDIR}/ww3.grads ${OUTDIR}/${GRD}.t${HSIM}z.grads

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

 done
fi


# ---------------------------------------------------------------------------------------#
#  ww3_ounp: pós-processamento da saída .points do WW3 para espectros e ondogramas (tab) #
# ---------------------------------------------------------------------------------------#

if [ ${FORC} = 'ico13' ] || [ ${FORC} = 'gfs12' ] || [ ${FORC} = 'cosmo' ]; then

  echo ' --------------------------------------------------------------------------------- '
  echo '  ww3_ounp: pós-processamento da saída .points do WW3 para espectros e ondogramas  '
  echo ' --------------------------------------------------------------------------------- '

  ln -sf ${GRDDIR}/mod_def.points ${WORKDIR}/mod_def.ww3
  ln -sf ${OUTDIR}/out_pnt.t${HSIM}z.points ${WORKDIR}/out_pnt.ww3
  cp ${FIXODIR}/ww3_ounp_spec.inp ${WORKDIR}/ww3_ounp_spec.inp
  sed s/dataini/${AMD}/g ww3_ounp_spec.inp > temp_ww3ounp
  sed s/cyc/${HSIM}/g temp_ww3ounp > ww3_ounp_spec.inp
  mv ${WORKDIR}/ww3_ounp_spec.inp ${WORKDIR}/ww3_ounp.inp

  echo ' '
  echo ' Executando ww3_ounp espectro da data '${AMD}${HSIM}
  echo ' '

  ww3_ounp

  echo ' '
  echo ' Movendo os espectros para a pasta Backup '
  echo ' '

  ${p_cdo} -s mergetime espectro.*Z_spec.nc spec_ww3${FORC}_${AMD}${HSIM}.nc
  cp ${WORKDIR}/spec_ww3${FORC}_${AMD}${HSIM}.nc ${BCKDIR}/specs/spec_ww3${FORC}_${AMD}${HSIM}.nc
  ${p_ncks} -d station,0,76 ${BCKDIR}/specs/spec_ww3${FORC}_${AMD}${HSIM}.nc -O ${BCKDIR}/specs/spec_petro_ww3${FORC}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

  ln -sf ${GRDDIR}/mod_def.points ${WORKDIR}/mod_def.ww3
  ln -sf ${OUTDIR}/out_pnt.t${HSIM}z.points ${WORKDIR}/out_pnt.ww3
  cp ${FIXODIR}/ww3_ounp_tab.inp ${WORKDIR}/ww3_ounp_tab.inp
  sed s/dataini/${AMD}/g ww3_ounp_tab.inp > temp_ww3ounp
  sed s/cyc/${HSIM}/g temp_ww3ounp > ww3_ounp_tab.inp
  mv ${WORKDIR}/ww3_ounp_tab.inp ${WORKDIR}/ww3_ounp.inp
  
  echo ' '
  echo ' Executando ww3_ounp tab da data '${AMD}${HSIM}
  echo ' '

  ww3_ounp

  echo ' '
  echo ' Movendo os tabs em netcdf para a pasta Backup '
  echo ' '

  ${p_cdo} -s mergetime tab.*Z_tab.nc tab_ww3${FORC}_${AMD}${HSIM}.nc
  cp ${WORKDIR}/tab_ww3${FORC}_${AMD}${HSIM}.nc ${BCKDIR}/tabs/tab_ww3${FORC}_${AMD}${HSIM}.nc
  ${p_ncks} -d station,0,76 ${BCKDIR}/tabs/tab_ww3${FORC}_${AMD}${HSIM}.nc -O ${BCKDIR}/tabs/tab_petro_ww3${FORC}_${AMD}${HSIM}.nc

  for filename in ${WORKDIR}/*; do
    rm $filename
  done

  echo ' '
  echo ' Enviando dados para petrobras '
  echo ' '

  scp ${BCKDIR}/ww3${FORC}_met_${AMD}${HSIM}.nc petrobras@dpas06:/home/petrobras/WW3/WW3_607/
  scp ${BCKDIR}/tabs/tab_ww3${FORC}_${AMD}${HSIM}.nc petrobras@dpas06:/home/petrobras/WW3/WW3_607/
  scp ${BCKDIR}/specs/spec_petro_ww3${FORC}_${AMD}${HSIM}.nc petrobras@dpas06:/home/petrobras/WW3/WW3_607/

fi

mv ${OUTDIR}/out_pnt.t${HSIM}z.points ${BCKDIR}/ww3${FORC}_${AMD}${HSIM}.points
