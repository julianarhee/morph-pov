clear all
close all

source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_samples_euclid_fixedref/';

im_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';

base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/';

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

finfo = dir([source_root,'*.mat']);
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);

% can't load all 5k feature vectors, so get correlations in chunks:
% only need col 1 of the correlation matrix, since just want linear steps
% from "start" (image 1 in morph series, object A)) to "end" (last image, object B).

first_im = load([source_root, fnames{1}]);
first_feature_vect = first_im.featureVector;  % just need 1st column of corr mat

% chunk_size = 5;
% 
% start_idx = 1;
% last_idx = chunk_size;
% nchunks = floor(length(fnames)/chunk_size);
    
corr_vect = [];
curr_vect_idx = 1;
while 1

    if mod(curr_vect_idx, 100) == 0
        sprintf('calculating correlation between 0 and %s', fnames{curr_vect_idx})
    end
        
    
    curr_vect = load([source_root, fnames{curr_vect_idx}]);
    
    pcorr = corr(first_feature_vect', curr_vect.featureVector');
    
    corr_vect = [corr_vect; pcorr];
    
    if curr_vect_idx>length(fnames)
        break;
    end

end

% save this, bec it takes forever to make...
save([base_dir,sprintf('V1features_pcorr_fixedref_%s.mat', num2str(length(corr_vect)))], ...
    'corr_vect', 'fnames', 'first_feature_vect')
fprintf('Saved .mat to: %s', [base_dir,sprintf('V1features_pcorr_fixedref_%s.mat', num2str(length(corr_vect)))])


%%
% Test first x images to make sure corr_vect has the right stuff...
% Fs = [];
% x = 20;
% for i=1:x
%     curr_im = load([source_root, fnames{i}]);
%     Fs = [Fs curr_im.featureVector'];
% end
% pcorr_mat = corr(Fs);
% check_vect = pcorr_mat(:,1);
% 
% so_true = check_vect==corr_vect;
% 
% save([base_dir,sprintf('V1features_pcorr_fixed_ref%s.mat', num2str(length(corr_vect)))], ...
%     'check_vect', '-append')

%% Get linearly-spaced samples

nmorphs = 20;
% lin_samples = linspace(min(corr_vect), max(corr_vect), nmorphs+2); % add 2 to account for anchors
lin_samples = linspace(corr_vect(1), corr_vect(end), nmorphs+2);

% Get indices into stimulus bank (im_root):
sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(corr_vect-lin_samples(i)))
    sample_idxs = [sample_idxs; index];
end

im_info = dir([im_root,'*.png']);
im_names = cell(1, length(im_info));
for i=1:length(im_info)
    im_names{i} = im_info(i).name;
end
im_names = sort_nat(im_names);


% and save them...
for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i);
   
   curr_sample = im_names(curr_sample_idx)
   src = strcat(im_root, curr_sample);
   src = src{1};
   dest = strcat(out_root, curr_sample);
   dest = dest{1}
   copyfile(src, dest);
end