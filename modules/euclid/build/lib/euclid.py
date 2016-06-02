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
# try:
#     import Image
# except:
#     from PIL import Image
# import numpy as np
import re
import matplotlib.pyplot as plt

import optparse
# from fractions import Fraction

import imagemat
import spread
import shutil

def key_func(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))


def copy_directory(src, dest):
    try:
        shutil.copytree(src, dest)
    # Directories are the same
    except shutil.Error as e:
        print('Directory not copied. Error: %s' % e)
    # Any error saying that the directory doesn't exist
    except OSError as e:
        print('Directory not copied. Error: %s' % e)


def copy_file(src, dest):
    try:
        shutil.copy(src, dest)
    # eg. src and dest are the same file
    except shutil.Error as e:
        print('Error: %s' % e)
    # eg. source or destination doesn't exist
    except IOError as e:
        print('Error: %s' % e.strerror)


def get_pairwise_diffs(im_mat):

    '''
    
    Each row is an unraveled image. Take Euclid distance between each, over pairwise combinations.
    Pairs are only consecutive images (not all combinations). 

    i.e,. this assumes that the diff between x3 and x2 is smaller than the diff between x3 and x1.

    '''
    
    diffs = [scipy.spatial.distance.euclidean(x[1],x[0]) for x in zip(im_mat[1:],im_mat[:-1])]
    cumsums = scipy.cumsum(diffs)

    return diffs, cumsums


def get_even_dists_euclidean(imdirectory, outdirectory, npoints, ext='.png'):
    # Get image paths for all ims -- sample from this bank:

    all_ims = sorted([f for f in os.listdir(imdirectory) if f.endswith(ext)], key=key_func)
    all_impaths = [os.path.join(imdirectory, f) for f in all_ims]

    fims, im_mat = imagemat.get_imagemat_fromdir(imdirectory)
    print "IMS: ", len(fims)
    diffs, cumsums = get_pairwise_diffs(im_mat)
    # s = scipy.cumsum(diffs)
    print len(cumsums)
    # plt.figure()
    # plt.plot(s)
    # plt.show()
    stp = list(spread.spread(0, cumsums[-1], npoints+1, mode=3))
    indices = []
    print "LEN: ", len(stp)
    for n,interval in enumerate(stp[1:len(stp)]):
        idx = [i for i,val in enumerate(cumsums) if (val>=interval)]
        indices.append(idx)
    first_match = [v[0]+1 for v in indices]
    #usethese = s[first_match]
    #morphids = [i for i,csum in enumerate(s) if csum==usethese[0]
    first_match.extend([0])
    morphids = sorted(first_match)
    for x in morphids:
        print x, all_impaths[x]
    morphseq = [all_impaths[int(x)] for x in morphids]


    if not os.path.exists(outdirectory):
        os.makedirs(outdirectory)
    
    for i in morphseq:
        copy_file(i, outdirectory)
    for idx,morphname in enumerate(sorted([f for f in os.listdir(outdirectory) if f.endswith(ext)],key=key_func)):
        old = morphname.split("morph")[1]
        old = old.split('.')[0]
        morphname = os.path.join(outdirectory,morphname)
        os.rename(morphname, morphname.replace(old, str(idx)))

    return diffs, cumsums


def plot_euclidean(imdirectory, distances, cumsumd, plot):

    plt.figure()
    plt.plot(distances)
    plt.ylabel('euclidean distance between sampled images')
    plt.xlabel('image number')
    plt.title('Euclidian Distance')

    imname = 'euclidian_distance'
    figdir = os.path.join(os.path.split(imdirectory)[0], 'figures')


    if not os.path.exists(figdir):
        os.makedirs(figdir)


    impath = os.path.join(figdir, imname+'.jpg')
    plt.savefig(impath, format='jpg')

    if plot:
        plt.show()

    print impath

    plt.figure()
    plt.plot(cumsumd)
    plt.title('Cum Sum of Distances')
    plt.show()

    imname = 'cumsum_distances'
    basedir = os.path.split(imdirectory)[0]
    impath = os.path.join(basedir, 'figures', imname+'.jpg')
    plt.savefig(impath, format='jpg')

    if plot:
        plt.show()
        
    print impath

def run():

    parser = optparse.OptionParser()
    # parser.add_option('--headless', action="store_true", dest="headless",
    #                   default=False, help="run in headless mode, no figs")

    parser.add_option('--imformat', action="store",
                      dest="im_format", default="png", help="saved image format")
    # parser.add_option('--nmorphs', action="store",
    #                   dest="nmorphs", default="20", help="n morphs to generate (not incl anchors)")
    # parser.add_option('--append', action="store",
    #                   dest="append_name", default="", help="append string to saved file name")
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

    im_format = str(options.im_format)
    if '.' not in im_format:
        im_format='.'+im_format

    plot = options.plot
    nmorphs = int(options.nmorphs)


    # tmp_ims, tmp_mat = get_imagemat_fromdir(imdir, im_format)
    # # print sys.argv[1]
    # # print sys.argv[2]
    # dists, sums = get_pairwise_diffs(tmp_mat)

    dists, sums = get_even_dists_euclidean(imdir, outdir, nmorphs, im_format)

    plot_differences(imdir, dists, sums, plot)

    print sums


if __name__ == '__main__':
    # imdir = '../../morphs/output/final'
    # fmt = '.png'

    run()