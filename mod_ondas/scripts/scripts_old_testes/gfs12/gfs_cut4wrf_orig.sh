#!/bin/bash -x

#########################
#Configurar o acesso via proxy
#usuario="09405031740"
#senha="4662de52"
usuario="smm"
senha="dfebdb6a"
export HTTP_PROXY="$usuario:$senha@proxy-armacao.mb:6060"
export HTTPS_PROXY="$usuario:$senha@proxy-armacao.mb:6060"
export NO_HTTP_PROXY="127.0.0.1,10.5.176.0/20,10.5.192.0/20,*.mb,*.mar.mil.br"

##HTTP_PROXY=''
##HTTPS_PROXY=''
##NO_HTTP_PROXY=''

route del default gw 10.13.50.1 2>> /dev/null
route add default gw 10.5.192.1 2>> /dev/null


############################################
#
# Este é o local onde atualmente pegamos os dados do GFS. Será preciso alterar o URL do get_gfs.pl se o local do dado mudar.
# URL='https://para.nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/para/gfs.$YYYY$MM$DD$HH/'
#
# Este é o nome do grib que é baixado e encontrado no get_gfs.pl
# grb='gfs.t${HH}z.pgrb2.0p25.f${HREF}'
#
#############################################################################################


if ! [ $# -eq 1 ]
then
        echo
        echo " Entre com o horario de simulacao (00, 12) "
        echo
        exit
fi

HH=$1
datacorrente=`date +%Y%m%d`
dir_scripts="/home/operador/scripts"
dir_output="/home/operador/dados/GFS_wrf/${HH}hmg"


dir_saida="/home/wrfoperador/DATA/GFS_RECIM/data${HH}"

############
# VAR = A lista de variáveis que o WRF necessita do downloado dos dados do GFS
VAR="HGT:TMP:RH:UGRD:VGRD:PRMSL:LANDN:ICEC:LAND:PRES:TSOIL:SOILW:WEASD"
#VAR="HGT"

#########
# O "all", diz que todos os níveis serão selecionados
########

########
## Remove os arquivos do HH do dia passado
rm ${dir_output}/gfs.t${HH}z.pgrb2.0p25.f*

######################################################
## Hora em que eu começo a realizar o download
echo "Essa hora é começo a fazer o download" >> /home/operador/scripts/log/tempo$datacorrente${HH}.txt
date >> /home/operador/scripts/log/tempo$datacorrente${HH}.txt

#for HREF in `seq -s " " -f "%02g" 00 3 120` ;do
for HREF in `seq -f "%03g" 00 3 120` ;do

#       if [ ${HREF} -gt 10 -a ${HREF} -lt 100 ];then
#               DIG=0
#               HREF=${DIG}${HREF}
#               echo "HREF=${DIG}${HREF}"
#       else
#               echo "Tá tudo certo e ele consegue fazer correto"
#       fi

echo $HREF

${dir_scripts}/get_gfs.pl data ${datacorrente}${HH} ${HREF} ${HREF} ${HREF} ${VAR} all ${dir_output}/
#${dir_scripts}/get_gfs.pl data ${datacorrente}${HH} 108 108 108 ${VAR} all ${dir_output}/

cd ${dir_output}/ 

campo=`/home/operador/fontes/grib2/wgrib2/wgrib2 gfs.t${HH}z.pgrb2.0p25.f${HREF} | wc -l` ##mostra o tamanho dos arquivos

#######
## Alterno os registros de linhas do GFS se necessário. 
#######


   if [ $HREF -eq 00 ]; then
     	valor=230 
   else
     	valor=241
   fi

   if [ $campo -ge ${valor} ]; then
      echo Arquivo gfs.t${HH}z.pgrb2.0p25.f${HREF} completo
   else
      echo Arquivo gfs.t${HH}z.pgrb2.0p25.f${HREF} esta incompleto
      GFS_FLAG=1
      continue
   fi

#### É aqui que eu transfiro o dado do horário
#

### /home/operador/scripts/trasnfere_dado.sh ${HH}  
chown operador:operador gfs.t${HH}z.pgrb2.0p25.f${HREF}
chmod 666 gfs.t${HH}z.pgrb2.0p25.f${HREF}
echo "scp ${dir_output}/gfs.t${HH}z.pgrb2.0p25.f${HREF} wrfoperador@10.13.100.1:${dir_saida}/gfs.t${HH}z.pgrb2.0p25.f${HREF} &" 
scp ${dir_output}/gfs.t${HH}z.pgrb2.0p25.f${HREF} wrfoperador@10.13.100.1:${dir_saida}/gfs.t${HH}z.pgrb2.0p25.f${HREF} & 
echo "Fazendo a transferência da rodada de ${HH} para a dpns01"

done 

#### Aqui eu termino de fazer o download ################ 
echo "Essa hora termina download" >> /home/operador/scripts/log/tempo$datacorrente${HH}.txt
date >> /home/operador/scripts/log/tempo$datacorrente${HH}.txt

route del default gw 10.5.192.1 2>> /dev/null
