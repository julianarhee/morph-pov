# Basic Setup
Instructions go here.



1.  Install morphmaker and morphdiff (correctly samples image differences using euclidean distance).

	
		python setup.py install


2.  Create large set of morphs using POVray.

	
		python make_pov_morphs.py --output-path='/path/to/save/dir' --nmorphs=N


3.  Sample morphs from step 2 using constraints specified in step 1.

		python sample_morphs.py --output-path='/path/to/save/dir' --nmorphs=M --input-path='/save/dir/from/step2'

