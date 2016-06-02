clear all
close all


source_root='/home/juliana/Documents/projects/morphs/morph5000/im/';
out_root='/home/juliana/Documents/projects/morphs/morph5000_gray/';

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

imnames = dir([source_root,'*.png']);

for i=1:length(imnames)
    
    % load image
    morph_idx = i-1;
    
    if mod(i, 100) == 0
        sprintf('converting to grayscale: morph %s', num2str(morph_idx))
    end
         
    curr_im = [source_root,'morph', num2str(morph_idx),'.png'];
    im = double(imread(curr_im));
    im = rgb2gray(im);
    imwrite(im, [out_root, sprintf('morph%i.png', morph_idx)]);
  
%     save([out_root,sprintf('V1_features_%s.mat', num2str(morph_idx))])
    
end