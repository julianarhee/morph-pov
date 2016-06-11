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

def key_func(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))


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
parser.add_option('--method', action="store", dest='method', type="choice", choices=['euclid', 'project', 'corr', 'pov'], default='euclid', help="sampling method, euclid | project [default: euclid]")

parser.add_option('--fixedref', action="store_true",
                  dest="fixedref", default="False", help="sample distance measure relative to fixed reference")


parser.add_option('--no-save', action="store_false",
                  dest="save_samples", default="True", help="create new samples and save them")

(options, args) = parser.parse_args()

imdirectory = options.imdir
outdirectory = options.outdir

im_format = str(options.im_format)
headless = options.headless

nmorphs = int(options.nmorphs)
method = options.method

plot = options.plot
fixedref = options.fixedref
save_samples = options.save_samples

print "METHOD: %s" % method

if method=='euclid':

    print "Using Euclidean distance..."
    dists, sums, morphids = euc.get_even_dists_euclidean(imdirectory, outdirectory, int(nmorphs), fixedref, im_format, save_samples)

    euc.plot_all_distances(outdirectory, dists, sums, morphids, fixedref, show_plot=plot)

    euc.plot_sampled_distances(outdirectory, morphids, fixedref, im_format, show_plot=plot)


elif method=='project':

    print "Using scalar projection..."

    projs, idxs = proj.get_projected_morphs(nmorphs, imdirectory, outdirectory, im_format, save_samples)
    proj.plot_all_projections(outdirectory, projs, idxs, im_format, show_plot=plot)
    proj.plot_sampled_projections(outdirectory, idxs, im_format, show_plot=plot)
    # if plot:
        # proj.plot_sampled_projections(projs, idxs, imdirectory, show_plot=plot)

elif method=='corr':

    print "Using correlation..."

    morph_idxs, morph_coeffs, all_coeffs = corr.get_sampled_morphs(imdirectory, outdirectory, nmorphs, fixedref, im_format, save_samples)

    corr.plot_all_distances(outdirectory, all_coeffs, morph_idxs, fixedref=fixedref, show_plot=plot)
    corr.plot_sampled_distances(outdirectory, morph_idxs, fixedref=fixedref, ext='.png', show_plot=plot)

elif method=='pov':

  morphs = os.listdir(imdirectory)
  morphs = sorted([i for i in morphs if im_format in i], key=key_func)
  morphids = range(len(morphs))


  euc.plot_sampled_distances(imdirectory, morphids, fixedref, im_format, show_plot=plot)

  corr.plot_sampled_distances(imdirectory, morphids, fixedref, im_format, show_plot=plot)

  proj.plot_sampled_projections(imdirectory, morphids, im_format, show_plot=plot)
  # print "Plotting each distance measure using INPUT: ", outdirectory

  # A = [i[1] for i in coeffs]
  # B = range(len(A))
  # Z = morphids[1:]

  # fig, (ax1, ax2, ax3) = plt.subplots(3)
  # ax1.plot(B, A, 'r*-')
  # for a, b, z in zip(B, A, Z):
  #     # Annotate the points 5 _points_ above and to the left of the vertex
  #     ax1.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
  #                 textcoords='offset points')
  # ax1.set_title('P-correlaton between image n and n+1')

  # A = scipy.cumsum([i[1] for i in coeffs])
  # B = range(len(A))
  # Z = morphids[1:]
  # ax2.plot(B, A, 'r*-')
  # for a, b, z in zip(B, A, Z):
  #     # Annotate the points 5 _points_ above and to the left of the vertex
  #     ax2.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
  #                 textcoords='offset points')
  # ax2.set_title('Cum sum of sampled')

  # fmorphs_fixed, coeffs_fixed = get_coeffs_fixedref(outdirectory, ext)
  # A = [i[1] for i in coeffs_fixed]
  # B = range(len(A))
  # Z = morphids

  # ax3.plot(B, A, 'r*-')
  # for a, b, z in zip(B, A, Z):
  #     # Annotate the points 5 _points_ above and to the left of the vertex
  #     ax3.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
  #                 textcoords='offset points')
  # ax3.set_title('Relative to FIRST image')


print outdirectory
    
