clear all
close all


% source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/';
% out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_neighbor/';
% 
% im_root='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000/morph2000_gray_resize/';
% 
% base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';


source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/pov20/'; % .mat files
out_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/pov20_pcorr_neighbor/'; % output pngs

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
    
corr_vect = [];
curr_vect_idx = 1;
next_vect_idx = curr_vect_idx + 1;
while 1

    if mod(curr_vect_idx, 100) == 0
        sprintf('calculating correlation between %s and %s', fnames{curr_vect_idx}, fnames{next_vect_idx})
    end
        
    curr_vect = load([source_root, fnames{curr_vect_idx}]);
    next_vect = load([source_root, fnames{next_vect_idx}]);
    
    pcorr = corr(curr_vect.featureVector', next_vect.featureVector');

    corr_vect = [corr_vect; pcorr];
    

    curr_vect_idx = curr_vect_idx + 1;
    next_vect_idx = curr_vect_idx + 1;

    if curr_vect_idx==length(fnames)
        break;
    end

end


% save this, bec it takes forever to make...
save([base_dir,sprintf('V1features_pcorr_neighbor_%s.mat', num2str(length(corr_vect)))], ...
    'corr_vect', 'fnames')
fprintf('Saved .mat to: %s', [base_dir,sprintf('V1features_pcorr_neighbor_%s.mat', num2str(length(corr_vect)))])


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
% save([base_dir,sprintf('V1_features_pcorr_%s.mat', num2str(length(corr_vect)))], ...
%     'check_vect', '-append')

%% Get linearly-spaced samples
% 
% nmorphs = 20;
% % lin_samples = linspace(min(corr_vect), max(corr_vect), nmorphs+2); % add 2 to account for anchors
% lin_samples = linspace(corr_vect(1), corr_vect(end), nmorphs+2);
% 
% sample_idxs = [];
% for i=1:length(lin_samples)
%     [c index] = min(abs(corr_vect-lin_samples(i)))
%     sample_idxs = [sample_idxs; index];
% end
% % 
% % % and save them...
% % 
% im_info = dir([im_root,'*.png']);
% im_names = cell(1, length(im_info));
% for i=1:length(im_info)
%     im_names{i} = im_info(i).name;
% end
% im_names = sort_nat(im_names);
% % 
% for i=1:length(sample_idxs)
%    curr_sample_idx = sample_idxs(i);
%    
%    curr_sample = im_names(curr_sample_idx)
%    src = strcat(im_root, curr_sample);
%    src = src{1};
%    dest = strcat(out_root, curr_sample);
%    dest = dest{1}
%    copyfile(src, dest);
% end

%%
nmorphs = 20;
cumsum_total = cumsum(corr_vect);
start_point = cumsum_total(1);
end_point = cumsum_total(end);
lin_samples = linspace(start_point, end_point, nmorphs+2);

sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(cumsum_total-lin_samples(i)))
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

if strfind(stimset, 'pov20')
    sample_idxs = linspace(1, nmorphs+2, nmorphs+2);
end


% Save selected samples:
for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i);
   
   curr_sample = im_names(curr_sample_idx)
   src = strcat(im_root, curr_sample);
   src = src{1};
   dest = strcat(out_root, sprintf('morph%i.png', i-1));
%    dest = dest{1}
   copyfile(src, dest);
end

%% Crap sampling due to nonlinear distances?  Generally seems okay for neighbor comparisons (both euclid and pcorr)
% only seems to be a problem for fixed-ref...

save([base_dir,sprintf('V1features_pcorr_neighbor_%s.mat', num2str(length(corr_vect)))], ...
    'cumsum_total', 'sample_idxs', '-append')
