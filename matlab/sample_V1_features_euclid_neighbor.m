clear all
close all


% source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
% out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_euclid_neighbor/';
% 
% im_root='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000/morph2000_gray_resize/';
% 
% base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/pov20/'; % .mat files
out_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/pov20_euclid_neighbor/'; % output pngs

im_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/pov20/pov20_gray_resize/';

base_dir = '/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

parts = strsplit(source_root,'/');
stimset = parts{end-1};

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


curr_vect_idx = 1;
next_vect_idx = curr_vect_idx + 1;

distance_vect = [];
while 1

    if mod(curr_vect_idx, 100) == 0
        sprintf('calculating correlation between %s and %s', fnames{curr_vect_idx}, fnames{next_vect_idx})
    end
         
    
    curr_vect = load([source_root, fnames{curr_vect_idx}]);
    next_vect = load([source_root, fnames{next_vect_idx}]);

    D = norm(curr_vect.featureVector'-next_vect.featureVector'); % Get Euclidean distance between vec1 and curr_vect
    distance_vect = [distance_vect; D];

    curr_vect_idx = curr_vect_idx + 1;
    next_vect_idx = curr_vect_idx + 1;

    if curr_vect_idx==length(fnames)
        break;
    end

end

% save this, bec it takes forever to make...
save([base_dir,sprintf('V1features_euclid_neighbor_%s.mat', num2str(length(fnames)))], ...
    'distance_vect', 'fnames', 'source_root', 'im_root')

fprintf('Saved .mat to: %s', [base_dir,sprintf('V1features_euclid_neighbor_%s.mat', num2str(length(fnames)))])

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
cumsum_total = cumsum(distance_vect);
start_point = cumsum_total(1);
end_point = cumsum_total(end);
lin_samples = linspace(start_point, end_point, nmorphs+2);

sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(cumsum_total-lin_samples(i)))
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

if strfind(stimset, 'pov20')
    sample_idxs = linspace(1, nmorphs+2, nmorphs+2);
end


for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i);
   
   curr_sample = im_names(curr_sample_idx)
   src = strcat(im_root, curr_sample);
   src = src{1};
   dest = strcat(out_root, sprintf('morph%i.png', i-1));
%    dest = dest{1}
   copyfile(src, dest);
end

%%
% CRAP SAMPLING due to non-linear changes:
% sample_idxs = linspace(1, nmorphs+2, nmorphs+2);

save([base_dir,sprintf('V1features_euclid_neighbor_%s.mat', num2str(length(fnames)))], ...
    'cumsum_total', 'sample_idxs', '-append')
