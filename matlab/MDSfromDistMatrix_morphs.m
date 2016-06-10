clear all
close all

addpath(genpath('./helpers'))
addpath(genpath('./hmaxMatlab'))

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/';

% input = 'pixel';
% input = 'V1features';

% corrType='correlation';
corrTypes={'correlation', 'euclidean'};
inputs = {'pixels', 'V1features'};

        
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/';

% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project2/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl_neighbor/';
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl_fixedref/';

source_roots = {'/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project2/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_neighbor/',...
                '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_fixedref/'}; %,...
%                 '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/morph2000_pcorr_fixedref/',...
%                 '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/morph2000_euclid_fixedref/'};

alt_base_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

for CORR=1:length(corrTypes)
    corrType = corrTypes{CORR};
    
for input_idx=1:length(inputs)
    input = inputs{input_idx};
    
    for root=1:length(source_roots)
        source_root = source_roots{root};
        
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/';
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/';

    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/';
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/';
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project2/';
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl_neighbor/';
    % source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_correl_fixedref/';

    parts = strsplit(source_root,'/');
    stimset = parts{end-1};
    if strfind(stimset, 'pov20')
        nstims = 22;
    else
        nstims = 2002;
    end

    out_root=fullfile(parts{1:end-2});
    out_root = ['/', out_root,'/'];
    
    sprintf('SOURCE: %s\nSTIMSET: %s\nCORR: %s | INPUT: %s\n', source_root, stimset, corrType, input)
    sprintf('Saving to:\n%s', out_root)

%     if ~isdir(out_root)
%         mkdir(out_root)
%         sprintf('Created output dir: %s', out_root)
%     end

    % Get the stimuli for comp matrix:
    base_root = ['/', fullfile(parts{1:end-2}), '/'];

    % % input = 'pixel';
    % input = 'V1features';
    
    if strfind(input, 'pixels')
        iminfo = dir([source_root,'*.png']);
    elseif strfind(input, 'V1features')
        iminfo = dir([source_root,'*.mat']);
    end

    imnames = cell(1, length(iminfo));
    for i=1:length(iminfo)
        imnames{i} = iminfo(i).name;
    end
    imnames = sort_nat(imnames);

%     corrType='correlation';
    % corrType='euclidean';
    %corrType='Spearman';
    % load([out_rootoot,corrType,'Corr_V1features_distMatrix'])


    % load .mat for V1 feature vector
    if strfind(input, 'V1features')
        % switch base_root to find main V1features .mat for POV20 stimset:
        if strfind(stimset, 'pov')
            base_root = alt_base_root;
        end
        main_mfile = dir([base_root,'*.mat']);
        for i=1:length(main_mfile)
            main_mfile_name = main_mfile(i).name;
            if strfind(corrType, 'correlation')
                if strfind(main_mfile_name, sprintf('_pcorr_neighbor_%i', nstims))
                    load([base_root, main_mfile_name])
                end
            elseif strfind(corrType, 'euclidean')
                if strfind(main_mfile_name, sprintf('_pcorr_neighbor_%i', nstims))
                    load([base_root, main_mfile_name])
                end
            end
               
        end
        
        if strfind(stimset, 'pov20')
            feat_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/pov20/';
        else
            feat_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
        end
        F = [];
        for idx=1:length(sample_idxs)
            curr_feat = load([feat_root, sprintf('V1_features_morph%i.mat', sample_idxs(idx))]);
            F = [F; curr_feat.featureVector];
            % F = [F curr_feat.featureVector']; doesn't work.. too big
        end
        nsamples = length(sample_idxs);

    elseif strfind(input, 'pixels')

        F = [];
        for i=1:length(imnames)
            curr_im = double(imread([source_root, imnames{i}]));
            F = [F; reshape(curr_im, 1, numel(curr_im))];
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

    % opts = statset('Display','iter', 'MaxIter', 1500);
    opts = statset('MaxIter', 10000);

    [distMatrixMap,distMatrixStress]=mdscale(dist_mat,2, 'Options', opts);


    %plot w/ color scatter plot
    colorList={'r','b'};
    sz=10;
    hF=figure;
    hold all

%     subplot(1,2,1)
    scatter(distMatrixMap(1:nsamples,1),distMatrixMap(1:nsamples,2),sz,colorList{1},'o')

    % scatter(distMatrixMap(nsamples+1:end,1),distMatrixMap(nsamples+1:end,2),sz,colorList{2},'o')

    saveas(hF,[out_root,corrType,sprintf('_%s_MDS_%s_scatter.png', input, stimset)])

    %plot w/ images
    % imSourceRoot='/home/cesar/Documents/Stimuli/static/trainingObjects/Blobs_HorizontalAzimuthRotation/';
%     im_source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';
    im_source_root = source_root;

    sz=.015;
    hF=figure;
    hold all
%     subplot(1,2,2)
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

    saveas(hF,[out_root,corrType,sprintf('_%s_MDS_%s.png', input, stimset)])

    end
end
end

