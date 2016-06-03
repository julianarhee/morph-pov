#!/usr/bin/env python2

'''

From a matrix of images (each row is the "unraveled" vector of an image in the dir), calculate Euclidian distance between them, i.e., || ROW2-ROW1 || ** 2.

This can be run directly from the command line:
$ python euclid.py --input-path='/path/to/image/dir' --output-path='/path/to/save/dir' --nmorphs=N (not including anchors)

If plot is True, show a plot of euclidean distance between each n and n+1 image in the image directory.

input-path : imdirectory (dir of povray-generated morphs to calculate distance between)
output-path : directory to save sampled morphs to
nmorphs : number of morphs to create between anchors (totalling N+2 images)

'''

# __init__.py is empty except for imports.
import sys, os, os.path
import scipy.spatial
try:
    import Image
except:
    from PIL import Image
import numpy as np
import re
import matplotlib.pyplot as plt

import optparse
# from fractions import Fraction

import imagemat
import spread

import math
import shutil

from scipy.stats.stats import pearsonr

def key_func(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))

def copy_file(src, dest):
    try:
        shutil.copy(src, dest)
    # eg. src and dest are the same file
    except shutil.Error as e:
        print('Error: %s' % e)
    # eg. source or destination doesn't exist
    except IOError as e:
        print('Error: %s' % e.strerror)

# imdirectory = '/tmp/morph20/im'
# imdirectory = '/tmp/morph5000_euclid'
# imdirectory = '/tmp/morph5000/im'

# outdirectory = '/tmp/morph_project'
# ext = '.png' #im_format
# nmorphs = 20

def get_coeffs(imdirectory, ext):

    '''
    Return vector of correlation coefficients. 
    '''

    fmorphs = [f for f in os.listdir(imdirectory) if f.endswith(ext)]
    fmorphs = sorted(fmorphs,key=key_func)

    curr_vect_idx = 0
    start_morph = fmorphs[curr_vect_idx]
    img = Image.open(os.path.join(imdirectory, start_morph)).convert('F')
    start_vect = np.array(img).ravel()

    # coeffs = []
    # # coeffs.append([curr_vect_idx, start_vect])
    # curr_vect_idx += 1
    # while True:
    #     curr_morph = Image.open(os.path.join(imdirectory, fmorphs[curr_vect_idx])).convert('F')
    #     curr_vect = np.array(curr_morph).ravel()

    #     curr_corr = pearsonr(start_vect, curr_vect)

    #     coeffs.append([curr_vect_idx, curr_corr[0]])

    #     curr_vect_idx += 1

    #     if curr_vect_idx >= len(fmorphs):
    #         break

    coeffs = []
    # coeffs.append([curr_vect_idx, start_vect])
    curr_vect_idx = 0

    while True:
        curr_morph = Image.open(os.path.join(imdirectory, fmorphs[curr_vect_idx])).convert('F')
        curr_vect = np.array(curr_morph).ravel()

        curr_corr = pearsonr(start_vect, curr_vect)
        coeffs.append([curr_vect_idx, curr_corr[0]])

        curr_vect_idx += 1

        if curr_vect_idx >= len(fmorphs):
            break

    return fmorphs, coeffs


def find_samples(coeffs, nmorphs):
    # Sample evenly:
    coeff_vals = np.array([i[1] for i in coeffs])
    strt = float(coeff_vals.min())
    last = float(coeff_vals.max())
    sample_space = list(spread.spread(strt, last, nmorphs+1, mode=3))

    # idxs = []
    # print "LEN: ", len(sample_space)
    # morph_coeffs = [i[1] for i in coeffs]
    # for n,curr_bin in enumerate(sample_space[1:len(sample_space)-1]): # 1st and last images will always be anchors, just need to find the middle indices
    #     print n
    #     sample_idx = np.where(morph_coeffs == min(morph_coeffs, key=lambda x: abs(float(x) - curr_bin)))[0][0]
    #     idxs.append(sample_idx)

    idxs = []
    print "LEN: ", len(sample_space)
    for n,curr_bin in enumerate(sample_space): # 1st and last images will always be anchors, just need to find the middle indices
        print n
        sample_idx = np.where(coeff_vals == min(coeff_vals, key=lambda x: abs(float(x) - curr_bin)))[0][0]
        idxs.append(sample_idx)

    return idxs

def plot_sampled_morphs(morph_sample_idxs, morph_sample_coeffs, imdirectory, show_plot=True):

    A = morph_sample_coeffs
    B = range(len(A))#np.ones((len(A),1))
    Z = morph_sample_idxs

    fig, ax = plt.subplots()

    ax.plot(A, B, 'r*')
    for a, b, z in zip(A, B, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')

    plt.title('Sampled morphs based on correlation of pixels (relative to Im 1)')

    imname = 'correlate_from_im1'
    figdir = os.path.join(os.path.split(imdirectory)[0], 'figures')

    if not os.path.exists(figdir):
        os.makedirs(figdir)

    impath = os.path.join(figdir, imname+'.png')
    plt.savefig(impath, format='png')
    print "Saved interval graph: %s" % impath

    if show_plot:
        plt.show()


def get_sampled_morphs(nmorphs, imdirectory, outdirectory, ext):

    fmorphs, coeffs = get_coeffs(imdirectory, ext)
    idxs = find_samples(coeffs, nmorphs)

    # if show_plot:
    #     plot_sample_projections(projections, idxs, imdirectory)

    morph_sample_coeffs = [coeffs[idx][1] for idx in idxs]

    morph_sample_idx = [coeffs[idx][0] for idx in idxs]
    # morph_sample_idx.append(0) # add anchor 1
    # morph_sample_idx.append(len(fmorphs)-1) # add anchor 2
    # morph_sample_idx = sorted(morph_sample_idx)

    morph_sample_paths = [os.path.join(imdirectory, fmorphs[midx]) for midx in morph_sample_idx]

    if not os.path.exists(outdirectory):
        os.makedirs(outdirectory)

    for m in morph_sample_paths:
        copy_file(m, outdirectory)
        print "Copied files to %s: ", outdirectory

    morph_list = sorted([f for f in os.listdir(outdirectory) if f.endswith(ext)],key=key_func)
    for midx,morphname in enumerate(morph_list):
        old = morphname.split("morph")[1]
        old = old.split('.')[0]
        morphname = os.path.join(outdirectory,morphname)
        os.rename(morphname, morphname.replace(old, str(midx)))

    return morph_sample_idx, morph_sample_coeffs

def run():
    parser = optparse.OptionParser()

    parser.add_option('--imformat', action="store",
                      dest="ext", default="png", help="saved image format")
    parser.add_option('--output-path', action="store",
                      dest="outdir", default="/tmp", help="output path for selected morphs")
    parser.add_option('--input-path', action="store",
                      dest="imdir", default="/tmp", help="input path of rendered morphs")
    parser.add_option('--plot', action="store_true",
                      dest="plot", default="False", help="plot distance and cumsum (don't use to just save)")
    parser.add_option('--nmorphs', action="store",
                      dest="nmorphs", default="20", help="n morphs to generate (not incl anchors)")

    (options, args) = parser.parse_args()

    imdir = options.imdir
    outdir = options.outdir
    ext = str(options.ext)
    if '.' not in ext:
        ext='.'+ext
    plot = options.plot
    nmorphs = int(options.nmorphs)


    morph_sample_idxs, morph_sample_coeffs = get_sampled_morphs(nmorphs, imdir, outdir, ext)

    plot_sampled_morphs(morph_sample_idxs, morph_sample_coeffs, imdir, show_plot=plot)

if __name__ == '__main__':
    run()