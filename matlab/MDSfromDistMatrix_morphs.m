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
        
        parts = strsplit(source_root,'/');
        stimset = parts{end-1};
        
        if strfind(stimset, 'pov20') % POV20 stuff is in different place, since no sampling
            feat_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/pov20/';
        else
            feat_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
        end


        base_root = ['/', fullfile(parts{1:end-2}), '/'];
        
        if strfind(stimset, 'pov20')
            nstims = 22;
        else
            nstims = 2002;
        end

        out_root=fullfile(parts{1:end-2});
        out_root = ['/', out_root,'/'];

        sprintf('SOURCE: %s\nSTIMSET: %s\nCORR: %s | INPUT: %s\n', source_root, stimset, corrType, input)

    %     if ~isdir(out_root)
    %         mkdir(out_root)
    %         sprintf('Created output dir: %s', out_root)
    %     end

        % Get the stimuli for pdist matrix:
%         if strfind(input, 'pixels')                 % Compare images pixel-wise 
%             iminfo = dir([source_root,'*.png']);
%             
%         elseif strfind(input, 'V1features')
%             iminfo = dir([base_root,'*.mat']);    % Compare V1-feature responses to image
%         end
        
        iminfo = dir([source_root,'*.png']);
        imnames = cell(1, length(iminfo));
        for i=1:length(iminfo)
            imnames{i} = iminfo(i).name;
        end
        imnames = sort_nat(imnames);

        
        % Load main .mat for V1 feature vector to get the sample_idxs (need
        % this to grab the correct V1-feature-vector from source bank.
        dist_struct = struct();
        mat_file_name = '';
        if strfind(input, 'V1features')

            % switch base_root to find main V1features .mat for POV20 stimset:
            if strfind(stimset, 'pov')
                base_root = alt_base_root; % redirect to V1_features/samples dir since POV20 doesn't resample
            end

            % NO .MAT for any _fixedref, since sampling looked terrible
            main_mfile = dir([base_root,'*.mat']);
            for i=1:length(main_mfile)
                main_mfile_name = main_mfile(i).name;
                if strfind(corrType, 'correlation')
                    if strfind(main_mfile_name, sprintf('_pcorr_neighbor_%i', nstims))
                        mat_file_name = main_mfile_name;
                        load([base_root, main_mfile_name])
                    end
                elseif strfind(corrType, 'euclidean')
                    if strfind(main_mfile_name, sprintf('_euclid_neighbor_%i', nstims))
                        mat_file_name = main_mfile_name;
                        load([base_root, main_mfile_name])
                    end
                end

            end

            F = [];
            for idx=1:length(sample_idxs)
                curr_feat = load([feat_root, sprintf('V1_features_morph%i.mat', sample_idxs(idx))]);
                F = [F; curr_feat.featureVector];  % F = [F curr_feat.featureVector']; doesn't work.. too big
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

%         sprintf('Using distance metric: %s', corrType)
        if isempty(dist_struct)
            dist_mat = pdist(F, corrType);
            dist_mat=squareform(dist_mat);
            
            %get rid of float-point artifacts that make matrix unsymmetric
            dist_mat=round(dist_mat*10000)/10000;
            
            dist_struct.(corrType) = dist_mat;
            
            if ~isempty(mat_file_name)
                save([base_root, mat_file_name], 'dist_struct', '-append')
            end
        else
            dist_mat = dist_struct.(corrType);
        end
        
        dist_mat
        
        % opts = statset('Display','iter', 'MaxIter', 1500);
        opts = statset('MaxIter', 5000);

        [distMatrixMap,distMatrixStress]=mdscale(dist_mat,2, 'Options', opts);


        %plot w/ color scatter plot
        colorList={'r','b'};
        sz=10;
        hF=figure;
        hold all

        scatter(distMatrixMap(1:nsamples,1),distMatrixMap(1:nsamples,2),sz,colorList{1},'o')

        saveas(hF,[out_root,corrType,sprintf('_%s_MDS_%s_scatter.png', input, stimset)])
        outstring = [out_root,corrType,sprintf('_%s_MDS_%s_scatter.png', input, stimset)];
        sprintf('Saved SCATTER to:\n%s', outstring)
        
        %plot w/ images
    %     im_source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';
        im_source_root = source_root;

        sz=.03;
        hF=figure;
        hold all
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

        colormap('gray')
        title('MDS map')

        saveas(hF,[out_root,corrType,sprintf('_%s_MDS_%s.png', input, stimset)])
        outstring = [out_root,corrType,sprintf('_%s_MDS_%s.png', input, stimset)];
        sprintf('Saved IMAGES to:\n%s', outstring)

    end
end
end

