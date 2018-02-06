#!/usr/bin/env python2

import numpy as np
import scipy as sp
from math import *

def sigmoid(x, a=1, b=0):
	return 1./(1+np.exp(-a*x-b))

def sigmap(diffvec, nmorphs, constrain=[0,-1], a=1, b=0):
	if type(diffvec)==float:
		diffarray = np.asarray([diffvec])
	else:
		diffarray = diffvec
	if constrain[1]==-1:
		constrain[1]=nmorphs-1

	morph_array = range(nmorphs)
	morph_range = morph_array[constrain[1]] - morph_array[constrain[0]] + 1
	centered = np.asarray(range(morph_range))-((morph_range-1)/2.) # center around 0
	if morph_range < nmorphs:
		tails = (nmorphs-morph_range)
		morph_array[constrain[0]:constrain[1]+1]=centered
		x = np.asarray(morph_array)
		x[0:constrain[0]] = centered[0]
		x[constrain[1]:nmorphs-1] = centered[-1]
	else:
		x = centered
	y = sigmoid(x,a,b)
	sig_start = y[constrain[0]+1]
	sig_end = y[constrain[1]-1]
	y[y<sig_start]=0
	y[y>sig_end]=1
	step = []
	if len(diffarray) > 1:
		for v in diffarray:
			step.append(v*y)
	else:
		step = diffarray*y
	stepmat = np.asarray(step)
	return stepmat.T

def linmap(diffvec, nmorphs, constrain=[0,-1]):
	if type(diffvec)==float:
		diffarray = np.asarray([diffvec])
	else:
		diffarray = diffvec
	if constrain[1]==-1:
		constrain[1]=nmorphs-1

	morph_array = range(nmorphs)
	morph_range = morph_array[constrain[1]] - morph_array[constrain[0]] + 1
	if morph_range < nmorphs:
		incr = (nmorphs-1)/float(morph_range-1)
		morph_array[constrain[0]:constrain[1]+1] = np.arange(0,nmorphs,incr)
		x = np.asarray(morph_array) # linear, from Start to End objects	
	else:
		x = np.asarray(morph_array)
	y = x/float(nmorphs-1)
	#set_strt = y[constrain[0]+1]
	#set_end = y[constrain[1]-1]
	y[0:constrain[0]]=0
	y[constrain[1]:len(y)]=1
	step = []
	if len(diffarray) > 1:
		for v in diffarray:
			step.append(v*y)
	else:
		step = diffarray*y
	stepmat = np.asarray(step)
	return stepmat.T