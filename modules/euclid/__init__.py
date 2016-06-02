# __init__.py for euclid.py

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
from fractions import Fraction

import spread
from imagemat import *
