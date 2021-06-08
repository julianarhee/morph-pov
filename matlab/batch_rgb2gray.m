clear all
close all

source_root='/tmp/morphs/im/';
out_root='/tmp/morphs/gray/';
%source_root='/nas/volume1/behavior/stimuli/pnas_morphs/pov20/im/';
%out_root='/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray/';

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

%imnames = dir([source_root,'*.png']);
nmorph_imgs = 22;
rot_y = [-90, -60, -30, 0, 30, 60, 90];

for i=1:nmorph_imgs %length(imnames)
    % load image
    morph_idx = i-1;
    if mod(i, 100) == 0
        sprintf('converting to grayscale: morph %s', num2str(morph_idx))
    end
    for r=1:length(rot_y)
        curr_rot = rot_y(r);
        curr_fn = sprintf('morph%i_y%i.png', morph_idx, curr_rot);
        curr_im = fullfile(source_root, curr_fn);
        im = imread(curr_im);
        im = rgb2gray(im);
        imwrite(im, fullfile(out_root, curr_fn));
    end    
end
