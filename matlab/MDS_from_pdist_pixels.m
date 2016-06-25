clear all
close all
clc

addpath(genpath('./helpers'))
addpath(genpath('./hmaxMatlab'))

corrTypes= {'correlation', 'euclidean'};
input = 'pixels';

[~, user_name] = system('whoami');

if strfind(user_name, 'rhee') % ON DIXIE
    base_root = '/nas/volume1/behavior/stimuli/pnas_morphs/samples/'; %,...
else
    base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/';
end            

sample_dirs = dir(base_root);
sample_dirs = sample_dirs([sample_dirs.isdir]);
sample_dirs = sample_dirs(arrayfun(@(x) x.name(1), sample_dirs) ~= '.');

I = struct();

for CORR=1:length(corrTypes)
    corrType = corrTypes{CORR}
    
    for root=1:length(sample_dirs)
        clear dist_mat D M
        source_root = [base_root, sample_dirs(root).name, '/'];
        
        parts = strsplit(source_root,'/');
        stimset = parts{end-1};
        
        cond_info = strsplit(stimset, '_');
        I.source_root = source_root;
        I.stimset = stimset;
        I.sampled_feature = cond_info{1};
        I.sampled_distance = cond_info{2};
        I.sampled_comparison = cond_info{3};
        
%         if strfind(stimset, 'pixels') | strfind(stimset, 'pov20')
%             continue;
%         end
% 

        out_root = [strjoin(parts(1:end-3), '/'), '/figures/MDS/'];
        
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
        
        % Load images and unravel:

        % FIND .mat if exists:
        main_mfiles = dir([base_root,'*.mat']);
        mfiles = cell(1,length(main_mfiles));
        for m=1:length(main_mfiles)
            mfiles{m} = main_mfiles(m).name;
        end
        
%         curr_mfile_idx = ~cellfun('isempty', strfind(mfiles, sprintf('%s_%s_%s', I.sampled_feature, I.sampled_distance, I.sampled_comparison)))
        curr_mfile_idx = ~cellfun('isempty', strfind(mfiles, [stimset, '_pix']))
        curr_mfile = mfiles(curr_mfile_idx);

        if length(curr_mfile) > 1 % some names are made by appending name_X, so filter out correctly:
            contained_here = ~cellfun('isempty', strfind(curr_mfile, stimset)); % this will find name_X correctly, but will call anythign starting with name_
            curr_mfile = curr_mfile(contained_here);
            if length(curr_mfile) > 1
                curr_mfile = curr_mfile{1}; % just grab the first one if name is being searched
            end
        elseif length(curr_mfile) == 1
            curr_mfile = curr_mfile{1}
        else
            curr_mfile = '';
        end
        
        % LOAD struct w/ pdist and relevant info if it exists.  If not,
        % create new:
        save_new = 0;
        if isempty(curr_mfile)
            M = struct();
            M.sample_idxs = linspace(1, length(imnames), length(imnames));
            curr_mfile = sprintf('%s_pix.mat', stimset);
            save_new = 1;
        else
            
            M = load([base_root, curr_mfile]);
            if isfield(M, 'M')
                M = M.M;
            end
        end
            
        if isfield(M, 'pdist') && isfield(M.pdist, corrType)
            dist_mat = M.pdist.(corrType);
            if isfield(M, 'D') && isfield(M.D, 'sample_idxs')
                sidxs = M.D.sample_idxs;
            else
                sidxs = M.sample_idxs;
            end
        else
            if ~isfield(M, 'pdist')
                M.pdist = struct();
            end
        %M.pdist = struct();
        
            F = [];
            for i=1:length(imnames)
                curr_im = double(imread([source_root, imnames{i}]));
                F = [F; reshape(curr_im, 1, numel(curr_im))];
            end

            dist_mat = pdist(F, corrType);
            dist_mat=squareform(dist_mat);

            %get rid of float-point artifacts that make matrix unsymmetric
            dist_mat=round(dist_mat*10000)/10000;
            M.pdist.(corrType) = dist_mat;
            M.I = I;
            
            if save_new==1
                save([base_root, curr_mfile], 'M')
            else
                save([base_root, curr_mfile], 'M', '-append')
            end
        end
        nsamples = length(imnames);

        % opts = statset('Display','iter', 'MaxIter', 1500);
        opts = statset('MaxIter', 5000);

        [distMatrixMap,distMatrixStress]=mdscale(dist_mat, 2, 'Options', opts);

        %plot w/ color scatter plot
        parts_fig =  strsplit(out_root,'/');
        scatter_root = [strjoin(parts_fig(1:end-2), '/'), '/scatter/'];
        colorList={'r','b'};
        c = linspace(1,5,nsamples);
        sz=10;
        hF=figure;
        hold all
        
        scatter(distMatrixMap(1:nsamples,1),distMatrixMap(1:nsamples,2),sz,c,'o')
        scatter(distMatrixMap(1,1),distMatrixMap(1,2),sz,'k','*')
        title(sprintf('_%s_MDS_%s_scatter.png', input, stimset))
        
        imname = sprintf('MDS_%s_%s_%s_scatter.png', stimset, corrType, input);
        saveas(hF,[scatter_root,imname])
        outstring = [scatter_root, imname];
        sprintf('Saved SCATTER to:\n%s', outstring)
        
        %plot w/ images
    %     im_source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20_gray_resize/';
%         im_source_root = source_root;
        if strfind(corrType, 'euclidean')
            sz = 5000;
        else
            sz = .005;
        end
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
        %title('MDS map')
        title(sprintf('_%s_MDS_%s_scatter.png', input, stimset))

        imname = sprintf('MDS_%s_%s_%s_images.png', stimset, corrType, input);
        saveas(hF,[out_root,imname])
        outstring = [out_root, imname];
        sprintf('Saved IMAGES to:\n%s', outstring)

    end

end