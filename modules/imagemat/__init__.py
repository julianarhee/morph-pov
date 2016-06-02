# __init__.py for imagemat.py

import sys, os, os.path
import scipy.spatial
try:
    import Image
except:
    from PIL import Image
import numpy as np
import re