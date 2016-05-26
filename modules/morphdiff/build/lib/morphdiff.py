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
try:
    import Image
except:
    from PIL import Image
import numpy as np
import re
import matplotlib.pyplot as plt

import optparse


def keyFunc(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))

def get_imagemat_fromdir(imdirectory,ext='.png'):
    images = [f for f in os.listdir(imdirectory) if f.endswith(ext)]
    images = sorted(images,key=keyFunc)
    impaths = [os.path.join(imdirectory, f) for f in images]
    matrix = []
    for idx, im in enumerate(impaths):
        img = Image.open(im).convert('F') # 32-bit float?
        arr = np.array(img)
        shape = arr.shape # original shape
        flat_arr = arr.ravel()
        matrix.append(flat_arr)
    return images, matrix

def get_imagemat(imdirectory,ims,ext='.png'):
    # images = [f for f in os.listdir(imdirectory) if f.endswith(ext)]
    # images = sorted(images,key=keyFunc)
    impaths = [os.path.join(imdirectory, f) for f in sorted(ims,key=keyFunc)]
    print impaths
    matrix = []
    for idx, im in enumerate(impaths):
        img = Image.open(im).convert('F') # 32-bit float?
        arr = np.array(img)
        shape = arr.shape # original shape
        flat_arr = arr.ravel()
        matrix.append(flat_arr)
    return ims, matrix

def get_pairwise_diffs(im_mat):

    '''
    
    Each row is an unraveled image. Take Euclid distance between each, over all pairwise combinations.

    '''
    diff = [scipy.spatial.distance.euclidean(x[1],x[0]) for x in zip(im_mat[1:],im_mat[:-1])]
    s = scipy.cumsum(diff)

    return diff,s


def plot_differences(imdirectory, distances, cumsumd, plot):

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



if __name__ == '__main__':
    # imdir = '../../morphs/output/final'
    # fmt = '.png'


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
    parser.add_option('--plot', action="store",
                      dest="plotit", default="0", help="plot distance and cumsum (0 to just save)")


    (options, args) = parser.parse_args()

    imdir = options.imdir
    outdir = options.outdir

    im_format = str(options.im_format)
    plotit = int(options.plotit)


    tmp_ims, tmp_mat = get_imagemat_fromdir(imdir, im_format)
    # print sys.argv[1]
    # print sys.argv[2]
    dists, sums = get_pairwise_diffs(tmp_mat)

    plot_differences(imdir, dists, sums, plotit)

    print sums
