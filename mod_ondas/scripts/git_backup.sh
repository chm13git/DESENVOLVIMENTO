#!/bin/bash
##################################################
# Script para realizar o backup dos scritps com  #
# as modificações no github                      #
#                                                #
# AGO2019                                        #  
# 1T(RM2-T) Andressa D'Agostini                  #
##################################################

# -----------------------------------------
# Definição diretórios raiz e do wavewatch
source ~/mod_ondas/fixos/dir.sh
source ~/.bashrc

SCRIPTDIR=${WW3DIR}/scripts

for script in ${SCRIPTDIR}/*; do
  git add ${script}
  echo ''
  echo ' Enviando script '${script}' para o GitHub '
  echo ''
  git commit -m " Atualização "
  git push origin master
done

FIXODIR=${WW3DIR}/fixos

for inp in ${FIXODIR}/*; do
  git add ${inp}
  echo ''
  echo ' Enviando arquivo inp '${inp}' para o GitHub '
  echo ''
  git commit -m " Atualização "
  git push origin master
done

GRDINPDIR=${WW3DIR}/input/grid.inp/operacional/

for inp in ${GRDINPDIR}/*.inp; do
  git add ${inp}
  echo ''
  echo ' Enviando arquivo inp '${inp}' para o GitHub '
  echo ''
  git commit -m " Inserção ww3_grid.inp "
  git push origin master
done

