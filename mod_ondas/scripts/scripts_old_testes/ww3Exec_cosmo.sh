#!/bin/bash

###################################################
#
# Este programa copia forçantes e arqs auxiliares
# para executar ww3_multi e armazena os resultados
# nos respectivos diretorios
#
###################################################

if ! [ $# -eq 2 ]
then
	echo "------------------- Utilizacao ---------------------"
	echo "                                                    "
	echo "       Entre com a data da rodada e o ciclo         "
	echo "                                                    "
	echo "          ./ww3Exec_cosmo.sh AAAAMMDD HH            "
	echo "                                                    "
	echo "----------------------------------------------------"
	exit
fi

DATA=$1
HH=$2					

YYYY=`echo $DATA | cut -c1-4`	
MM=`echo $DATA | cut -c5-6`				
DD=`echo $DATA | cut -c7-8`				

DATAa=$(date -d "$DATA -1 days" +%Y%m%d)
DATAf=$(date -d "$DATA +4 days" +%Y%m%d)
Dnext=$(date -d "$DATA +1 days" +%Y%m%d)
Drest=$(date -d "$DATA +2 days" +%Y%m%d)

if [ ${HH} == 00 ];then
 res=12
 rest1=${DATA}    
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

ice=ice

area1=glo
area2=met
area3=ant
AREAS=$area1';'$area2';'$area3

# Diretorios

ww3dir=/data1/ww3operador/mod_ondas/testes
ventodir=$ww3dir/input/vento/$wnd
gelodir=$ww3dir/input/gelo
workdir=$ww3dir/work
grddir=$ww3dir/grids
fixodir=$ww3dir/fixos
outdir=$ww3dir/output/ww3$wnd/wave.$DATA
restdir=$ww3dir/restart/ww3$wnd
logdir=$ww3dir/log
flagdir=$ww3dir/flags

ulimit -s unlimited
ulimit -v unlimited
export MPI_REQUEST_FREE
export MPI_NTHREADS=15
export MPI_BUFS_LIMIT=32
export MPI_MSG_RETRIES=400000
export MPI_IB_RECV_MSGS=1024
export MPI_IB_RECV_BUFS=256

source $ww3dir/wavewatch/setww3v516.sh

cp $grddir/mod_def.* $workdir   # copiando grids para o dir work

echo ''
echo ' Copiando vento da data: '${DATA}
echo ''

cp $ventodir/wind.$DATA$HH.$wnd $workdir/wind.$wnd # copiando vento para o dir work

# copiando o gelo para o dir work
num_days=6
for i in `seq 1 $num_days`
do 
 ddd=$(date -d "$DATA -${i} days" +%Y%m%d)
 if [ -e ${gelodir}/ice.${ddd}.ice ];then
  cp $gelodir/ice.${ddd}.ice $workdir/ice.ice
  echo ''
  echo ' Copiando gelo da data: '${ddd}
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

for i in `seq 1 3`
do
AREA=`echo $AREAS | cut -f$i -d";"`
if [ -e ${restdir}/restart.${DATA}${HH}.${AREA} ];then
 echo ''
 echo ' Copiando restarts para a data: '$DATA
 echo ''
 cp $restdir/restart.${DATA}${HH}.${AREA} $workdir/restart.$AREA
else
 cp $restdir/restart.$AREA $workdir/restart.$AREA
 echo ''
 echo ' Não há restart '$DATA $AREA', rodando'
 echo ''
 fi
done 

cd $workdir
cp ${fixodir}/ww3_multi.inp $workdir/ww3_multi.inp

sed s/dataini/$DATA/g ww3_multi.inp > temp_ww3multi
sed s/datafim/$DATAf/g temp_ww3multi > ww3_multi.inp
sed s/restart/$Drest/g ww3_multi.inp > temp_ww3multi
sed s/area1/$area1/g temp_ww3multi > ww3_multi.inp
sed s/area2/$area2/g ww3_multi.inp > temp_ww3multi
sed s/area3/$area3/g temp_ww3multi > ww3_multi.inp
sed s/wnd/$wnd/g ww3_multi.inp > temp_ww3multi
sed s/ice/$ice/g temp_ww3multi > ww3_multi.inp
sed s/cyc/$HH/g ww3_multi.inp > temp_ww3multi
cp $workdir/temp_ww3multi $workdir/ww3_multi.inp

echo ''
echo ' Iniciando Execução WW3/'${wnd}' data: '$DATA$HH
echo ''

/usr/bin/time -p /opt/hpe/hpc/mpt/mpt-2.17/bin/mpirun -v -f `cat ${fixodir}/lista_nos` ww3_multi

echo ''
echo ' Copiando os arquivos de output e restarts da rodada do WW3/'${wnd}' data: '$DATA$HH
echo ''

if [ -e ${outdir}]; then
 break
else
 mkdir ${outdir}/wave.$DATA
fi

for i in `seq 1 3`
do
 AREA=`echo $AREAS | cut -f$i -d";"`
 echo ''
 echo ' Copiando restarts para a data: '$DATA
 echo ''
 cp $workdir/restart001.$AREA $restdir/restart.${rest1}${HH}.${AREA}
 cp $workdir/restart002.$AREA $restdir/restart.${rest2}${HH}.${AREA}
 cp $workdir/restart003.$AREA $restdir/restart.${rest3}${HH}.${AREA}
 cp $workdir/restart004.$AREA $restdir/restart.${rest4}${HH}.${AREA}
 cp $workdir/out_grd.$AREA $outdir/out_grd.t$HHz.${AREA}
 cp $workdir/log.$AREA $logdir/log.t$HHz.${AREA}
done

cp $workdir/nest.met $outdir/nest.t$HHz.met
cp $workdir/nest.ant $outdir/nest.t$HHz.ant
cp $workdir/out_pnt.points $outdir/out_pnt.t$HHz.points
cp $workdir/log.mww3 $logdir/log.t$HHz.mww3

touch $flagdir/WW3GFS_$DATA$HH_SAFO


for filename in $workdir/*; do
 rm $filename
done
