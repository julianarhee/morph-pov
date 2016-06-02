# __init__.py for projection.py

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