
# __init__.py is empty except for imports.
import sys, os, os.path
# import scipy.spatial
try:
    import Image
except:
    from PIL import Image
import numpy as np
import re


def key_func(afilename):
    nondigits = re.compile("\D")
    return int(nondigits.sub("", afilename))


def get_imagemat_fromdir(imdirectory,ext='.png'):
    images = [f for f in os.listdir(imdirectory) if f.endswith(ext)]
    images = sorted(images,key=key_func)
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
    impaths = [os.path.join(imdirectory, f) for f in sorted(ims,key=key_func)]
    print impaths
    matrix = []
    for idx, im in enumerate(impaths):
        img = Image.open(im).convert('F') # 32-bit float?
        arr = np.array(img)
        shape = arr.shape # original shape
        flat_arr = arr.ravel()
        matrix.append(flat_arr)
    return ims, matrix
