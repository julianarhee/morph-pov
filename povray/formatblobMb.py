# CREATE MORPH IMAGES USING JINJA2
# 13 Nov 2014 (jyr)

# START with Object A, END with Object B: moprhing is specified by NMORPHS. Differences in any parameter (translation, rotation, scale, etc.) are simultaneously changed, step-wise, from START to END, with step-size determined by the (START-END)/NMORPHS.

# -*- coding: utf-8 -*-
from jinja2 import Environment, PackageLoader, FileSystemLoader, Template
import sys, os, os.path
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
from math import *

# import Image
# import re

# from scipy.stats import cumfreq
# import shutil
# import spread

# from imageDiff import *

# def keyFunc(afilename):
#     nondigits = re.compile("\D")
#     return int(nondigits.sub("", afilename))

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


# Create new output directory if it doesn't exist:
povdirectory =  './output3/pov'
if not os.path.exists(povdirectory):
    os.makedirs(povdirectory)

imdirectory =  './output3/im'
if not os.path.exists(imdirectory):
    os.makedirs(imdirectory)

tmpdirectory =  './output3/tmp'
if not os.path.exists(tmpdirectory):
    os.makedirs(tmpdirectory)

# ==================================================================
# SET NUM OF MORPHS BETWEEN Strt and End:
# ==================================================================

# Location of the whole object/stimulus (x,y,z)
# @StimPos1 = qw( 0 -0.18 5 );
# @StimPos2 = qw( 0 0 6 );
# Size of the whole object/stimulus (x,y,z)
# @StimSize1 = qw( 0 1.02 0 );
# @StimSize2 = qw( 0 0 0 );


n_real_morphs = 20
nmorphs = n_real_morphs+2 # first and last 'morph' are the originals

# SPHERE 1 (BASE):
s_trans1 = np.array([0, -0.4, 0.5])
e_trans1 = np.array([0, -0.2, 0.7])
diff_trans1 = e_trans1 - s_trans1

s_scale1 = np.array([1, 1, 1])
e_scale1 = np.array([0.8, 1.4, 0.8])
diff_scale1 = e_scale1 - s_scale1

s_rot1 = np.array([0,0,0])
e_rot1 = np.array([20,0,0])
diff_rot1 = e_rot1 - s_rot1

# SPHERE 2 (HEAD or LEFT LOBE):
s_trans2 = np.array([0, 0, -0.5])
e_trans2 = np.array([0, 0, -0.5])
diff_trans2 = e_trans2 - s_trans2

s_scale2 = np.array([1.8, 0.6, 1.8])
e_scale2 = np.array([0.6, 0.6, 2])
diff_scale2 = e_scale2 - s_scale2

s_rot2 = np.array([30,0,0])
e_rot2 = np.array([40,0,55])
diff_rot2 = e_rot2 - s_rot2

# SPHERE 4 (HEAD or RIGHT LOBE):
s_trans4 = np.array([0, 0, -0.5])
e_trans4 = np.array([0, 0, -0.5])
diff_trans4 = e_trans4 - s_trans4

s_scale4 = np.array([1.8, 0.6, 1.8])
e_scale4 = np.array([0.6, 0.6, 2])
diff_scale4 = e_scale4 - s_scale4

s_scale5 = np.array([1.8, 0.6, 1.8])
e_scale5 = np.array([1.8, 0.6, .9])
diff_scale5 = e_scale5 - s_scale5

s_rot4 = np.array([30,0,0])
e_rot4 = np.array([40,0,-55])
diff_rot4 = e_rot4 - s_rot4


# SPHERE 3:
s_trans3 = np.array([0, 0, -0.5])
e_trans3 = np.array([0, 0, 0])
diff_trans3 = e_trans3 - s_trans3

s_scale3 = np.array([0.5, 0.5, 1])
e_scale3 = np.array([0,0,0])
diff_scale3 = e_scale3 - s_scale3

s_rot3 = np.array([-45,0,0])
e_rot3 = np.array([0,0,0])
diff_rot3 = e_rot3 - s_rot3

