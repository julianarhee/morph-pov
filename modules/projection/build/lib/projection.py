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

def key_func(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))


def unit_vector(vector):
    """ Returns the unit vector of the vector.  """
    return vector / np.linalg.norm(vector)


def angle_between(v1, v2):
    """ Returns the angle in radians between vectors 'v1' and 'v2'::

            >>> angle_between((1, 0, 0), (0, 1, 0))
            1.5707963267948966
            >>> angle_between((1, 0, 0), (1, 0, 0))
            0.0
            >>> angle_between((1, 0, 0), (-1, 0, 0))
            3.141592653589793
    """
    v1_u = unit_vector(v1)
    v2_u = unit_vector(v2)
    return np.arccos(np.clip(np.dot(v1_u, v2_u), -1.0, 1.0))


def dotproduct(v1, v2):
  return sum((a*b) for a, b in zip(v1, v2))


def length(v):
  return math.sqrt(dotproduct(v, v))


# def angle(v1, v2):
#   return math.acos(dotproduct(v1, v2) / (length(v1) * length(v2)))


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

def get_projection_vectors(imdirectory, ext):

    '''
    Return difference vetor, list of all vector differences from one of the end points. 
    '''

    fmorphs = [f for f in os.listdir(imdirectory) if f.endswith(ext)]
    fmorphs = sorted(fmorphs,key=key_func)

    start_morph = fmorphs[0]
    img = Image.open(os.path.join(imdirectory, start_morph)).convert('F')
    start_image = np.array(img).ravel()

    end_morph = fmorphs[-1]
    img = Image.open(os.path.join(imdirectory, end_morph)).convert('F')
    end_image = np.array(img).ravel()

    im_shape = img.size

    difference_vect = end_image - start_image
    difference_vect_unit = unit_vector(difference_vect)

    # see_diff = difference_vect.reshape((im_shape[1], im_shape[0]))
    # plt.imshow(see_diff)

    diff_vects = []
    for idx,im in enumerate(fmorphs[1:-1]): # only grab morphs (not anchors)
        curr_morph = Image.open(os.path.join(imdirectory, im)).convert('F')
        curr_image = np.array(curr_morph).ravel()
        curr_diff_vect = curr_image - start_image

        diff_vects.append([idx, curr_diff_vect])

    return fmorphs, difference_vect, diff_vects


def project_vectors(difference_vect, diff_vects):

    '''
    Scalar projections of morph-vectors onto difference vector:

    a1 = a . b-hat, where b-hat is the unit vector in the direction of b

    '''
    difference_vect_unit = unit_vector(difference_vect)

    projections = [[i[0], np.dot(i[1], difference_vect_unit)] for i in diff_vects]

    return projections

# # PLOT PRE sampling:
# A = [i[1] for i in projections]
# B = np.ones((len(projections),1))
# Z = [i[0] for i in projections]

# fig, ax = plt.subplots()

# ax.plot(A, B, 'r*')
# for a, b, z in zip(A, B, Z):
#     # Annotate the points 5 _points_ above and to the left of the vertex
#     ax.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
#                 textcoords='offset points')

# plt.title('Scalar projection of morph differences in direction of difference between anchors')
# plt.show()

def find_projections(difference_vect, projections, nmorphs):
    # Sample evenly:
    full_length = length(difference_vect)
    sample_space = list(spread.spread(0, full_length, nmorphs+1, mode=3))

    idxs = []
    print "LEN: ", len(sample_space)
    morph_projections = [i[1] for i in projections]
    for n,curr_bin in enumerate(sample_space[1:len(sample_space)-1]):
        print n
        sample_idx = np.where(morph_projections == min(morph_projections, key=lambda x: abs(float(x) - curr_bin)))[0][0]
        idxs.append(sample_idx)

    return idxs


