#!/data1/ww3operador/programas/python/anaconda3/bin/python
# -*- coding: utf-8 -*-
# -*- coding: iso-8859-1 -*-

#---------------------------------------------------#
#        Script para calcular o CFL time-step       #
#                                                   #  
# Autora: 1T(RM2-T) Andressa D'Agostini             #
# JAN/2019                                          #
#---------------------------------------------------#

import datetime, time
import os, sys, shutil
import numpy as np
import scipy
import math

if len(sys.argv) < 4:
    print('+------------Utilização-----------------+')
    print(' Entre com os seguintes argumentos :     ')
    print(' 1. Resolução Mínima da Grade em Minutos ')
    print(' 2. Latitude Máxima em graus             ')
    print(' 3. Período Máximo                       ')
    print('      '+sys.argv[0]+' 25 60 26           ')
    print('+---------------------------------------+')
    sys.exit(1)

rm=sys.argv[1]
lt=sys.argv[2]
pm=sys.argv[3]

ResMin=float(rm)
LatMax=float(lt)*(np.pi/180) # graus para radianos
Pmax=float(pm)

CFL=123766*(ResMin/60)*np.cos(LatMax)*(1/Pmax)

print('')
print(' CFL time-step (segundos) é: '+str(int(CFL)))
#print(int(CFL))
print('')
