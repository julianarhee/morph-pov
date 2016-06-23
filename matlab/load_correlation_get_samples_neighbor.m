
%% LOAD correlation vector mat:
clear all
clc

[~, user_name] = system('whoami');

if strfind(user_name, 'rhee') % ON DIXIE
    source_roots = {'/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project2/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_neighbor/',...
                    '/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_fixedref/'}; %,...
    alt_base_root = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

%                 '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/morph2000_pcorr_fixedref/',...
%                 '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/morph2000_euclid_fixedref/'};
else
    source_roots = {'/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_fixedref/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_euclid_neighbor/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_project2/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_neighbor/',...
                    '/media/nas/volume1/behavior/stimuli/pnas_morphs/pixels/samples/test_pcorr_fixedref/'};
    alt_base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';
end  

source_root = source_roots{3}

out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/';
% out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/';

im_root='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000/morph2000_gray_resize/';

base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';


corrType = 'correlation';
input = 'V1features';

parts = strsplit(source_root,'/');
stimset = parts{end-1}

base_root = ['/', fullfile(parts{1:end-2}), '/'];

if strfind(stimset, 'pov20')
    nstims = 22;
else
    nstims = 2002;
end


%%

clear all;
clc;

source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1features/pov2000_final/';
% out_root='/nas/volume1/behavior/stimuli/pnas_morphs/samples/V1_euclid_neighbor/';

im_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/final/';

base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/';


%%
mfiles = dir([base_root,'*.mat']);

matnames = cell(1, length(mfiles));
for i=1:length(mfiles)
    if strfind(mfiles(i).name, 'neighbor_')
    	matnames{i} = mfiles(i).name;
    end
end
matnames = matnames(~cellfun('isempty', matnames))

%%
for f=1:length(matnames)
    f
    curr_mfile = matnames{f}
    load([base_root, curr_mfile]);
    D
    
    parts = strsplit(curr_mfile, '_');
    sample_folder = strjoin(parts(1:end-1), '_')
    out_root=[base_root, sample_folder, '/'];

    
% end
        
    % Get linearly-spaced samples

    nmorphs = 20;

    cumsum_total = cumsum(D.dist_vect);

    start_point = cumsum_total(1);
    end_point = cumsum_total(end);
    lin_samples = linspace(start_point, end_point, nmorphs+2);

    sample_idxs = [];
    for i=1:length(lin_samples)
        [c index] = min(abs(cumsum_total-lin_samples(i)));
        sample_idxs = [sample_idxs; index];
    end

    % x = cumsum_total(sample_idxs);
    % plot(x)

    im_info = dir([im_root,'*.png']);
    im_names = cell(1, length(im_info));
    for i=1:length(im_info)
        im_names{i} = im_info(i).name;
    end
    im_names = sort_nat(im_names);
    % 

    % if strfind(stimset, 'pov20')
    %     sample_idxs = linspace(1, nmorphs+2, nmorphs+2);
    % 
    % end


    % Save selected samples:
    for idx=1:length(sample_idxs)
       curr_sample_idx = sample_idxs(idx);

       if idx == 1
           curr_sample = im_names(curr_sample_idx)
       else
           curr_sample = im_names(curr_sample_idx+1)

       end
       src = strcat(im_root, curr_sample);
       src = src{1};
       dest = strcat(out_root, curr_sample)%sprintf('morph%i.png', i));
       dest = dest{1}
       copyfile(src, dest);
    end
    
    D.sample_idxs = sample_idxs;
    D.cumsum_total = cumsum_total;

    % Crap sampling due to nonlinear distances?  Generally seems okay for neighbor comparisons (both euclid and pcorr)
    % only seems to be a problem for fixed-ref...

    save([base_root,curr_mfile], 'D', '-append')

end