clear all
close all


imdir='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray/';
outdir='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize/';


if ~isdir(outdir)
    mkdir(outdir)
    sprintf('Created output dir: %s', outdir)
end

finfo = dir([imdir,'*.mat']);
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);

fprintf('Resizing %s images from dir: %s', str(length(fnames), imdir))
ResizeBlobRatStims_General(fnames, imdir, outdir);
fprintf('FINISHED. Output saved to dir: %s', outdir)




