# Basic Setup
Instructions go here.



1.  Install modules.  For each:

	
		python setup.py install


2.  Create large set of morphs using POVray.  This is to create discrete, linear steps along each varying dimension to get from object A to B.
	

		python make_pov_morphs.py --output-path='/path/to/save/dir' --nmorphs=N


3.  Convert to grayscale. This can be done in batch with photoshop, or just run the following MATLAB script:
	

		batch_rgb2gray.m (specify source and output paths)


4.  Resize images, following old stimulus generation pipeline from pnas. Use MATLAB script adapted for morphs:
	

		resize_morphs.m (specify source and output paths)


5.  Sample morphs from step 2 using constraints specified in step 1.


		a.  Use pixel-space to approximately sample equivalent intervals between morphs. This is easily done using the python script and desired option flag:


		python sample_morphs.py --output-path='/path/to/samples' --input-path='/path/to/source/images' --nmorphs=N --method='euclid'


		b.  Use V1-features instead.  This should be done in MATLAB since it uses the hmaxMatlab module.


		sample_V1_features_pcorr.m, or
		samlpe_V1_features_euclid.m (always specify source and output paths)
