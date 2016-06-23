clear all
close all
clc

addpath(genpath('./helpers'))
addpath(genpath('./hmaxMatlab'))

corrTypes= {'correlation', 'euclidean'}; %{'correlation', 'euclidean'};
input = 'V1features';

[~, user_name] = system('whoami');

if strfind(user_name, 'rhee') % ON DIXIE
    base_root = '/nas/volume1/behavior/stimuli/pnas_morphs/samples/'; %,...
    feature_base_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1features/';
else
    base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/';
    feature_base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1features/';
end            

sample_dirs = dir(base_root);
sample_dirs = sample_dirs([sample_dirs.isdir]);
sample_dirs = sample_dirs(arrayfun(@(x) x.name(1), sample_dirs) ~= '.');

D = struct();

for CORR=1:length(corrTypes)
    corrType = corrTypes{CORR}
    
    for root=1:length(sample_dirs)
        clear dist_mat D M
        source_root = [base_root, sample_dirs(root).name, '/'];
        
        parts = strsplit(source_root,'/');
        stimset = parts{end-1};
        
        cond_info = strsplit(stimset, '_');
        D.source_root = source_root;
        D.stimset = stimset;
        D.sampled_feature = cond_info{1};
        D.sampled_distance = cond_info{2};
        D.sampled_comparison = cond_info{3};
  
        % FIX THIS FOR V1 referencing:
%         if strfind(stimset, 'pov20')
%             nstims = 22;
%             feature_root = [feature_base_root, 'pov20/'];
%         else
%             nstims = 2002;
%             if strfind(stimset, 'pixels_')
%                 % Samples generated with python (i.e,. not using
%                 % V1-features) do not have associated sample_idxs...
%                 % Instead, use V1 features created for specific stimsets: 
%                 feature_root = [feature_base_root, sprintf('%s_%s20', D.sampled_distance, D.sampled_comparison)]
%             else
%                 feature_root = [feature_base_root, 'morph2000_gray_resize/'];
%             end
%         end
        if strfind(stimset, 'v1_')
            nstims = 2002;
            feature_root = [feature_base_root, 'morph2000_gray_resize/'];
        else
            nstims = 22;
            % Samples generated with python (i.e,. not using
            % V1-features) do not have associated sample_idxs...
            % Instead, use V1 features created for specific stimsets: 
            feature_root = [feature_base_root, sprintf('%s/', stimset)]
        end

        D.nstims = nstims
        
%         out_root=fullfile(parts{1:end-2});
        out_root = [strjoin(parts(1:end-3), '/'), '/figures/'];
        
        if ~isdir(out_root)
            mkdir(out_root)
            sprintf('Created output dir: %s', out_root)
        end

        sprintf('SOURCE: %s\nSTIMSET: %s\nCORR: %s | INPUT: %s\n', source_root, stimset, corrType, input)

        % Get the stimuli for pdist matrix:
%         if strfind(input, 'pixels')                 % Compare images pixel-wise 
%             iminfo = dir([source_root,'*.png']);
%             
%         elseif strfind(input, 'V1features')
%             iminfo = dir([base_root,'*.mat']);    % Compare V1-feature responses to image
%         end
        
        iminfo = dir([source_root,'/*.png']);
        imnames = cell(1, length(iminfo));
        for i=1:length(iminfo)
            imnames{i} = iminfo(i).name;
        end
        imnames = sort_nat(imnames);
        sprintf('N sampled image: %i', length(imnames))
        
        % Load main .mat for V1 feature vector to get the sample_idxs (need
        % this to grab the correct V1-feature-vector from source bank.

        % NO .MAT for any _fixedref, since sampling looked terrible
        main_mfiles = dir([base_root,'*.mat']);
        mfiles = cell(1,length(main_mfiles));
        for m=1:length(main_mfiles)
            %curr_mfile = main_mfiles(m).name;
            mfiles{m} = main_mfiles(m).name;
        end
        
        curr_mfile_idx = ~cellfun('isempty', strfind(mfiles, sprintf('_%s_%s_%i', D.sampled_distance, D.sampled_comparison, D.nstims)))
        curr_mfile = mfiles(curr_mfile_idx);
        
        if isempty(curr_mfile)
            fprintf('No m-file found, creating new...');
        else
            curr_mfile = curr_mfile{1};
        end

        if ~isempty(curr_mfile)
            if strfind(curr_mfile, '_fixedref')
                sprintf('Skipping MDS for bad-sampling of %s stimset...', curr_mfile)
            continue;
            end
        end
        
        save_new = 0;
        if isempty(curr_mfile)
            M = struct();
            M.sample_idxs = linspace(1, length(imnames), length(imnames));
            curr_mfile = sprintf('pdistmat_%s_%s_%i.mat', D.sampled_distance, D.sampled_comparison, D.nstims);
            save_new = 1;
        else
            
            M = load([base_root, curr_mfile]);
            if isfield(M, 'M')
                M = M.M;
            end
        end
            
        if isfield(M, 'pdist') && isfield(M.pdist, corrType)
            dist_mat = M.pdist.(corrType);
            nsamples = length(M.sample_idxs);
        else
            if ~isfield(M, 'pdist')
                M.pdist = struct();
            end
            sampled_feature_vects = [];
            for idx=1:length(M.sample_idxs)
                curr_feat = load([feature_root, sprintf('V1_features_morph%i.mat', (M.sample_idxs(idx)-1))]);
                sampled_feature_vects = [sampled_feature_vects; curr_feat.featureVector];  % F = [F curr_feat.featureVector']; doesn't work.. too big
            end
            nsamples = length(M.sample_idxs);

            dist_mat = pdist(sampled_feature_vects, corrType);
            dist_mat=squareform(dist_mat);

            %get rid of float-point artifacts that make matrix unsymmetric
            dist_mat=round(dist_mat*10000)/10000;
            M.pdist.(corrType) = dist_mat;
            if save_new==1
                save([base_root, curr_mfile], 'M')
            else
                save([base_root, curr_mfile], 'M', '-append')
            end
        end
        

        % opts = statset('Display','iter', 'MaxIter', 1500);
        opts = statset('MaxIter', 5000);

        [distMatrixMap,distMatrixStress]=mdscale(dist_mat, 2, 'Options', opts);

        %plot w/ color scatter plot
        colorList={'r','b'};
        sz=10;
        hF=figure;
        hold all

        scatter(distMatrixMap(1:nsamples,1),distMatrixMap(1:nsamples,2),sz,colorList{1},'o')
        scatter(distMatrixMap(1,1),distMatrixMap(1,2),sz,'b','o')
        title(sprintf('_%s_MDS_%s_scatter.png', input, stimset))
        saveas(hF,[out_root,corrType,sprintf('_%s_MDS_%s_scatter.png', input, stimset)])
        outstring = [out_root,corrType,sprintf('_%s_MDS_%s_scatter.png', input, stimset)];
        sprintf('Saved SCATTER to:\n%s', outstring)
        
        %plot w/ images
    %     im_source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';
%         im_source_root = source_root;

        sz=.03;
        hF=figure;
        hold all
        for i=1:length(imnames)
            imName=[source_root,imnames{i}];
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