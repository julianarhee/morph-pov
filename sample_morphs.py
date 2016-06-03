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

# from imagemat import *
import euclid as euc
import projection as proj
import correlation as corr


# if __name__ == '__main__':

parser = optparse.OptionParser()
parser.add_option('--headless', action="store_true", dest="headless",
                  default=False, help="run in headless mode, no figs")
parser.add_option('--plot', action="store_true", dest="plot",
                  default=False, help="show plots of sampled intervals")
parser.add_option('--imformat', action="store",
                  dest="im_format", default=".png", help="saved image format")
parser.add_option('--nmorphs', action="store",
                  dest="nmorphs", default="20", help="n morphs to generate (not incl anchors)")
parser.add_option('--append', action="store",
                  dest="append_name", default="", help="append string to saved file name")
parser.add_option('--output-path', action="store",
                  dest="outdir", default="/tmp", help="output path for selected morphs")
parser.add_option('--input-path', action="store",
                  dest="imdir", default="/tmp", help="input path of rendered morphs")
parser.add_option('--method', action="store", dest='method', type="choice", choices=['euclid', 'project', 'corr'], default='euclid', help="sampling method, euclid | project [default: euclid]")

(options, args) = parser.parse_args()

imdirectory = options.imdir
outdirectory = options.outdir

im_format = str(options.im_format)
headless = options.headless

nmorphs = int(options.nmorphs)
method = options.method

plot = options.plot

print "METHOD: %s" % method

if method=='euclid':

    print "Using Euclidean distance..."

    dists, cumsumd, morphids = euc.get_even_dists_euclidean(imdirectory, outdirectory, int(nmorphs), im_format)

    if plot:
        euc.plot_euclidean(imdirectory, dists, cumsumd, morphids, show_plot=True)

elif method=='project':

    print "Using scalar projection..."

    projs, idxs = proj.get_projected_morphs(nmorphs, imdirectory, outdirectory, im_format)
    
    if plot:
        proj.plot_sample_projections(projs, idxs, imdirectory, show_plot=plot)

elif method=='corr':

    print "Using correlation..."

    idxs, coeffs = corr.get_sampled_morphs(nmorphs, imdirectory, outdirectory, im_format)

    if plot:
        corr.plot_sampled_morphs(idxs, coeffs, imdirectory, show_plot=plot)

print outdirectory
    
