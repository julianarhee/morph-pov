
FlagPlotBoundaries=1;

orig_N1_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D1_Rot_y/';
orig_N2_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D2_Rot_y/';

rot_y = -90:5:90;

for curr_rot = rot_y
    %curr_rot = rot_y(r);

    % Get BB for N1:
    curr_N1_orig = sprintf('Blob_N1_CamRot_y%i.png', curr_rot);
    N1 = imread(fullfile(orig_N1_dir, curr_N1_orig));
    
    curr_morph_fn = sprintf('morph0_y%i.png', curr_rot);
    im1 = imread(fullfile(size_dir, curr_morph_fn));
    diff1 = N1 - im1;
    if ~max(max(diff1)) == 0
        fprintf('Blob1: %i', curr_rot);
    end
    

    % Get BB for N2:
    curr_N2_orig = sprintf('Blob_N2_CamRot_y%i.png', curr_rot);
    N2 = imread(fullfile(orig_N2_dir, curr_N2_orig));
    
    
    curr_morph_fn = sprintf('morph1_y%i.png', curr_rot);
    im2 = imread(fullfile(size_dir, curr_morph_fn));
    diff2 = N2 - im2;
    
    if ~max(max(diff2)) == 0
        fprintf('Blob2: %i', curr_rot);
    end
end