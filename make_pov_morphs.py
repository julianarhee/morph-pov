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
import optparse
from utils.mapping import sigmap, linmap

def make_morphs(options):
    parser = optparse.OptionParser()
    parser.add_option('--headless', action="store_true", dest="headless",
                      default=False, help="run in headless mode, no figs")
    
    parser.add_option('--imformat', action="store",
                      dest="im_format", default="png", help="saved image format")
    parser.add_option('--nmorphs', action="store",
                      dest="nmorphs", default=20, help="n morphs to generate (not incl anchors)")
    parser.add_option('--append', action="store",
                      dest="append_name", default="", help="append string to saved file name")
    parser.add_option('--output-path', action="store",
                      dest="outdir", default="/tmp", help="output path for rendered images and povs")
    parser.add_option('-x', '--xrot', action="store",
                      dest="xrot", default=0, help="X rotation for OBJECT [default 0]")
    parser.add_option('-y', '--yrot', action="store",
                      dest="yrot", default=0, help="Y rotation for OBJECT [default 0]")
    parser.add_option('-z', '--zrot', action="store",
                      dest="zrot", default=0, help="Z rotation for OBJECT [default 0]")
    
    (options, args) = parser.parse_args(options)
    
    outdir = options.outdir
    im_format = str(options.im_format)
    headless = options.headless
    n_real_morphs = int(options.nmorphs)
    
    XROT = int(options.xrot)
    YROT = int(options.yrot)
    ZROT = int(options.zrot)
    
    # Create new output directory if it doesn't exist:
    povdirectory =  '%s/pov' % outdir
    if not os.path.exists(povdirectory):
        os.makedirs(povdirectory)
    
    imdirectory =  '%s/im' % outdir
    if not os.path.exists(imdirectory):
        os.makedirs(imdirectory)
    
    tmpdirectory =  '%s/tmp' % outdir
    if not os.path.exists(tmpdirectory):
        os.makedirs(tmpdirectory)
    
    # ==================================================================
    # SET NUM OF MORPHS BETWEEN Strt and End:
    # ==================================================================
    n_total_morphs = n_real_morphs+2 # first and last 'morph' are the originals
    
    
    # CAMERA -------------------------
    cam_loc_start = np.array([0,0,-10])
    cam_loc_end = np.array([0,0,-10])
    cam_loc_diff = cam_loc_end - cam_loc_start
    cam_angle = 15
    cam_lookat = np.array([0,0,0])
    
    # LIGHT SOURCE -------------------
    light_loc_start  = np.array([0,-10,-10])
    light_loc_end = np.array([0,-10,-10])
    light_loc_diff = light_loc_end - light_loc_start
    
    # BLOBS --------------------------
    n_total_spheres = 4
    
    class Sphere(object):
    
        def __init__(self, param_vec):
            self.translation = param_vec[0] #translation
            self.scale = param_vec[1] #scale
            self.rotation = param_vec[2] #rotation
    
        def method(self, arg):
        	return True
    
    class Step(object):
    
        def __init__(self, diff_vec, n_morphs):
        	self.translation = linmap(diff_vec[0], n_morphs) # steps for translatnig
        	self.scale = linmap(diff_vec[1], n_morphs) # steps for scaling
        	self.rotation = linmap(diff_vec[2], n_morphs) # steps for rotating
        
        def method(self, arg):
        	return True
    
    
    # Sphere 1 ("base" of blob) ------------------------------
    # BLOB 1:
    # //sfera (culo)
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, -0.4, 0.5>
    # 	scale<1, 1, 1>
    # 	rotate <0,0,0>
    # }
    
    # BLOB 2:
    # //sfera (culo)
    # sphere { <0,0,0>, .8, 1  
    # //    	translate <0, -0.2, 0.5>
    # 	translate <0, -0.2, 0.7>
    # 	scale<0.8, 1.4, 0.8>
    # //    	rotate <30,0,0>
    # 	rotate <20,0,0>
    # }
    sphere1_start = np.array([
    					[0., -0.4, 0.5], # translate
    					[1., 1., 1.], 	 # scale
    					[0., 0., 0.]     # rotate
    					])
    sphere1_end = np.array([
    					[0., -0.2, 0.7], 
    					[0.8, 1.4, 0.8], 
    					[20., 0., 0.]
    					])
    sphere1_diff = sphere1_end - sphere1_start 
    
    # Sphere 2 ("head" of blob1 ("left lobe" of blob2)) ------
    # BLOB 1:
    # // lenticchia (muso/nasone)
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, 0, -0.5>
    # 	scale<1.8, 0.6, 1.8>
    # 	rotate <30,0,0>    
    # }
    
    # BLOB 2:
    # // orecchia sx
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, 0, -0.5>
    # 	scale<0.6, 0.6, 2>
    # 	rotate <40,0,55>    
    # }
    sphere2_start = np.array([
    					[0., 0., -0.5], 
    					[1.8, 0.6, 1.8], 
    					[30., 0., 0.]
    					])
    sphere2_end = np.array([
    					[0., 0., -0.5], 
    					[0.6, 0.6, 2.], 
    					[40., 0., 55.]
    					]) # LEFT EAR
    sphere2_diff = sphere2_end - sphere2_start
    
    # Sphere 4 (still "head" of blob1 ("right lobe" of blob2)) -----
    # BLOB 1:
    # //sfera (culo)
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, -0.4, 0.5>
    # 	scale<1, 1, 1>
    # 	rotate <0,0,0>
    # }
    
    # BLOB 2"
    # // orecchia dx
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, 0, -0.5>
    # 	scale<0.6, 0.6, 2>
    # 	rotate <40,0,-55>    
    # }    
    
    sphere4_start = np.array([
    					[0., 0., -0.5], 
    					[1.8, 0.6, 1.8], 
    					[30. ,0. , 0.]
    					])
    # sphere4_start = np.array([
    # 					[0, -0.4, 0.5], 
    # 					[1, 1, 1], 
    # 					[0,0,0]
    # 					])
    sphere4_end = np.array([
    					[0., 0., -0.5], 
    					[0.6, 0.6, 2.], 
    					[40., 0., -55.]
    					]) # RIGHT EAR
    sphere4_diff = sphere4_end - sphere4_start
    
    
    # Sphere 3:  "nose" of blob1 -----------------------------
    # BLOB 1:
    # // capsula (labbro inferiore)
    # sphere { <0,0,0>, .8, 1  
    # 	translate <0, 0, -0.5>
    # 	scale<0.5, 0.5, 1>
    # 	rotate <-45,0,0>  
    # }
    
    
    sphere3_start = np.array([
    					[0., 0., -0.5], 
    					[0.5, 0.5, 1.], 
    					[-45., 0., 0.]
    					])
    
    sphere3_end = np.array([
    					[0., 0., 0.], 
    					[0., 0., 0.], 
    					[0., 0., 0.]
    					])
    sphere3_diff = sphere3_end - sphere3_start
    
    # Add size parameter to reduce "radius" arg in POVray's "sphere" to 0:
    nosesize_start = 0.8
    nosesize_end = 0
    nosesize_diff = nosesize_end - nosesize_start
    
    
    
    # --------------------------------------------------------
    # Create lists parameter dicts:
    # --------------------------------------------------------
    
    cam_loc_steps = linmap(cam_loc_diff, n_total_morphs)
    light_loc_steps = linmap(light_loc_diff, n_total_morphs)
    
    # EX:  p_start[N].__dict__['translation']
    # calls starting translation value for sphereN+1
    
    p_start = [Sphere(sphere1_start), Sphere(sphere2_start), Sphere(sphere3_start), Sphere(sphere4_start)]
    
    p_end = [Sphere(sphere1_end), Sphere(sphere2_end), Sphere(sphere3_end), Sphere(sphere4_end)]
    
    p_steps = [Step(sphere1_diff, n_total_morphs), Step(sphere2_diff, n_total_morphs), Step(sphere3_diff, n_total_morphs), Step(sphere4_diff, n_total_morphs)]
    
    # # Add step parameter for nose:
    nosesize_steps = linmap(nosesize_diff, n_total_morphs)
    
    
    
    # additional scale parameter, so that masking with strengthA vs strengthB doesnt look so weird...
    s_scale5 = np.array([1.8, 0.6, 1.8])
    # e_scale5 = np.array([1.8, 0.6, .9])
    e_scale5 = np.array([1.8, 0.6, 0.9])
    diff_scale5 = e_scale5 - s_scale5
    
    scale5_steps = linmap(diff_scale5, n_total_morphs)
    
    
    # OBJECT params:
    # object_trans_start = np.array([0, -0.18, 5])
    # object_trans_start = np.array([0, -0.18, -5]) xxx
    # object_trans_end = np.array([0,0,0])
    
    object_trans_start = np.array([0, -0.18, 5])
    object_trans_end = np.array([0,0,6])
    
    
    # object_trans_start = np.array([0, 0, 0])
    # object_trans_end = np.array([0,0,0])
    
    
    ## FROM PERL SCRIPTS:
    # # Location of the whole object/stimulus (x,y,z)
    # @StimPos1 = qw( 0 -0.18 5 );
    # @StimPos2 = qw( 0 0 6 );
    # # Size of the whole object/stimulus (x,y,z)
    # @StimSize1 = qw( 0 1.02 0 );
    # @StimSize2 = qw( 0 0 0 );
    
    
    
    object_trans_diff = object_trans_end - object_trans_start
    
    object_trans_steps = linmap(object_trans_diff, n_total_morphs)
    
    # POVRay:  SCALE of 0's is actually 1x:
    
    # object_scale_start = np.array([0, 1.02, 0])
    # object_scale_end = np.array([0, 0, 0])
    
    object_scale_start = np.array([1., 1.02, 1.])
    object_scale_end = np.array([1.,1.,1.])
    
    # object_scale_start = np.array([0,0,0])
    # object_scale_end = np.array([0,0,0])
    
    
    # object_scale_start = np.array([1,1.02,1])
    # object_scale_end = np.array([1, 1, 1])
    
    object_scale_diff = object_scale_end - object_scale_start
    # object_scale_diff = object_scale_start - object_scale_end
    
    object_scale_steps = linmap(object_scale_diff, n_total_morphs)
    
      	# rotate <0, 0, 0>
      	# translate <0, -0.18, 5>
      	# scale <0 1.02 0>
      	# pigment {White} 
      	# finish {
       #     phong 0.0
       #     ambient 0.4 //0.3
       #     diffuse 0.6
       #  }
    
       #    	rotate <0,0,0>
      	# translate <0,0,0>
      	# scale <0,0,0>
      	# pigment {White} 
      	# finish {
      	#    phong 0.0
       #     ambient 0.4 //0.3
       #     diffuse 0.6
       #  }
    
    
    
    # --------------------------------------------------------
    # CUSTOM STEP FUNCTIONS (optional):
    # --------------------------------------------------------
    
    # MAPPING INPUTS (in normal speak):
    #
    # nmorphs : 
    #		num of actual morphs you want (even number in order to split 
    # 		stimuli evenly between 2 class, for ex.) PLUS 2 (start & end stim)
    #
    # constrain[x,y]  :  
    # 		x is the morph number you want to reset to 0 
    #		y is the morph num you want so that sig(y)=1
    #
    # 		EX: [5,15] makes morph5 the new start of the sigmoid, which reaches
    #		its end at 1 on morph No. 15.
    #
    # 		EX2:  If you just want to shift the sig curve over, and have it end 
    #		normally, i.e., with sig(last-morph)=1, set y=nmorphs-1
    #
    # a  :  
    #		alpha value for the general sigmoid function (changes the slope)
    #		At a=1, middle is halfway; a<1 (shallower slope); a>1 (steeper).
    #
    # b  :  
    #		beta value for the general sigmoid function (translates)
    #		At b=0, middle is halfway; b>0 shifts leftward (rise occurs earlier),
    #		while b<0 shifts rightward (rise occurs later).  
    
    
    # diff_vec indices:
    trans_idx = 0
    scale_idx = 1
    rot_idx = 2
    
    # BASE, i.e., sfera (culo) ----------------------------
    # corresponds to Sphere1, index w/ 0:
    # -----------------------------------------------------
    custom_sphere1 = False
    curr_idx = 0
    curr_diff_vec = sphere1_diff
    
    if custom_sphere1 == True:
    
    	p_steps[curr_idx].__dict__['translation'] = linmap(curr_diff_vec[trans_idx],n_total_morphs)
    
    	p_steps[curr_idx].__dict__['scale'] = sigmap(curr_diff_vec[scale_idx],n_total_morphs,a=.5,b=-1) #a=.6,b=0)
    
    	p_steps[curr_idx].__dict__['rotation'] = linmap(curr_diff_vec[rot_idx],n_total_morphs)
    
    
    # HEAD1 | L-EAR, i.e., lenticchia (muso/nasone) | orecchia sx
    # corresponds to Sphere2, index w/ 1:
    # -----------------------------------------------------
    custom_sphere2 = False
    curr_idx = 1
    curr_diff_vec = sphere2_diff
    
    if custom_sphere2 == True:
    
    	# TRANSLATION ---------------------------------------------------------
    	lim15 = int(np.ceil((n_total_morphs+2)*(15./22)))
    	lim10 = int(np.ceil((n_total_morphs+2)*(10./22)))
    
    	p_steps[curr_idx].__dict__['translation'] = sigmap(curr_diff_vec[trans_idx],n_total_morphs) # no change
    
    	# SCALE ---------------------------------------------------------
    	# This is an example where you want to change x, y, and z axis differently:
    	step_scale2x = sigmap(curr_diff_vec[scale_idx],n_total_morphs,constrain=[0,lim15],a=1,b=2) # thinning
    	step_scale2y = linmap(curr_diff_vec[scale_idx],n_total_morphs) # no change
    	step_scale2z = sigmap(curr_diff_vec[scale_idx],n_total_morphs,constrain=[lim10,n_total_morphs-1],a=.8 ,b=0) # 0.2 elong
    
    	p_steps[curr_idx].__dict__['scale'] = np.asarray([step_scale2x[:,0], step_scale2y[:,1], step_scale2z[:,2]]).T
    
    	# ROTATION ---------------------------------------------------------
    	lim3 = int(np.ceil((n_total_morphs+2)*(3./22)))
    
    	step_rot2x = sigmap(curr_diff_vec[rot_idx], n_total_morphs, constrain=[lim3, (n_total_morphs-1)],a=1,b=2) #-1
    	step_rot2y = linmap(curr_diff_vec[rot_idx], n_total_morphs) # y doesn't change
    	step_rot2z = sigmap(curr_diff_vec[rot_idx], n_total_morphs,constrain=[0,(n_total_morphs-1)],a=.7,b=3)
    
    	p_steps[curr_idx].__dict__['rotation'] = np.asarray([step_rot2x[:,0], step_rot2y[:,1], step_rot2z[:,2]]).T
    
    
    # HEAD2 | R-EAR, i.e., lenticchia (muso/nasone) | orecchia dx
    # corresponds to Sphere4, index w/ 3:
    # -----------------------------------------------------
    custom_sphere4 = False
    curr_idx = 3
    curr_diff_vec = sphere4_diff
    
    if custom_sphere4 == True:
    
    	# TRANSLATION ---------------------------------------------------------
    	p_steps[curr_idx].__dict__['translation'] = sigmap(curr_diff_vec[trans_idx], n_total_morphs) # no change
    
    	step_scale4x = sigmap(curr_diff_vec[scale_idx], n_total_morphs, constrain = [0,lim15], a=1, b=2)
    
    	step_scale4y = linmap(curr_diff_vec[scale_idx], n_total_morphs) # no change
    
    	step_scale4z = sigmap(curr_diff_vec[scale_idx], n_total_morphs, constrain = [lim10, nmorphs-1], a=.8, b=0) # 0.2 change
    
    	# SCALE ---------------------------------------------------------
    	p_steps[curr_idx].__dict__['scale'] = np.asarray([step_scale4x[:,0], step_scale4y[:,1], step_scale4z[:,2]]).T
    
    
    	# ROTATION ---------------------------------------------------------
    	step_rot4x = sigmap(curr_diff_vec[rot_idx], n_total_morphs, constrain=[lim3,(nmorphs-1)],a=1,b=2) #-1
    
    	step_rot4y = linmap(curr_diff_vec[rot_idx], n_total_morphs) # y doesn't change
    	step_rot4z = sigmap(curr_diff_vec[rot_idx], n_total_morphs, constrain=[0,(nmorphs-1)],a=.7,b=3) #[0,21],a=.7,b=3)
    
    	p_steps[curr_idx].__dict__['rotation'] = np.asarray([step_rot4x[:,0], step_rot4y[:,1], step_rot4z[:,2]]).T
    
    
    # NOSE | ___, i.e., capsula (labbro inferiore) | NA
    # corresponds to Sphere3, index w/ 2:
    # -----------------------------------------------------
    custom_sphere3 = False
    curr_idx = 2
    curr_diff_vec = sphere3_diff
    
    if custom_sphere3 == True:
    
    	p_steps[curr_idx].__dict__['translation'] = linmap(curr_diff_vec[trans_idx], n_total_morphs)
    
    	p_steps[curr_idx].__dict__['scale'] = linmap(curr_diff_vec[scale_idx], n_total_morphs)
    
    	p_steps[curr_idx].__dict__['rotation'] = linmap(curr_diff_vec[rot_idx], n_total_morphs)
    
    	nosesize_steps = sigmap(nosesize_diff, n_total_morphs) #,a=.6, b=-2)
    
    
    print "NOSE: ", nosesize_steps
    # ---------------------------------------------------------------------------
    # SET THE STARTING PARAMETER VALUES (Object A, or B):
    # ---------------------------------------------------------------------------
    config = {k+str(i+1): '<%s>' % ', '.join(map(str, p_start[i].__dict__[k])) for i in range(len(p_start)) for k in p_start[i].__dict__.keys()}
    
    config['cam_loc'] = '<%s>' % ', '.join(map(str, cam_loc_start))
    config['light_loc'] = '<%s>' % ', '.join(map(str, light_loc_start))
    
    config['nosesize'] = nosesize_start # + nosesize_steps[0]
    
    config['scale5'] = '<%s>' % ', '.join(map(str, s_scale5))
    
    config['object_translation'] = '<%s>' % ', '.join(map(str, object_trans_start))
    config['object_scale'] = '<%s>' % ', '.join(map(str, object_scale_start))
    
    # config = {
    # 	# 'camloc': '<%s>' % ', '.join(map(str, s_camloc)),
    # 	'cam_loc': '<%s>' % ', '.join(map(str, s_cam_loc)),
    # 	'translate1': '<%s>' % ', '.join(map(str, s_trans1)),
    # 	'scale1': '<%s>' % ', '.join(map(str, s_scale1)),
    # 	'rotate1': '<%s>' % ', '.join(map(str, s_rot1)),
    
    # 	'translate2': '<%s>' % ', '.join(map(str, s_trans2)),
    # 	'scale2': '<%s>' % ', '.join(map(str, s_scale2)),
    # 	'rotate2': '<%s>' % ', '.join(map(str, s_rot2)),
    
    # 	'translate3': '<%s>' % ', '.join(map(str, s_trans3)),
    # 	'scale3': '<%s>' % ', '.join(map(str, s_scale3)),
    # 	'rotate3': '<%s>' % ', '.join(map(str, s_rot3)),
    # 	'nosesize': s_nosesize,
    
    # 	'translate4': '<%s>' % ', '.join(map(str, s_trans4)),
    # 	'scale4': '<%s>' % ', '.join(map(str, s_scale4)),
    # 	'rotate4': '<%s>' % ', '.join(map(str, s_rot4)),
    # 	'scale5': '<%s>' % ', '.join(map(str, s_scale5)),
    # }	
    

