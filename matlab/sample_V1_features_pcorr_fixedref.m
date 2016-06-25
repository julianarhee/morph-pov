clear all
close all

% source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/morph2000_gray_resize/'; % .mat files
% out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/morph2000_pcorr_fixedref/'; % output pngs
% im_root='/nas/volume1/behavior/stimuli/pnas_morphs/morph2000/morph2000_gray_resize/';
% base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/V1_features/samples/';

addpath(genpath('./helpers'))
addpath(genpath('./hmaxMatlab'))

source_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1features/pov2000_final/';
out_root='/nas/volume1/behavior/stimuli/pnas_morphs/samples/V1_pcorr_fixedref/';

im_root='/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/final/';

base_dir = '/nas/volume1/behavior/stimuli/pnas_morphs/samples/';


tmp_source = strsplit(source_root,'/');
source = tmp_source{end-1};
tmp_out = strsplit(out_root, '/');
stimset = tmp_out{end-1};

D = struct();
D.source = source;
D.stimset = stimset;

% if ~isdir(out_root)
%     mkdir(out_root)
%     sprintf('Created output dir: %s', out_root)
% end

finfo = dir([source_root,'*.mat']);
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);
    
first_im = load([source_root, fnames{1}]);
first_feature_vect = first_im.featureVector;  % just need 1st column of corr mat

sprintf('Loaded first feature vector %s from: %s', fnames{1}, source_root)

D.dist_vect = [];
curr_vect_idx = 1;

while 1
    
    sprintf('IDX: %i', curr_vect_idx)
    
    if mod(curr_vect_idx, 100) == 0
        sprintf('calculating correlation between 0 and %s', fnames{curr_vect_idx})
    end
        
    
    curr_vect = load([source_root, fnames{curr_vect_idx}]);
    
    pcorr = corr(first_feature_vect', curr_vect.featureVector');
    
    D.dist_vect = [D.dist_vect; pcorr];
    
    curr_vect_idx = curr_vect_idx + 1;
    
    if curr_vect_idx>length(fnames)
        break;
    end

end

D.fnames = fnames;
D.first_feature_vect = first_feature_vect;

% save this, bec it takes forever to make...
matname = sprintf('V1_pcorr_fixedref_%s.mat', num2str(length(D.dist_vect)));
save([base_dir, matname], 'D')

fprintf('Saved .mat to: %s', [base_dir, matname])


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

%% Load .mat if exists...


mname = 'V1_pcorr_fixedref_';
base_root = '/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/';

mfiles = dir([base_root,'*.mat']);

matnames = cell(1, length(mfiles));
for i=1:length(mfiles)
    if strfind(mfiles(i).name, mname)
    	matnames{i} = mfiles(i).name;
    end
end
matnames = matnames(~cellfun('isempty', matnames))

matname = matnames{1};

load([base_root, matname]); % This should load struct D


%% Get linearly-spaced samples

nmorphs = 20;
% lin_samples = linspace(min(D.dist_vect), max(D.dist_vect), nmorphs+2); % add 2 to account for anchors
lin_samples = linspace(D.dist_vect(1), D.dist_vect(end), nmorphs+2);

% Get indices into stimulus bank (im_root):
sample_idxs = [];
for i=1:length(lin_samples)
    [c index] = min(abs(D.dist_vect-lin_samples(i)))
    sample_idxs = [sample_idxs; index];
end

im_info = dir([im_root,'*.png']);
im_names = cell(1, length(im_info));
for i=1:length(im_info)
    im_names{i} = im_info(i).name;
end
im_names = sort_nat(im_names);

% if strfind(stimset, 'pov20')
%     sample_idxs = linspace(1, nmorphs+2, nmorphs+2);
% end
     
D.sample_idxs = sample_idxs;
% and save them...
for i=1:length(sample_idxs)
   curr_sample_idx = sample_idxs(i);
   sprintf('index: %i, sample num: %i', i, curr_sample_idx)
   
   curr_sample = im_names(curr_sample_idx);
   src = strcat(im_root, curr_sample);
   src = src{1};
   %dest = strcat(out_root, curr_sample);
   dest = strcat(out_root, 'morph', num2str(i-1), '.png');
   %dest = dest{1}
   copyfile(src, dest);
end

%%
% CRAP SAMPLING due to non-linear changes:
% sample_idxs = linspace(0, nmorphs+1, nmorphs+2);
save([base_dir, matname], 'D', '-append')