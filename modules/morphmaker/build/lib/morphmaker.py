#!/usr/bin/env python2

'''

From an image bank of rendered morphs (.png is default), sample a subset of them to create a sub-sequence of morphs that are more or less equidistant from each other (Euclidian distance between 1D vector of imageN and of imageN+1). Saves the chosen subset into a 'tmp' folder.

imdirectory : imdirectory (dir of morphs to sample from)
tmpdirectory : output directory for sampled
nmorphs : n morphs to sample

'''

import sys, os, os.path
import numpy as np
import scipy as sp
# import matplotlib.pyplot as plt

# import Image
import re
# from imageDiff import *
from morphdiff import *

from scipy.stats import cumfreq
import shutil
import spread


import optparse


# parser = optparse.OptionParser()
# parser.add_option('--headless', action="store_true", dest="headless",
#                   default=False, help="run in headless mode, no figs")

# parser.add_option('--imformat', action="store",
#                   dest="im_format", default="png", help="saved image format")
# parser.add_option('--nmorphs', action="store",
#                   dest="nmorphs", default="20", help="n morphs to generate (not incl anchors)")
# parser.add_option('--append', action="store",
#                   dest="append_name", default="", help="append string to saved file name")
# parser.add_option('--output-path', action="store",
#                   dest="outdir", default="/tmp", help="output path for selected morphs")
# parser.add_option('--input-path', action="store",
#                   dest="imdir", default="/tmp", help="input path of rendered morphs")


# (options, args) = parser.parse_args()

# imdirectory = options.imdir
# tmpdirectory = options.outdir

# im_format = str(options.im_format)
# headless = options.headless

# nmorphs = int(options.nmorphs)


def keyFunc(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))

def copyDirectory(src, dest):
    try:
        shutil.copytree(src, dest)
    # Directories are the same
    except shutil.Error as e:
        print('Directory not copied. Error: %s' % e)
    # Any error saying that the directory doesn't exist
    except OSError as e:
        print('Directory not copied. Error: %s' % e)

def copyFile(src, dest):
    try:
        shutil.copy(src, dest)
    # eg. src and dest are the same file
    except shutil.Error as e:
        print('Error: %s' % e)
    # eg. source or destination doesn't exist
    except IOError as e:
        print('Error: %s' % e.strerror)

def get_even_dists(imdirectory, tmpdirectory, npoints, ext='.png'):
    # Get image paths for all ims -- sample from this bank:

    if '.' not in ext:
        print "adding extension format"
        ext = '.'+ext

    all_ims = sorted([f for f in os.listdir(imdirectory) if f.endswith(ext)], key=keyFunc)
    all_impaths = [os.path.join(imdirectory, f) for f in all_ims]

    fims, im_mat = get_imagemat_fromdir(imdirectory)
    print "IMS: ", len(fims)
    diffs, s = get_pairwise_diffs(im_mat)
    # s = scipy.cumsum(diffs)
    print len(s)
    # plt.figure()
    # plt.plot(s)
    # plt.show()
    stp = list(spread.spread(0, s[-1], npoints+1, mode=3))
    indices = []
    print "LEN: ", len(stp)
    for n,interval in enumerate(stp[1:len(stp)]):
        idx = [i for i,val in enumerate(s) if (val>=interval)]
        indices.append(idx)
    first_match = [v[0]+1 for v in indices]
    #usethese = s[first_match]
    #morphids = [i for i,csum in enumerate(s) if csum==usethese[0]
    first_match.extend([0])
    morphids = sorted(first_match)
    for x in morphids:
        print x, all_impaths[x]
    morphseq = [all_impaths[int(x)] for x in morphids]


    if not os.path.exists(tmpdirectory):
        os.makedirs(tmpdirectory)
    
    for i in morphseq:
        copyFile(i, tmpdirectory)
    for idx,morphname in enumerate(sorted([f for f in os.listdir(tmpdirectory) if f.endswith(ext)],key=keyFunc)):
        old = morphname.split("morph")[1]
        old = old.split('.')[0]
        morphname = os.path.join(tmpdirectory,morphname)
        os.rename(morphname, morphname.replace(old, str(idx)))

    return s

def run():
    get_even_dists(imdirectory,tmpdirectory,int(nmorphs), ext=im_format)

if __name__ == '__main__':
    # imdirectory = sys.argv[1]
    # tmpdirectory = sys.argv[2]
    # # if not os.path.exists(tmpdirectory):
    # #     os.makedirs(tmpdirectory)
    # nmorphs = sys.argv[3]


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

    run()
