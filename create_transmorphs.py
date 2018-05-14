#!/usr/bin/env python2

import os
import sys
import numpy as np
from make_pov_morphs import make_morphs
import optparse

parser = optparse.OptionParser()

parser.add_option('--imformat', action="store",
		  dest="im_format", default="png", help="saved image format")
parser.add_option('--nmorphs', action="store",
		  dest="nmorphs", default=20, help="n morphs to generate (not incl anchors)")
parser.add_option('--output-path', action="store",
		  dest="outdir", default="/tmp", help="output path for rendered images and povs")
parser.add_option('-s', '--yrot_start', action="store",
		  dest="yrot_start", default=0, help="Y rotation start angle [default 0]")
parser.add_option('-e', '--yrot_stop', action="store",
		  dest="yrot_stop", default=0, help="Y rotation end angle [default 0]")
parser.add_option('-i', '--yrot_step', action="store",
		  dest="yrot_step", default=0, help="Y rotation step size [default 0]")



(options, args) = parser.parse_args()

outdir = options.outdir
im_format = str(options.im_format)
n_real_morphs = int(options.nmorphs)

YROT_start = int(options.yrot_start)
YROT_stop = int(options.yrot_stop)
YROT_step = int(options.yrot_step)

yrots = [int(i) for i in np.arange(YROT_start, YROT_stop+YROT_step, YROT_step)]
print yrots


for yrot in yrots:
    print "*******************************************************************"
    print "CREATING MORPHS for Y-ROT: %i" % yrot
    print "*******************************************************************"   
    morphs_opts = ['--imformat=%s' % im_format,
		   '--output-path=%s' % outdir,
                   '--nmorphs=%i' % n_real_morphs,
                   '-y', yrot]
    make_morphs(morphs_opts)
    print "DONE"
    print "*******************************************************************"
