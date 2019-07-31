#!/bin/sh
##################################################
# Script com a configuração dos diretórios para  #
# as rodadas operacionais do WW3                 #
#                                                #
# MAI2019                                        #  
# Autoras: 1T(RM2-T) Andressa D'Agostini         #
#          Bruna Reis                            #     
##################################################

#---------------------------------------------------------------------------
# Diretórios raiz 
WW3DIR=/data1/ww3desenv/home/mod_ondas
DIRWND=${WW3DIR}/input/vento
DIRICE=${WW3DIR}/input/gelo

# GFS - Diretório utilizado em $WW3DIR/scripts/get_gfs.sh
DOWNLOAD=/data1/download/ww3

# ICON - Diretório utilizado em $WW3DIR/scripts/get_icon.sh
DPNS24='/mnt/nfs/dpns24/icondata'

# COSMO - - Diretório utilizado em $WW3DIR/scripts/get_cosmo.sh
COSMODATA='/data2/admcosmo/metarea5/data'

#----------------------------------------------------------------------------------------
# Programas - Utilizados nas rotinas $WW3DIR/scripts/get_$WND.sh, prnc_wnd.sh, prnc_ice.sh
p_wgrib2='/home/operador/bin/wgrib2'
p_bunzip2='/usr/bin/bunzip2'
p_mpirun='/opt/hpe/hpc/mpt/mpt-2.17/bin/mpirun'
p_ncks='~/anaconda3/bin/ncks'
p_ncap2='~/anaconda3/bin/ncap2'
p_nccopy='/data1/ww3desenv/home/libs/netcdf/bin/nccopy'
