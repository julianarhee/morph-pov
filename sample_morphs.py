#!/usr/bin/env python2

'''

Take all images in a specified directory, create a matrix with each row being the "unraveled" vector of an image in the dir, then calculate Euclidian distance between them, i.e., || ROW2-ROW1 || ** 2.

This can be run directly from the command line:
$ python morphdiff.py /path/to/image/dir .imageformat
This will give a plot of euclidean distance between each n and n+1 image in the image directory.


imdirectory : imdirectory (dir of morphs to calculate distance between)
fmt : format of input images

'''

# __init__.py is empty except for imports.
import sys, os, os.path
import scipy.spatial
import numpy as np
import re
import matplotlib.pyplot as plt

import optparse

from morphdiff import *
from morphmaker import *



if __name__ == '__main__':

	parser = optparse.OptionParser()
	parser.add_option('--headless', action="store_true", dest="headless",
	                  default=False, help="run in headless mode, no figs")

	parser.add_option('--imformat', action="store",
	                  dest="im_format", default="png", help="saved image format")
	parser.add_option('--nmorphs', action="store",
	                  dest="nmorphs", default="20", help="n morphs to generate (not incl anchors)")
	parser.add_option('--append', action="store",
	                  dest="append_name", default="", help="append string to saved file name")
	parser.add_option('--output-path', action="store",
	                  dest="outdir", default="/tmp", help="output path for selected morphs")
	parser.add_option('--input-path', action="store",
	                  dest="imdir", default="/tmp", help="input path of rendered morphs")


	(options, args) = parser.parse_args()

	imdirectory = options.imdir
	tmpdirectory = options.outdir

	im_format = str(options.im_format)
	headless = options.headless

	nmorphs = int(options.nmorphs)

	get_even_dists(imdirectory,tmpdirectory,int(nmorphs), ext='.'+im_format)



	