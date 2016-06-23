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
import numpy as np
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


# def get_pairwise_diffs(im_mat):

#     '''
    
#     Each row is an unraveled image. Take Euclid distance between each, over pairwise combinations.
#     Pairs are only consecutive images (not all combinations). 

#     i.e,. this assumes that the diff between x3 and x2 is smaller than the diff between x3 and x1.

#     '''
    
#     diffs = [scipy.spatial.distance.euclidean(x[1],x[0]) for x in zip(im_mat[1:],im_mat[:-1])]
#     cumsums = scipy.cumsum(diffs)

#     return diffs, cumsums


def get_dists_neighbor(im_mat):

    '''
    
    Each row is an unraveled image. Take Euclid distance n and n+1.

    i.e,. this computes distance between each sequential image. Uses cumsum of all distances to sample.

    '''

    dists = [[i, scipy.spatial.distance.euclidean(im_mat[i], im_mat[i+1])] for i,vect in enumerate(im_mat[0:-1])]
    cumsums = scipy.cumsum([d[1] for d in dists])

    return dists, cumsums


def get_dists_fixedref(im_mat):

    '''
    
    Each row is an unraveled image. Take Euclid distance between FIRST image and each subsequent image.

    i.e,. this holds a fixed reference point for each calculated distance.

    '''
    
    first_im = im_mat[0]

    dists = [[idx, scipy.spatial.distance.euclidean(first_im, vect)] for idx,vect in enumerate(im_mat)]
    cumsums = scipy.cumsum([d[1] for d in dists])

    return dists, cumsums


def get_even_dists_euclidean(imdirectory, outdirectory, npoints, fixedref=False, ext='.png', save_samples=True):
    # Get image paths for all ims -- sample from this bank:

    all_ims = sorted([f for f in os.listdir(imdirectory) if f.endswith(ext)], key=key_func)
    all_impaths = [os.path.join(imdirectory, f) for f in all_ims]

    fims, im_mat = imagemat.get_imagemat_fromdir(imdirectory)
    print "IMS: ", len(fims)

    # diffs, cumsums = get_pairwise_diffs(im_mat)
    if fixedref is True:
        print "fixed ref..."
        dists, cumsums = get_dists_fixedref(im_mat)
        dist_vals = np.array([d[1] for d in dists])
        stp = list(spread.spread(0, dist_vals[-1], npoints+1, mode=3))
    else:
        print "neighbors..."
        dists, cumsums = get_dists_neighbor(im_mat)
        dist_vals = cumsums #np.array([d[1] for d in dists])
        stp = list(spread.spread(0, dist_vals[-1], npoints+1, mode=3))

    idxs = []
    # stp = list(spread.spread(dist_vals[0], dist_vals[-1], npoints+1, mode=3))
    for n,curr_bin in enumerate(stp):
        print n
        sample_idx = np.where(dist_vals == min(dist_vals, key=lambda x: abs(float(x) - curr_bin)))[0][0]
        idxs.append(sample_idx)

    if fixedref is False: # fix interval-idxing
        idxs = [i+1 for i in idxs[1:]]
        idxs.append(0)
        idxs = sorted(idxs)


    # # s = scipy.cumsum(diffs)
    # print len(cumsums)
    # # plt.figure()
    # # plt.plot(s)
    # # plt.show()
    # # stp = list(spread.spread(0, cumsums[-1], npoints+1, mode=3))
    # stp = list(spread.spread(cumsums[0], cumsums[-1], npoints+1, mode=3))
    # indices = []
    # print "LEN: ", len(stp)
    # # for n,interval in enumerate(stp[1:len(stp)]):
    # for n,interval in enumerate(stp):
    #     idx = [i for i,val in enumerate(cumsums) if (val>=interval)]
    #     indices.append(idx)
    # first_match = [v[0]+1 for v in indices]
    # print "MORPHS: ", first_match
    # #usethese = s[first_match]
    # #morphids = [i for i,csum in enumerate(s) if csum==usethese[0]
    # first_match.extend([0])
    # morphids = sorted(first_match)

    morphids = idxs
    for x in morphids:
        print x, all_impaths[x]
    morphseq = [all_impaths[int(x)] for x in morphids]

    if save_samples:
        if not os.path.exists(outdirectory):
            os.makedirs(outdirectory)
        
        for i in morphseq:
            copy_file(i, outdirectory)
        for idx,morphname in enumerate(sorted([f for f in os.listdir(outdirectory) if f.endswith(ext)],key=key_func)):
            old = morphname.split("morph")[1]
            old = old.split('.')[0]
            morphname = os.path.join(outdirectory,morphname)
            os.rename(morphname, morphname.replace(old, str(idx)))

    return dists, cumsums, morphids


