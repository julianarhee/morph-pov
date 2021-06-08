Pipeline for generating morph continuum from two stimuli (object A and B). Stimuli are adapted from Zoccolan et al. (1). Object stimuli are first created in [POVray](https://github.com/coxlab/povray_blobs). To repicate previous methods as closely as possible, the whole pipeline uses a combination of Matlab (original) and Python (current) code.

# Overview
The pipeline assumes object stimuli were created with POVray (see link above). It first generates a large set of stimuli that morph from object A to B, using POVray. Following previous methos (1, and see Contributors), it then converts to grayscale and rescales each image so that all stimuli are centered with roughly the same dimensions. Finally, it allows even sampling of morphs from the large set using various methods to define the sampling interval.

# Setup

1. Create environment

        $ conda create env -f environment.yml

2.  Create large set of N morphs using POVray.  This is to create discrete, linear steps along each varying dimension to get from object A to B.


        $ python make_pov_morphs.py --output-path='/path/to/save/dir' --nmorphs=N


3.  Convert to grayscale. This can be done in batch with photoshop, or just run the following MATLAB script:


		batch_rgb2gray.m (specify source and output paths)


4.  Resize images, following old stimulus generation pipeline from pnas. Use MATLAB script adapted for morphs:


		resize_morphs.m (specify source and output paths)


5.  Sample morphs from step 2 using selected constraints. For example:


	a.  Use pixel-space to approximately sample equivalent intervals between morphs. This is easily done using the python script and desired option flag:


        $ python sample_morphs.py --output-path='/path/to/samples' --input-path='/path/to/source/images' --nmorphs=N --method='euclid'


	b.  Use V1-features instead.  This should be done in MATLAB since it uses the hmaxMatlab module.

		sample_V1_features_pcorr.m, or
		sample_V1_features_euclid.m (always specify source and output paths)


## References
1. Zoccolan D, Oertelt N, DiCarlo JJ, Cox DD. A rodent model for the study of invariant visual object recognition. Proc Natl Acad Sci USA. 2009 May 26;106(21):8748-53.