def plot_all_projections(outdirectory, projections, idxs, ext='.png', show_plot=True):

    # fmorphs, difference_vect, diff_vects = get_projection_vectors(outdirectory, ext)

    # projections = project_vectors(difference_vect, diff_vects)

    A = [p[1] for p in projections]
    B = np.ones((len(A),1))
    Z = idxs #[projections[idx][0] for idx in idxs]

    fig, ax = plt.subplots(figsize=(20,10))

    ax.plot(A, B, 'r*')
    for a, b, z in zip(A, B, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')

    plt.title('Scalar projection of morph differences in direction of difference between anchors')

    imname = os.path.split(outdirectory)[1]+'_all_projection'
    # figdir = os.path.join(os.path.split(imdirectory)[0], 'figures')
    figdir = os.path.split(outdirectory)[0]

    if not os.path.exists(figdir):
        os.makedirs(figdir)

    impath = os.path.join(figdir, imname+'.jpg')
    print impath
    plt.savefig(impath, format='jpg')
    print "Saved interval graph: %s" % impath

    if show_plot:
        plt.show()



def plot_sampled_projections(outdirectory, idxs, ext='.png', show_plot=True):

    fmorphs, difference_vect, diff_vects = get_projection_vectors(outdirectory, ext)

    projections = project_vectors(difference_vect, diff_vects)

    A = [p[1] for p in projections]
    B = np.ones((len(A),1))
    Z = np.array(idxs)+1 # add 1 to make labeled # correspond to morph #

    fig, ax = plt.subplots(figsize=(20,10))

    ax.plot(A, B, 'r*')
    for a, b, z in zip(A, B, Z):
        # Annotate the points 5 _points_ above and to the left of the vertex
        ax.annotate('{}'.format(z), xy=(a,b), xytext=(-5, 5), ha='right',
                    textcoords='offset points')

    plt.title('Scalar projection of morph differences in direction of difference between anchors')

    imname = os.path.split(outdirectory)[1]+'_sampled_projection'
    # figdir = os.path.join(os.path.split(imdirectory)[0], 'figures')
    figdir = os.path.split(outdirectory)[0]

    if not os.path.exists(figdir):
        os.makedirs(figdir)

    impath = os.path.join(figdir, imname+'.jpg')
    print impath
    plt.savefig(impath, format='jpg')
    print "Saved interval graph: %s" % impath

    if show_plot:
        plt.show()


def get_projected_morphs(nmorphs, imdirectory, outdirectory, ext='.png', save_samples=True):

    fmorphs, difference_vect, diff_vects = get_projection_vectors(imdirectory, ext)
    projections = project_vectors(difference_vect, diff_vects)

    idxs = find_projections(difference_vect, projections, nmorphs)

    # if show_plot:
    #     plot_sample_projections(projections, idxs, imdirectory)

    morph_sample_idx = [projections[idx+1][0] for idx in idxs]
    morph_sample_idx.append(0) # add anchor 1
    morph_sample_idx.append(len(fmorphs)-1) # add anchor 2
    morph_sample_idx = sorted(morph_sample_idx)

    morph_sample_paths = [os.path.join(imdirectory, fmorphs[midx]) for midx in morph_sample_idx]

    print "SAVE?? ", save_samples
    if save_samples:
        print 'TRUE'
        if not os.path.exists(outdirectory):
            os.makedirs(outdirectory)

        for m in morph_sample_paths:
            print m
            copy_file(m, outdirectory)

        morph_list = sorted([f for f in os.listdir(outdirectory) if f.endswith(ext)],key=key_func)
        for midx,morphname in enumerate(morph_list):
            old = morphname.split("morph")[1]
            old = old.split('.')[0]
            morphname = os.path.join(outdirectory,morphname)
            os.rename(morphname, morphname.replace(old, str(midx)))

        print "New sampled morphs saved to: ", outdirectory

    return projections, idxs

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

    parser.add_option('--no-save', action="store_false",
                      dest="save_samples", default="True", help="create new samples and save them")

    (options, args) = parser.parse_args()

    imdir = options.imdir
    outdir = options.outdir
    ext = str(options.ext)
    if '.' not in ext:
        ext='.'+ext
    plot = options.plot
    nmorphs = int(options.nmorphs)

    save_samples = options.save_samples

    projs, idxs = get_projected_morphs(nmorphs, imdir, outdir, ext, save_samples)


    plot_all_projections(outdir, projs, idxs, ext, show_plot=plot)

    plot_sampled_projections(outdir, idxs, ext, show_plot=plot)

if __name__ == '__main__':
    run()