def plot_all_distances(outdirectory, distances, cumsumd, morphids, fixedref=False, show_plot=True):

    # plt.figure()
    # plt.plot(distances)
    # figdir = os.path.join(os.path.split(outdirectory)[0], 'figures')
    figdir = os.path.split(outdirectory)[0]

    if not os.path.exists(figdir):
        os.makedirs(figdir)

    plt.figure()
    plt.subplot(1,2,1)
    plt.plot([d[1] for d in distances])
    plt.ylabel('euclidean distance between all images')
    plt.xlabel('im #')
    plt.title('Euclidian Distance')

    plt.subplot(1,2,2)
    plt.plot(cumsumd)
    plt.title('Cum Sum of all distances')

    if fixedref is True:
        plt.suptitle('Fixed Ref')
        imname = os.path.split(outdirectory)[1]+'_euclid_all_fixedref'
    else:
        plt.suptitle('Sequential neighbor distances')
        imname = os.path.split(outdirectory)[1]+'_euclid_all_neighbor'

    basedir = os.path.split(outdirectory)[0]
    impath = os.path.join(figdir, imname+'.jpg')
    plt.savefig(impath, format='jpg')

    if show_plot is True:
        plt.show()

    print impath


def plot_sampled_distances(outdirectory, morphids, fixedref=False, ext='.png', show_plot=True):

        # plt.figure()
    figdir = os.path.split(outdirectory)[0]
    # ims = os.listdir(outdirectory)
    # ims = sorted([i for i in ims if i.endswith(ext)], key=key_func)

    fims, im_mat = imagemat.get_imagemat_fromdir(outdirectory)
    distances, cumsums = get_dists_neighbor(im_mat)

    A = [i[1] for i in distances]
    B = range(len(A))
    Z = morphids[1:]

    fig, (ax1, ax2, ax3) = plt.subplots(3, sharex=True, figsize=(20,10))
    ax1.plot(B, A, 'r*-')
    for a, b, z in zip(B, A, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax1.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')
    ax1.set_title('Sampled Euclidean distances')

    A = cumsums
    B = range(len(A))
    Z = morphids[1:]
    ax2.plot(B, A, 'r*-')
    for a, b, z in zip(B, A, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax2.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')
    ax2.set_title('Cum sum of sampled')

    distances_fixed, cumsums_fixed = get_dists_fixedref(im_mat)
    A = [i[1] for i in distances_fixed]
    B = range(len(A))
    Z = morphids

    ax3.plot(B, A, 'r*-')
    for a, b, z in zip(B, A, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax3.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')
    ax3.set_title('Relative to FIRST image')



    if fixedref is True:
        plt.suptitle('Fixed Ref')
        imname = os.path.split(outdirectory)[1]+'_euclid_sampled_fixedref'
    else:
        imname = os.path.split(outdirectory)[1]+'_euclid_sampled_neighbor'
        plt.suptitle('Sequential neighbor distances')
    
    impath = os.path.join(figdir, imname+'.jpg')
    plt.savefig(impath, format='jpg')

    if show_plot is True:
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
    parser.add_option('--fixedref', action="store_true",
                      dest="fixedref", default="False", help="sample distance measure relative to fixed reference")

    parser.add_option('--no-save', action="store_false",
                      dest="save_samples", default="True", help="create new samples and save them")

    (options, args) = parser.parse_args()

    imdir = options.imdir
    outdir = options.outdir

    im_format = str(options.im_format)
    if '.' not in im_format:
        im_format='.'+im_format

    plot = options.plot
    nmorphs = int(options.nmorphs)

    fixedref = options.fixedref
    print "FIXED? ", fixedref

    save_samples = options.save_samples
    # tmp_ims, tmp_mat = get_imagemat_fromdir(imdir, im_format)
    # # print sys.argv[1]
    # # print sys.argv[2]
    # dists, sums = get_pairwise_diffs(tmp_mat)

    dists, sums, morphids = get_even_dists_euclidean(imdir, outdir, nmorphs, fixedref, im_format, save_samples)

    plot_all_distances(outdir, dists, sums, morphids, fixedref, show_plot=plot)

    plot_sampled_distances(outdir, morphids, fixedref, im_format, show_plot=plot)

    print sums


if __name__ == '__main__':
    # imdir = '../../morphs/output/final'

    run()