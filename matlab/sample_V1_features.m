clear all
close all


source_root='/home/juliana/Documents/projects/morphs/V1_feature_morphs/';
out_root='/home/juliana/Documents/projects/morphs/V1_feature_samples_pcorr/';

im_root='/home/juliana/Documents/projects/morphs/morph5000_gray/';


base_dir = '/home/juliana/Documents/projects/morphs/';

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
first_feature_vect = first_im.featureVector';  % just need 1st column of corr mat

chunk_size = 5;

start_idx = 1;
last_idx = chunk_size;
nchunks = floor(length(fnames)/chunk_size);
    
corr_vect = [];

while 1
% for c=1:nchunks+1 %-1
% for c=251:nchunks+100 %-1   
%     sprintf('current chunk: %i', c)
    
    %start IDX: 4732, end IDX: 4751
    F = [];
    if (length(fnames) - last_idx) < chunk_size
        fprintf('including the last images in this chunk!')
        last_idx = length(fnames);
    end
    
    
    sprintf('start IDX: %i, end IDX: %i', start_idx, last_idx)
    for i=start_idx:last_idx
        curr_im = load([source_root, fnames{i}]);
        F = [F curr_im.featureVector'];
    end
    
    F(:,1) = first_feature_vect;
    
    pcorr_mat = corr(F);
    all_corrs = pcorr_mat(:,1);
    
    corr_vect = [corr_vect; all_corrs];
    
    start_idx = last_idx;
    last_idx = last_idx + chunk_size - 1;
    
%     current chunk: 263
% 
%     including the last images in this chunk!
%     ans =
% 
%     start IDX: 4979, end IDX: 5002


    if last_idx==length(fnames)
        break;
    end

end

% with extra1's, lengh(corr_vect)=5264

remove_idxs = corr_vect == 1;     % find all repeated corrs of first vector
remove_idxs(1) = 0;               % obviously keep first vector
corr_vect(remove_idxs) = [];      % get rid of the rest

% save this, bec it takes forever to make...
save([base_dir,sprintf('V1_features_pcorr_%s.mat', num2str(length(corr_vect)))], ...
    'corr_vect', 'fnames', 'first_feature_vect')

%%
% Test first x images to make sure corr_vect has the right stuff...
Fs = [];
x = 20;
for i=1:x
    curr_im = load([source_root, fnames{i}]);
    Fs = [Fs curr_im.featureVector'];
end
pcorr_mat = corr(F);
check_vect = pcorr_mat(:,1);

so_true = check_vect==corr_vect;

%% Get linearly-spaced samples

nmorphs = 20;
lin_samples = linspace(min(corr_vect), max(corr_vect), nmorphs+2); % add 2 to account for anchors

sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(corr_vect-lin_samples(i)))
    sample_idxs = [sample_idxs; index];
end

% and save them...

im_info = dir([im_root,'*.png']);
im_names = cell(1, length(im_info));
for i=1:length(im_info)
    im_names{i} = im_nifo(i).name;
end
im_names = sort_nat(im_names);

for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i)(2);
   
   curr_sample = im_names(curr_sample_idx);
   copyfile(['im_root', curr_sample], ['out_root', curr_sample]);
end