s_nosesize = 0.8
e_nosesize = 0
diff_nosesize = e_nosesize - s_nosesize


# OTHER PARAMETERS:
s_camloc = np.array([0,0,-10])
e_camloc = np.array([0,0,-20])
diff_camloc = e_camloc - s_camloc

# MAPPING INPUTS (in normal speak):
#
# nmorphs :  the num of actual morphs you want (even number in order to split 
# 		stimuli evenly between 2 class, for ex.) PLUS 2 (the start & end stim)
#
# constrain[x,y]  :  
# 		x is the morph number you want to reset to 0 
#		y is the morph num you want so that sig(y)=1
# 		EX: [5,15] makes morph No.5 the new start of the sigmoid, which reaches
#		its end at 1 on morph No. 15.
# 		EX2:  If you just want to shift the sig curve over, and have it end 
#		normally, i.e., with sig(last-morph)=1, set y=nmorphs-1
#
# a  :  alpha value for the general sigmoid function (changes the slope)
#		At a=1, middle is halfway point; a<1 (shallower slope); a>1 (steeper).
#
# b  :  beta value for the general sigmoid function (translates)
#		At b=0, middle is halfway point; b>0 shifts leftward (rise occurs earlier)
#		while b<0 shifts rightward (rise occurs later).  


# SET LINEAR or SIGMOIDAL Interpolation Map:
step_camloc = linmap(diff_camloc, nmorphs)


# BASE/BOTTOM ###########################
step_trans1 = linmap(diff_trans1,nmorphs)
step_scale1 = linmap(diff_scale1,nmorphs)#sigmap(diff_scale1,nmorphs,a=.5,b=-1)#a=.6,b=0)
step_rot1 = linmap(diff_rot1,nmorphs)


# head 1 scale ###########################
lim15 = int(np.ceil((nmorphs+2)*(15./22)))
lim10 = int(np.ceil((nmorphs+2)*(10./22)))
step_trans2 = sigmap(diff_trans2,nmorphs) # no change
step_scale2x = sigmap(diff_scale2,nmorphs,constrain=[0,lim15],a=1,b=2) # thinning
step_scale2y = linmap(diff_scale2,nmorphs) # no change
step_scale2z = sigmap(diff_scale2,nmorphs,constrain=[lim10,nmorphs-1],a=.8 ,b=0) # 0.2 elong
step_scale2 = np.asarray([step_scale2x[:,0], step_scale2y[:,1], step_scale2z[:,2]]).T


# head 2 scale ###########################
step_trans4 = sigmap(diff_trans4,nmorphs) # no change
step_scale4x = sigmap(diff_scale4,nmorphs,constrain=[0,lim15],a=1,b=2)
step_scale4y = linmap(diff_scale4,nmorphs) # no change
step_scale4z = sigmap(diff_scale4,nmorphs,constrain=[lim10,nmorphs-1],a=.8 ,b=0) # 0.2 change
step_scale4 = np.asarray([step_scale4x[:,0], step_scale4y[:,1], step_scale4z[:,2]]).T

step_scale5 = linmap(diff_scale5, nmorphs)


# head 1 rot ###########################
lim3 = int(np.ceil((nmorphs+2)*(3./22)))
step_rot2x = sigmap(diff_rot2,nmorphs,constrain=[lim3,(nmorphs-1)],a=1,b=2) #-1
step_rot2y = linmap(diff_rot2,nmorphs) # y doesn't change
step_rot2z = sigmap(diff_rot2,nmorphs,constrain=[0,(nmorphs-1)],a=.7,b=3)
step_rot2 = np.asarray([step_rot2x[:,0], step_rot2y[:,1], step_rot2z[:,2]]).T


# head 2 rot ###########################
step_rot4x = sigmap(diff_rot4,nmorphs,constrain=[lim3,(nmorphs-1)],a=1,b=2) #-1
step_rot4y = linmap(diff_rot4,nmorphs) # y doesn't change
step_rot4z = sigmap(diff_rot4,nmorphs,constrain=[0,(nmorphs-1)],a=.7,b=3) #[0,21],a=.7,b=3)
step_rot4 = np.asarray([step_rot4x[:,0], step_rot4y[:,1], step_rot4z[:,2]]).T