#def run():

	# SET NUMBER OF MORPHS BETWEEN OBJECT A and OBJECT B, and create .pov files for each morph in "templates" folder.

	# Generated .pov files can then be run in a batch with the POVRAY3_7_Unofficial GUI, which can then output .png files for each rendered morph into "output" folder.

	# nmorphs = 21
    for morph_num in range(n_total_morphs):

	strengthA = float(morph_num) / (n_total_morphs-1)
	strengthB = 1.0 - strengthA

	config.update(

		{k+str(i+1): '<%s>' % ', '.join(map(str, p_start[i].__dict__[k] + p_steps[i].__dict__[k][morph_num])) for i in range(len(p_start)) for k in p_start[i].__dict__.keys()}

		)

	config['nosesize'] = nosesize_start + nosesize_steps[morph_num]

	config['cam_loc'] ='<%s>' % ', '.join(map(str, cam_loc_start + cam_loc_steps[morph_num]))

	config['light_loc'] = '<%s>' % ', '.join(map(str, light_loc_start + light_loc_steps[morph_num]))

	config['strengthA'] = float(strengthA)
	config['strengthB'] = float(strengthB)

	# if morph_num==n_total_morphs:
	# 	config['scale5'] = '<%s>' % ', '.join(map(str, [0, 0, 0]))
	# else:
	config['scale5'] = '<%s>' % ', '.join(map(str, s_scale5 + scale5_steps[morph_num]))

	config['object_translation'] = '<%s>' % ', '.join(map(str, object_trans_start + object_trans_steps[morph_num]))

	config['object_scale'] = '<%s>' % ', '.join(map(str, object_scale_start + object_scale_steps[morph_num]))

	config['object_rotation'] = '<%i, %i, %i>' % (XROT, YROT, ZROT)


	command = """
	#include "colors.inc"

	background{Black}

	camera{
		angle 15
		location {{ cam_loc }}
		look_at <0,0,0>
	}

	light_source{ {{light_loc}} color White}

	#declare StimBlob1 = blob {
	    threshold 0.2

	    //base (bottom)
	    sphere { <0,0,0>, .8, 1  
		translate {{ translation1 }}
		scale {{ scale1 }}
		rotate {{ rotation1 }}
	    }
	    
	    
	    // original head disc
	    sphere { <0,0,0>, .8, {{strengthB}}  
		translate <0.0, 0.0, -0.5>
		scale {{ scale5 }}
		rotate <30.0, 0.0, 0.0>   
	    }
	    

	    // LEFT EAR
	    sphere { <0,0,0>, .8, {{strengthA}}
		translate <0.0, 0.0, -0.5>
		scale <0.6, 0.6, 2.0>
		rotate <40.0, 0.0, 55.0>   
	    }


	    // RIGHT EAR
	    sphere { <0,0,0>, .8, {{strengthA}} 
		translate <0.0, 0.0, -0.5>
		scale <0.6, 0.6, 2.0>
		rotate <40.0, 0.0, -55.0>   
	    }
	    
	    // nose protrusion
	    sphere { <0,0,0>, {{ nosesize }}, 1  
		translate {{ translation3 }}
		scale {{ scale3 }}
		rotate {{ rotation3 }}
	    }
	}

	object{ StimBlob1 
		rotate {{object_rotation}}
		translate {{object_translation}}
		scale {{object_scale}}
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
	outpath = povdirectory + '/morph%i_y%i.pov' % (int(morph_num), int(YROT))
	impath = imdirectory + '/morph%i_y%i.%s' % (int(morph_num), int(YROT), im_format)
	with open(outpath, "wb") as fn:
		fn.write(command)

	# deprecated, but who cares
	AspRat = 320/240. #320/240
	xres = 1100 #1875 #2400 #1100

	yres = int (xres / AspRat )
	# yres = 1393
	os.system('povray +I%s +O%s +W%s +H%s -D' % (outpath, impath, str(xres), str(yres))) # -D switch turns off graphic display
	
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

def main(options):
    make_morphs(options)

if __name__ == '__main__':
	main(sys.argv[1:])
	# get_even_dists(imdirectory, npoints)
	#smooth_leaps(n_to_try, n_real_morphs)
	#mat = get_image_mats(imdirectory)
	#d = get_pairwise_diffs(mat)
