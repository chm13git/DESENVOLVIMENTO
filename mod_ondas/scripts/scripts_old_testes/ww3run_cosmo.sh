#!/bin/bash

source ~/wavewatch/setww3v607.sh

nNnP=t_XnYYYp #t_12n252p

DATAi=20170808
DATAf=20170813

# sets de MPI
ulimit -s unlimited
ulimit -v unlimited

# Diretorios
ww3dir=/data1/ww3desenv/home/mod_ondas
ww3scr=$ww3dir/scripts/scripts_teste
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos
outdir=$ww3dir/output
restdir=$ww3dir/restart
workdir=$ww3dir/work
gelodir=$ww3dir/input/gelo
log_dir=$ww3dir/logs

cd ${workdir}

WND='cosmo;'
nWND=1

# denominação das grades a serem utilizadas 
GRD1='glo25','met5'
GRD2='glo15','met3','ant3'
GRD_casos=$GRD1';'$GRD2
nCGRD=2

i=1 # Casos das grades
v=1

grds=` echo ${GRD_casos} | cut -f$i -d";" `
    START=$(date +%s.%N)
    wnd=`echo $WND | cut -f${v} -d";"`
    ventodir=$ww3dir/input/vento/${wnd}
    grd=` echo ${grds} | cut -f1 -d"," `
    echo "====================================================="
    echo " RODANDO WW3 Grades: "${grds}" Forçante: "$wnd
    echo "====================================================="

    if [[ ${wnd} = "cosmo" ]] && [[ ${grd} = "glo25" ]]
    then
      glo="glo25_icon"
    elif [[ ${wnd} = "cosmo" ]] && [[ ${grd} = "met5" ]]
    then
      glo="met5_cosmo"
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
      ln -sf ${grddir}/mod_def.${grd} ${workdir}/mod_def.${grd}
      ln -sf ${restdir}/restart.${grd} ${workdir}/restart.${grd}
      done

    ln -sf ${grddir}/mod_def.points ${workdir}/mod_def.points
    ln -sf ${grddir}/mod_def.${wnd}_${glo1} ${workdir}/mod_def.${wnd}
    ln -sf ${grddir}/mod_def.ice_${glo1} ${workdir}/mod_def.ice
    ln -sf ${gelodir}/ice.${DATAi}_${DATAf}_${glo1}_NN.ice ${workdir}/ice.ice
    ln -sf ${ventodir}/wind.${DATAi}_${DATAf}_${glo1}_NN.${wnd} ${workdir}/wind.${wnd}

    # configurando o ww3_multi.inp
    cp ${fixodir}/ww3_multi.inp ${workdir}/ww3_multi.inp
    sed s/area1/$glo/g ww3_multi.inp > temp_ww3multi
    sed s/area2/$met/g temp_ww3multi > ww3_multi.inp
    sed s/area3/$ant/g ww3_multi.inp > temp_ww3multi
    sed s/wnd/$wnd/g temp_ww3multi > ww3_multi.inp

    # Executando 
    /usr/bin/time -p /opt/hpe/hpc/mpt/mpt-2.17/bin/mpirun -v `cat ${fixodir}/${nNnP}` /data1/ww3desenv/home/wavewatch/ww3v607/model/exe/ww3_multi

    END=$(date +%s.%N)
    TEMPO=$(echo "$END - $START" | bc)

    if [ -e ${outdir}/out_pnt.points]; then
      touch $logdir/ww3${wnd}_${grades}_${nNnP}_${TEMPO}s
    fi