# nose protrusion ###########################
step_trans3 = linmap(diff_trans3,nmorphs)
step_scale3 = linmap(diff_scale3,nmorphs)
step_rot3 = linmap(diff_rot3,nmorphs)
step_nosesize = linmap(diff_nosesize, nmorphs) #sigmap(diff_nosesize,nmorphs)#,a=.6, b=-2)


# SET THE STARTING PARAMETER VALUES (Object A, or B):
config = {
	'camloc': '<%s>' % ', '.join(map(str, s_camloc)),
	'translate1': '<%s>' % ', '.join(map(str, s_trans1)),
	'scale1': '<%s>' % ', '.join(map(str, s_scale1)),
	'rotate1': '<%s>' % ', '.join(map(str, s_rot1)),

	'translate2': '<%s>' % ', '.join(map(str, s_trans2)),
	'scale2': '<%s>' % ', '.join(map(str, s_scale2)),
	'rotate2': '<%s>' % ', '.join(map(str, s_rot2)),

	'translate3': '<%s>' % ', '.join(map(str, s_trans3)),
	'scale3': '<%s>' % ', '.join(map(str, s_scale3)),
	'rotate3': '<%s>' % ', '.join(map(str, s_rot3)),
	'nosesize': s_nosesize,

	'translate4': '<%s>' % ', '.join(map(str, s_trans4)),
	'scale4': '<%s>' % ', '.join(map(str, s_scale4)),
	'rotate4': '<%s>' % ', '.join(map(str, s_rot4)),
	'scale5': '<%s>' % ', '.join(map(str, s_scale5)),
}	


