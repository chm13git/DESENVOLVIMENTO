#!/bin/bash
##################################################
#                                                #
# Script que cria as flags de datas para uso nas #
# rodadas operacionais                           #
#                                                #
##################################################
# Passo 1: Verifica a hora de referencia
if [ $# -ne 1 ]
then
   echo "+------------------Utilização----------------+"
   echo "  Script que cria as flags de datas para uso  "
   echo "  nas rodadas operacionais. Insira o horario  "
   echo "  de referencia (00 ou 12):                   "
   echo "                                              "
   echo "         ./ledata_corr.sh 00                  "
   echo "+--------------------------------------------+"
   exit 01
fi
HH=$1
# ---------------------------------------------------------
# Passo 2: Cria arquivos
#
rm -f ~/datas/datacorrente$HH
rm -f ~/datas/ANO${HH}
rm -f ~/datas/ano${HH}
rm -f ~/datas/mes${HH}
rm -f ~/datas/dia${HH}
rm -f ~/datas/diacorrente$HH
rm -f ~/datas/datacorrente_grads${HH}
#
#  le data corrente e copia para arquivo
#
date +%Y%m%d > ~/datas/datacorrente$HH
date +%Y >  ~/datas/ANO${HH}
date +%y >  ~/datas/ano${HH}
date +%m >  ~/datas/mes${HH}
date +%d >  ~/datas/dia${HH}
date +%d > ~/datas/diacorrente$HH
date +%d%b%Y > ~/datas/datacorrente_grads${HH}
date --date='-1day' +%Y%m%d > ~/datas/datacorrente_m1${HH}
#
cat ~/datas/datacorrente$HH
# fim
