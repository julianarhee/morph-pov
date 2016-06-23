clear all
close all

% get V1 features for a group of images

addpath('./hmaxMatlab')
addpath('./helpers')

source_root='/nas/volume1/behavior/stimuli/pnas_morphs/samples/pixels_project_na/';
out_root='/nas/volume1/behavior/stimuli/pnas_morphs/V1features/pixels_project_na/';

if ~isdir(out_root)
    mkdir(out_root)
    sprintf('Created output dir: %s', out_root)
end

imnames = dir([source_root,'*.png']);

fprintf('initializing S1 gabor filters\n');
orientations = [90 -45 0 45]; % 4 orientations for gabor filters
RFsizes      = 7:2:39;        % receptive field sizes
div          = 4:-.05:3.2;    % tuning parameters for the filters' "tightness"
[filterSizes,filters,c1OL,~] = initGabor(orientations,RFsizes,div);

fprintf('initializing C1 parameters\n')
% c1Scale = 6:2:18; % defining 4 scale bands
c1Scale = 9:2:18; % defining 4 scale bands
c1Space = 16:2:22; % defining spatial pooling range for each scale band

% objIDList={'N1','N2'};
% rotList=-90:10:90;

% V1info={};
% for o=1:length(objIDList)
V1info = [];
for i=1:length(imnames)
    
    % load image
    morph_idx = i-1;
    
    if mod(i, 100) == 0
        sprintf('creating V1 features for morph %s', num2str(morph_idx))
    end
         
    curr_im = [source_root,'morph', num2str(morph_idx),'.png'];
    im0 = double(imread(curr_im));
    
    % get V1 features (complex and simple cells)
    [c1,s1] = C1(im0,filters,filterSizes,c1Space,c1Scale,c1OL,0);
    
    featureVector=[];
    %unroll features into vector
    for sc=1:length(c1Scale)-1
        for ph=1:2
            for or =1 :length(orientations)
                featureVector=[featureVector s1{sc}{ph}{or}(:)'];
            end
        end
    end
    for sc=1:length(c1Scale)-1
        featureVector=[featureVector c1{sc}(:)'];
    end

%     V1info = [V1info; featureVector];
    
    save([out_root,sprintf('V1_features_morph%s.mat', num2str(morph_idx))])
end
% end
% V1info=V1info{1};
%save cell array with each cell containing the V1 feature vector for one
%object
% save([out_root,'V1Features.mat'],'V1info','rotList','objIDList')