def run():

	#print config
	#print step_trans1

	# SET NUMBER OF MORPHS BETWEEN OBJECT A and OBJECT B, and create .pov files for each morph in "templates" folder.

	# Generated .pov files can then be run in a batch with the POVRAY3_7_Unofficial GUI, which can then output .png files for each rendered morph into "output" folder.

	# nmorphs = 21
	for morphnum in range(nmorphs):

		strengthA = float(morphnum) / nmorphs
		strengthB = 1.0 - strengthA

		config.update(
			camloc='<%s>' % ', '.join(map(str, s_camloc+step_camloc[morphnum])),
			translate1='<%s>' % ', '.join(map(str, s_trans1+step_trans1[morphnum])),
			scale1='<%s>' % ', '.join(map(str, s_scale1+step_scale1[morphnum])),
			rotate1='<%s>' % ', '.join(map(str, s_rot1+step_rot1[morphnum])),

			translate2='<%s>' % ', '.join(map(str, s_trans2+step_trans2[morphnum])),
			scale2='<%s>' % ', '.join(map(str, s_scale2+step_scale2[morphnum])),
			rotate2='<%s>' % ', '.join(map(str, s_rot2+step_rot2[morphnum])),

			translate3='<%s>' % ', '.join(map(str, s_trans3+step_trans3[morphnum])),
			scale3='<%s>' % ', '.join(map(str, s_scale3+step_scale3[morphnum])),
			rotate3='<%s>' % ', '.join(map(str, s_rot3+step_rot3[morphnum])),
			nosesize=s_nosesize+step_nosesize[morphnum],

			translate4='<%s>' % ', '.join(map(str, s_trans4+step_trans4[morphnum])),
			scale4='<%s>' % ', '.join(map(str, s_scale4+step_scale4[morphnum])),
			rotate4='<%s>' % ', '.join(map(str, s_rot4+step_rot4[morphnum])),
			strengthA='%f' % strengthA,
			strengthB='%f' % strengthB,
			scale5='<%s>' % ', '.join(map(str, s_scale5+step_scale5[morphnum]))

			)

		command = """
		#include "colors.inc"

		background{Black}

		camera{
			angle 15
			location {{ camloc }}
			look_at <0,0,0>
		}

		light_source{ <0,-10,-10> color White}

		#declare StimBlob1 = blob {
		    threshold 0.2
		    //base (bottom)
		    sphere { <0,0,0>, .8, 1  
		    	translate {{ translate1 }}
		    	scale {{ scale1 }}
		    	rotate {{ rotate1 }}
		    }
		    
		    // original head disc
		    sphere { <0,0,0>, .8, {{strengthB}}  
		    	translate <0.0, 0.0, -0.5>
		    	scale {{ scale5 }}
		    	rotate <30.0, 0.0, 0.0>   
		    }

		    //head disc
		    sphere { <0,0,0>, .8, {{strengthA}}
		    	translate <0.0, 0.0, -0.5>
		    	scale <0.6, 0.6, 2.0>
		    	rotate <40.0, 0.0, 55.0>   
		    }

		    //head disc 2
		    sphere { <0,0,0>, .8, {{strengthA}} 
		    	translate <0.0, 0.0, -0.5>
		    	scale <0.6, 0.6, 2.0>
		    	rotate <40.0, 0.0, -55.0>   
		    }
		   	
		   	/*//nose protrusion
		    sphere { <0,0,0>, {{ strengthB }}, 1  
		    	translate <0,0,-0.5>
		    	scale <0.5, 0.5, 1>
		    	rotate <-45,0,0>
		    }


		    
		    //nose protrusion
		    sphere { <0,0,0>, {{ strengthA }}, 1  
		    	translate <0, 0, 0>
		    	scale <0,0,0>
		    	rotate <0,0,0>
		    }*/


		    /*//head disc
		    sphere { <0,0,0>, .8, 1  
		    	translate {{ translate2 }}
		    	scale {{ scale2 }}
		    	rotate {{ rotate2 }}   
		    }

		    //head disc 2
		    sphere { <0,0,0>, .8, 1  
		    	translate {{ translate4 }}
		    	scale {{ scale4 }}
		    	rotate {{ rotate4 }}   
		    }*/
		    
		    //nose protrusion
		    sphere { <0,0,0>, {{ nosesize }}, 1  
		    	translate {{ translate3 }}
		    	scale {{ scale3 }}
		    	rotate {{ rotate3 }}
		    }
		}

	  	object{ StimBlob1 
		  	rotate <0,0,0>
		  	translate <0, 0, 0>
		  	scale <1, 1, 1>
		  	pigment {White} 
		  	finish {
		       phong 0.0
		       ambient 0.4 //0.3
		       diffuse 0.6
		    }
		}
		"""

		command = Environment().from_string(command).render(config)
		#print command

		# save formatted file: 
		# imname = 'morph%i.pov' % morphnum
		outpath = povdirectory + '/morph%i.pov' % morphnum
		impath = imdirectory + '/morph%i.png' % morphnum
		with open(outpath, "wb") as fn:
			fn.write(command)

		# deprecated, but who cares
		AspRat = 320/240.
		xres = 1100
		yres = int( xres / AspRat )
		os.system('povray +I%s +O%s +W%s +H%s' % (outpath, impath, str(xres), str(yres)))
		# os.system('povray +I%s +O%s' % (outpath, impath))
	# 	os.system('qlmanage -p 2>/dev/null %s &' % impath)
	# os.system('killall qlmanage')

 
# def copyDirectory(src, dest):
#     try:
#         shutil.copytree(src, dest)
#     # Directories are the same
#     except shutil.Error as e:
#         print('Directory not copied. Error: %s' % e)
#     # Any error saying that the directory doesn't exist
#     except OSError as e:
#         print('Directory not copied. Error: %s' % e)

# def copyFile(src, dest):
#     try:
#         shutil.copy(src, dest)
#     # eg. src and dest are the same file
#     except shutil.Error as e:
#         print('Error: %s' % e)
#     # eg. source or destination doesn't exist
#     except IOError as e:
#         print('Error: %s' % e.strerror)


