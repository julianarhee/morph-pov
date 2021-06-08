clear all
close all


imdir='/tmp/morphs/gray/';
outdir='/tmp/morphs/crop/';
%imdir='/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/scaletrans_pl/gray/';
%outdir='/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/scaletrans_pl/size/';


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





finfo = dir([gray_root,'*.png']); % run resize on newly create grayscale ims
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);

sprintf('Resizing %s images from dir: %s', num2str(length(fnames)), gray_root)
ResizeBlobRatStims_General_morphs(fnames, gray_root, size_root);
sprintf('FINISHED. Output saved to dir: %s', size_root)
