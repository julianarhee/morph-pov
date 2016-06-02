clear all
close all


source_root='/home/juliana/Documents/projects/V1_feature_morphs/';
out_root='/home/juliana/Documents/projects/morphs/V1_feature_samples/';

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

fnames = dir([source_root,'*.mat']);

x = load(fnames(1));
imshow(x.s1{1}{1}{1})

figure()
i = 1
for j=1:nbands
%         subplot(1,nbands,j)
    figure()
    imagesc(x.c1{i}(:,:,j))
    hold on;
end


% for i=1:length(x.c1)
%     nbands = size(x.c1{1});
    figure()
    i = 1
    for j=1:nbands
%         subplot(1,nbands,j)
        figure()
        imagesc(x.c1{i}(:,:,j))
        hold on;
    end
% end

j = 1

figure()
for i=1:length(x.c1)
    nbands = size(x.c1{1});
%     figure()
%     for j=1:nbands
    subplot(1,nbands,j)
    imshow(x.c1{i}(:,:,j))
    hold on;
%     end
end