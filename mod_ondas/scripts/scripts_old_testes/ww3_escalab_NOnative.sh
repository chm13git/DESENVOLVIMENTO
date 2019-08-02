#!/bin/bash

#####################################################
#
# Script que roda os testes de escalabilidade
# do WW3 com as três forçantes de vento(GFS, ICON e 
# COSMO)
#
# Autoras: 1T(RM2-T) Andressa D'Agostini
#                    Bruna Reis
# OUT2018
# DEZ2018
#
#####################################################

if ! [ $# -eq 1 ]
then
	echo "------------------- Utilizacao ---------------------"
	echo "                                                    "
	echo "   Entre com o nome do arquivo da pasta fixos que   "
	echo "   contém a informação de nós e processadores para  "
        echo "   realização do teste de escalabilidade            "
	echo "                                                    "
	echo "           ./ww3_escalab.sh t_4n192p                "
	echo "                                                    "
	echo "----------------------------------------------------"
	exit
fi

nNnP=$1

DATAi=20170808
DATAf=20170813

# sets de MPI
ulimit -s unlimited
ulimit -v unlimited

# Diretorios
ww3dir=/data1/ww3operador/mod_ondas/testes
ww3scr=$ww3dir/scripts
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos
outdir=$ww3dir/output
restdir=$ww3dir/restart
workdir=$ww3dir/work
gelodir=$ww3dir/input/gelo
log_dir=$ww3dir/logs

source /data1/ww3operador/mod_ondas/wavewatch/setww3v516.sh

cd ${workdir}

for filename in ${workdir}/*; do
 rm $filename
done


WND='gfs;icon;'
nWND=2

# denominação das grades a serem utilizadas 
GRD1='glo25','met5','ant5'
GRD2='glo15','met3','ant3'
GRD_casos=$GRD1';'$GRD2
nCGRD=2

for i in `seq 1 $nCGRD`
do
  grds=` echo ${GRD_casos} | cut -f$i -d";" `
  for v in `seq 1 $nWND`
  do    
    START=$(date +%s.%N)
    wnd=`echo $WND | cut -f${v} -d";"`
    ventodir=$ww3dir/input/vento/${wnd}
    grd=` echo ${grds} | cut -f1 -d"," `
    echo "====================================================="
    echo " RODANDO WW3 Grades: "${grds}" Forçante: "$wnd
    echo "====================================================="

    if [[ ${wnd} = "gfs" ]] && [[ ${grd} = "glo25" ]]
    then
      glo="glo25_gfs"
    elif [[ ${wnd} = "gfs" ]] && [[ ${grd} = "glo15" ]]
    then
      glo="glo15_gfs"
    elif [[ ${wnd} = "icon" ]] && [[ ${grd} = "glo25" ]]
    then
      glo="glo25_ico"
    elif [[ ${wnd} = "icon" ]] && [[ ${grd} = "glo15" ]]
    then
      glo="glo15_ico"; 
    else
      echo ""
      echo " deu ruim..."
      echo ""
    fi
    glo1=`echo ${grds} | cut -f1 -d","`
    met=`echo ${grds} | cut -f2 -d","`
    ant=`echo ${grds} | cut -f3 -d","`
    grades=$glo';'$met';'$ant
    echo "" 
    echo $grades 
    echo "" 
    
    for ii in `seq 1 3`
      do
      grd=` echo ${grades} | cut -f${ii} -d";" `
      echo $grd
      # Criando link dos arquivos de grd, restart, vento e gelo
      ln -s ${grddir}/mod_def.${grd} ${workdir}/mod_def.${grd}
      ln -s ${restdir}/restart.${grd} ${workdir}/restart.${grd}
      done

    ln -sf ${grddir}/mod_def.points ${workdir}/mod_def.points
    ln -sf ${grddir}/mod_def.${wnd}_${glo1} ${workdir}/mod_def.${wnd}
    ln -sf ${grddir}/mod_def.ice_${glo1} ${workdir}/mod_def.ice
    ln -sf ${gelodir}/ice.${DATAi}_${DATAf}_${glo1}_NN.ice ${workdir}/ice.ice
    ventodir=${ww3dir}/input/vento/${wnd}
    ln -sf ${ventodir}/wind.${DATAi}_${DATAf}_${glo1}_NN.${wnd} ${workdir}/wind.${wnd}

    # configurando o ww3_multi.inp
    cp ${fixodir}/ww3_multi.inp ${workdir}/ww3_multi.inp
    sed s/area1/$glo/g ww3_multi.inp > temp_ww3multi
    sed s/area2/$met/g temp_ww3multi > ww3_multi.inp
    sed s/area3/$ant/g ww3_multi.inp > temp_ww3multi
    sed s/wnd/$wnd/g temp_ww3multi > ww3_multi.inp
    # Executando 
    /usr/bin/time -p /opt/hpe/hpc/mpt/mpt-2.17/bin/mpirun -v `cat ${fixodir}/${nNnP}` /data1/ww3operador/mod_ondas/wavewatch/ww3v516/exe/ww3_multi

    outdir=$ww3dir/output/escalab/ww3${wnd}_${grds}
    if [ -e ${outdir}]; then
     break
    else
     mkdir ${outdir}/
    fi

   for ii in `seq 1 3`
     do
     grd=` echo ${grades} | cut -f${ii} -d"," ` 
     mv $workdir/restart001.${grd} $restdir/restart001.${grd}
     mv $workdir/out_grd.${grd} $outdir/out_grd.${grd}
     mv $workdir/log.${grd} $outdir/log.${grd}
     mv ${workdir}/out_pnt.points $outdir/out_pnt.points
     done
 
    mv ${workdir}/nest.met ${outdir}/nest.met

    END=$(date +%s.%N)
    TEMPO=$(echo "$END - $START" | bc)

    if [ -e ${outdir}/out_pnt.points]; then
      touch $logdir/ww3${wnd}_${grades}_${nNnP}_${TEMPO}s
    fi

    for filename in ${workdir}/*; do
      rm $filename
    done

  done
done