# def smooth_leaps(n_to_try, n_real_morphs):
# 	# n_to_try = 20
# 	# n_real_morphs = 100

# 	step = n_real_morphs/n_to_try
# 	all_povs = sorted(os.listdir(povdirectory),key=keyFunc)
# 	all_povpaths = [os.path.join(povdirectory, f) for f in all_povs]
# 	# ourdirs_png = outdirs
# 	sub_povpaths = all_povpaths[0::step]

# 	tmp_tmppath = [os.path.join(tmpdirectory, f) for f in all_povs[0::step]]
# 	pre = [os.path.splitext(i) for i in tmp_tmppath]
# 	pref = [x[0] for x in pre]
# 	tmppath = [p + '.png' for p in pref]
# 	for idx,pairs in enumerate(zip(sub_povpaths,tmppath)):
# 		os.system('povray +I%s +O%s' % (pairs[0], pairs[1]))
# 		#os.system('qlmanage -p 2>/dev/null %s &' % outpng)
# 	#os.system('killall qlmanage')

# 	fims, im_mat = get_imagemat_fromdir(tmpdirectory)
# 	diffs = get_pairwise_diffs(im_mat,plot=1)

# 	diff_median = np.median(diffs)
# 	fix_idxs = [i for i,v in enumerate(diffs) if v > diff_median]
# 	how_bad = [diffs[i] - diff_median for i in fix_idxs]

# 	addthese = []
# 	for i in fix_idxs:
# 		get_these = range(keyFunc(suboutpath[i]), keyFunc(suboutpath[i+1])+1,1)
# 		ims = ['morph%i.png' % n for n in get_these]
# 		fid, testmat = get_imagemat(imdirectory,ims,ext='.png')
# 		testdiffs = diffs[i]
# 		div = 2
# 		while testdiffs >= diff_median:
# 			print div
# 			m = [testmat[0], testmat[int(ceil(len(testmat)/div))]]
# 			testdiffs = get_pairwise_diffs(m,plot=0)
# 			div += 1
# 		newstep = div-1
# 		addthese.extend([os.path.join(imdirectory, f) for f in fid[0::newstep] if f not in fims])
# 		fims.extend([f for f in fid[0::newstep] if f not in fims])

# 	for i in addthese:
# 		copyFile(i, tmpdirectory)

# 	fims = sorted(fims, key=keyFunc)
# 	n_fims, f_im_mat = get_imagemat(tmpdirectory, fims)
# 	diffs = get_pairwise_diffs(f_im_mat,plot=1)


# def get_even_dists(imdirectory, npoints):
# 	# Get image paths for all ims -- sample from this bank:
# 	all_ims = sorted(os.listdir(imdirectory),key=keyFunc)
# 	all_impaths = [os.path.join(imdirectory, f) for f in all_ims]

# 	fims, im_mat = get_imagemat_fromdir(imdirectory)
# 	diffs = get_pairwise_diffs(im_mat,plot=1)
# 	s = scipy.cumsum(diffs)
# 	#plt.figure()
# 	#plt.plot(s)
# 	stp = list(spread.spread(0,s[-1],npoints+1,mode=3))
# 	indices = []
# 	for n,interval in enumerate(stp[1:len(stp)]):
# 		idx = [i for i,val in enumerate(s) if (val>=interval)]
# 		indices.append(idx)
# 	first_match = [v[0]+1 for v in indices]
# 	#usethese = s[first_match]
# 	#morphids = [i for i,csum in enumerate(s) if csum==usethese[0]
# 	first_match.extend([0])
# 	morphids = sorted(first_match)
# 	morphseq = [all_impaths[x] for x in morphids]
# 	for i in morphseq:
# 		copyFile(i, tmpdirectory)


if __name__ == '__main__':
	run()
	# get_even_dists(imdirectory, npoints)
	#smooth_leaps(n_to_try, n_real_morphs)
	#mat = get_image_mats(imdirectory)
	#d = get_pairwise_diffs(mat)
