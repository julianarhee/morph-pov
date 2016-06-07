clear all
close all


source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/'; % .mat files
out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_samples_euclid_fixedref/'; % output pngs

im_root='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000/morph2000_gray_resize/'; % input pngs

base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

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

curr_vect_idx = 1;
distance_vect = [];
while 1

    if mod(curr_vect_idx, 100) == 0
        sprintf('calculating correlation between 0 and %s', fnames{curr_vect_idx})
    end
         
    curr_vect = load([source_root, fnames{curr_vect_idx}]);
    D = norm(first_feature_vect' - curr_vect.featureVector'); % Get Euclidean distance between vec1 and curr_vect
    distance_vect = [distance_vect; D];

    curr_vect_idx = curr_vect_idx + 1;

    if curr_vect_idx>length(fnames)
        break;
    end

end

% save this, bec it takes forever to make...
save([base_dir,sprintf('V1features_euclid_fixedref_%s.mat', num2str(length(fnames)))], ...
    'distance_vect', 'fnames', 'first_feature_vect', 'source_root', 'im_root')

fprintf('Saved .mat to: %s', [base_dir,sprintf('V1features_euclid_fixedref_%s.mat', num2str(length(fnames)))])

%%
% Test first x images to make sure corr_vect has the right stuff...
% Fs = [];
% x = 20;
% for i=1:x
%     curr_im = load([source_root, fnames{i}]);
%     Fs = [Fs curr_im.featureVector'];
% end
% pcorr_mat = corr(F);
% check_vect = pcorr_mat(:,1);
% 
% so_true = check_vect==corr_vect;

%% Get linearly-spaced samples

nmorphs = 20;
lin_samples = linspace(min(distance_vect), max(distance_vect), nmorphs+2); % add 2 to account for anchors

sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(distance_vect-lin_samples(i)))
    sample_idxs = [sample_idxs; index];
end

% % and save them...
% 
im_info = dir([im_root,'*.png']);
im_names = cell(1, length(im_info));
for i=1:length(im_info)
    im_names{i} = im_info(i).name;
end
im_names = sort_nat(im_names);
% 
for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i);
   
   curr_sample = im_names(curr_sample_idx)
   src = strcat(im_root, curr_sample);
   src = src{1};
   dest = strcat(out_root, curr_sample);
   dest = dest{1}
   copyfile(src, dest);
end
