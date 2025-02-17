clear all
close all

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize_samples_pcorr_neighbor/';
% % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize_samples_pcorr/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_samples_pcorr_neighbor/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_samples_euclid_neighbor/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_corr/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_euclid/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_correl_relative/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_euclid_relative/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_euclid_rel2/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/morph2000_gray_resize_samples_project/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl_fixedref/';

source_root='/nas/volume1/behavior/stimuli/pnas_morphs/samples/pov20_pov_na/';

parts = strsplit(source_root,'/');
stimset = parts{end-1}

out_root=fullfile(parts{1:end-3});
out_root = ['/', out_root,'/figures/']

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

% Get the stimuli for comp matrix:
base_root = ['/', fullfile(parts{1:end-2}), '/']

input = 'pixel';
% input = 'V1features';

iminfo = dir([source_root,'*.png']);
imnames = cell(1, length(iminfo));
for i=1:length(iminfo)
    imnames{i} = iminfo(i).name;
end
imnames = sort_nat(imnames);

% corrType='correlation';
corrType='euclidean';
%corrType='Spearman';
% load([out_rootoot,corrType,'Corr_V1features_distMatrix'])


% load .mat for V1 feature vector
if strfind(input, 'V1features')
    main_mfile = dir([base_root,'*.mat']);
    for i=1:length(main_mfile)
        main_mfile_name = main_mfile(i).name;
        if strfind(main_mfile_name, '_pcorr_neighbor')
            load([base_root, main_mfile_name])
        end
    end
    
    feat_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
    F = [];
    for idx=1:length(sample_idxs)
        curr_feat = load([feat_root, sprintf('V1_features_morph%i.mat', idx)]);
        F = [F; curr_feat.featureVector];
        % F = [F curr_feat.featureVector']; doesn't work.. too big
    end
    nsamples = length(sample_idxs);
    
else

    F = [];
    for i=1:length(imnames)
        curr_im = double(imread([source_root, imnames{i}]));

        F = [F reshape(curr_im, (1, numel(curr_im))'];
    end
    nsamples = length(imnames);
    
end

% if strfind(corrType, 'Pearson')
%     dist_mat = corr(F);
% else
sprintf('Using distance metric: %s', corrType)
dist_mat = pdist(F, corrType);
% end

dist_mat=squareform(dist_mat);

%get rid of float-point artifacts that make matrix unsymmetric
dist_mat=round(dist_mat*10000)/10000;

opts = statset('Display','iter', 'MaxIter', 20000);
% opts = statset('MaxIter', 50000);

[distMatrixMap,distMatrixStress]=mdscale(dist_mat,2, 'Options', opts);


%plot w/ color scatter plot
colorList={'r','b'};
sz=10;
hF=figure;
hold all
scatter(distMatrixMap(1:length(nsamples),1),distMatrixMap(1:length(nsamples),2),sz,colorList{1},'o')
scatter(distMatrixMap(length(nsamples)+1:end,1),distMatrixMap(length(nsamples)+1:end,2),sz,colorList{2},'o')

saveas(hF,[out_root,corrType,sprintf('Corr_%s_MDS_%s_scatter.png', input, stimset)])

%plot w/ images
% imSourceRoot='/home/cesar/Documents/Stimuli/static/trainingObjects/Blobs_HorizontalAzimuthRotation/';
% im_source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';
im_source_root = source_root;

sz=.03;
hF=figure;hold all
for i=1:length(imnames)
    imName=[im_source_root,imnames{i}];
    im0=double(imread(imName));
    centerX=distMatrixMap(i,1);
    centerY=distMatrixMap(i,2);
    X1=centerX-(sz/2)*2;
    X2=centerX+(sz/2)*2;
    Y1=centerY-(sz/2);
    Y2=centerY+(sz/2);
    image([X2, X1],[Y2, Y1],(im0/255)*64)
end
% axis([-.4 .4 -.4 .4])
% 
% for i=1:length(fnames)
%     imName=[im_source_root,fnames{i}];
%     im0=double(imread(imName));
%     centerX=distMatrixMap(length(fnames)+i,1);
%     centerY=distMatrixMap(length(fnames)+i,2);
%     X1=centerX-(sz/2)*2;
%     X2=centerX+(sz/2)*2;
%     Y1=centerY-(sz/2);
%     Y2=centerY+(sz/2);
%     image([X2, X1],[Y2, Y1],(im0/255)*64)
% end
colormap('gray')
title('MDS map')

saveas(hF,[out_root,corrType,sprintf('Corr_%s_MDS_%s.png', input, stimset)])