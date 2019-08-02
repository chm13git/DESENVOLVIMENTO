#!/bin/bash -x
##################################################
# Script que realiza o Download do GFS (~12km)   # 
# horario para a rodada WW3                      #
#                                                #
# JUN2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
##################################################

if ! [ $# -eq 1 ];then

	echo ""
	echo " Informe o horario de simulacao (00, 12) "
	echo ""
	exit 01

fi

HSIM=$1
HSTART=0
HSTOP=120

DD=`date +"%d"`
MM=`date +"%m"`
YY=`date +"%Y"`

CURDATE=$YY$MM$DD
DIRGFS=/data1/ww3desenv/home/mod_ondas/input/vento/gfs/gfs_novo
#DIRGFS=/data1/operador/mod_ondas/ww3_418/input/vento/gfs
DIRGFSdados=${DIRGFS}
GFSARQ=gfs.t${HSIM}z.pgrb2.0p25.f
#WORKDIR=${DIRGFSdados}

cd ${DIRGFSdados}

for prog in `seq -s " " -f "%03g" ${HSTART} 1 ${HSTOP}`
#for prog in `seq -f "%02g" ${HSTART} 1 ${HSTOP}`
do

time /data1/ww3desenv/home/mod_ondas/scripts/get_gfs.pl data $CURDATE$HSIM $prog $prog 1 UGRD:VGRD 10_m_above_ground .
#time /data1/operador/mod_ondas/ww3_418/scripts/get_gfs.pl data $CURDATE$HSIM $prog $prog 1 UGRD:VGRD 10_m_above_ground .
done 
