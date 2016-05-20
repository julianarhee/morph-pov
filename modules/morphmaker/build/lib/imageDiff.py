# Function to take all images in a specified directory, create a matrix with each row being the "unraveled" vector of an image in the dir, then calculate Euclidian distance between them, i.e., || ROW2-ROW1 || ** 2.

# __init__.py is empty except for imports. 
import sys, os, os.path
import scipy.spatial
import Image
import numpy as np
import re
import matplotlib.pyplot as plt

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

def get_pairwise_diffs(im_mat,plot=1):
	diff = [scipy.spatial.distance.euclidean(x[1],x[0]) for x in zip(im_mat[1:],im_mat[:-1])]
	if plot==1:
		plt.figure()
		plt.plot(diff)
		plt.show()
	return diff

if __name__ == '__main__':
	tmp_mat = get_image_mats(sys.argv[1], ext=sys.argv[2])
	print sys.argv[1]
	print sys.argv[2]
	get_pairwise_diffs(tmp_mat)