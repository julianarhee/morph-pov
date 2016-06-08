clear all
close all


imdir='/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray/';
outdir='/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';


if ~isdir(outdir)
    mkdir(outdir)
    sprintf('Created output dir: %s', outdir)
end

finfo = dir([imdir,'*.png']);
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);

sprintf('Resizing %s images from dir: %s', num2str(length(fnames)), imdir)
ResizeBlobRatStims_General_morphs(fnames, imdir, outdir);
sprintf('FINISHED. Output saved to dir: %s', outdir)




