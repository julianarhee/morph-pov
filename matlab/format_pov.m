
% clear all; clc;

% Input vars:
base_dir = '/nas/volume1/behavior/stimuli/test_morphs_23levels';
nmorph_imgs = 21 + 2;

function format_pov(base_dir, nmorph_imgs)

%nmorph_imgs = num2str(nmorph_imgs);

middle_morph_idx = round(((nmorph_imgs-2)/2));

%%
source_root = fullfile(base_dir, 'im'); 

finfo = dir(fullfile(source_root,'*.png')); % run resize on newly create grayscale ims
fnames = {finfo(:).name}';
fnames = sort_nat(fnames);
fprintf('Found %i images to format\n', length(fnames));

%rot_y = [-90, -60, -30, 0, 30, 60, 90];
rot_y = [];
for f=1:length(fnames)
    rot_sidx = strfind(fnames{f}, '_y') + 2;
    rot_eidx = strfind(fnames{f}, '.png') -1;
    rot_y = [rot_y str2num(fnames{f}(rot_sidx:rot_eidx))];
end
rot_y = unique(rot_y);

% Set output dirs:
gray_dir = fullfile(base_dir, 'gray');                              % Output for grayscale images
if ~isdir(gray_dir)
    mkdir(gray_dir)
end
size_dir = fullfile(base_dir, 'crop');                              % Output for cropped images
if ~isdir(size_dir)
    mkdir(size_dir)
end
final_dir=fullfile(base_dir, 'final');                              % FINAL output images for behavior
if ~isdir(final_dir)
    mkdir(final_dir)
end
result_fig_dir = fullfile(base_dir, 'results');                     % BB calculations and diff img calculations
if ~exist(result_fig_dir)
    mkdir(result_fig_dir)
end
movie_dir = fullfile(base_dir, 'movies');                           % Movies to view rotations-morphs at same time
if ~exist(movie_dir)
    mkdir(movie_dir)
end

%% Convert to grayscale:
for i=1:nmorph_imgs
    morph_idx = i-1;
    if mod(i, 100) == 0
        sprintf('converting to grayscale: morph %s', num2str(morph_idx))
    end
    for r=1:length(rot_y)
        curr_rot = rot_y(r);
        curr_fn = sprintf('morph%i_y%i.png', morph_idx, curr_rot);  % Morph fn should be standard output from make_pov_morphs.py
        curr_im = fullfile(source_root, curr_fn);
        im = imread(curr_im);                                       % load image
        im = rgb2gray(im);                                          % convert to grayscale
        imwrite(im, fullfile(gray_dir, curr_fn));                   % save image
    end    
end

%% Resize images:
finfo = dir(fullfile(gray_dir,'*.png'));                                    % run resize on grayscale ims
fnames = cell(1, length(finfo));
fnames = {finfo(:).name}';
fnames = sort_nat(fnames);

sprintf('Resizing %s images from dir: %s', num2str(length(fnames)), gray_dir)
ResizeBlobRatStims_General_morphs(fnames, gray_dir, size_dir);
sprintf('FINISHED. Output saved to dir: %s', size_dir)

% NOTE:  The resizing shoudl be sufficient to create centered images!
% Don't do the below unless trying to exactly re-create PNAS 2009 images...


%%
resize_to_original = false
FlagPlotBoundaries=1;

if resize_to_original

    orig_N1_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D1_Rot_y/';
    orig_N2_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D2_Rot_y/';

    for r=1:length(rot_y)
        curr_rot = rot_y(r);

        % Get BB for N1:
        curr_N1_orig = sprintf('Blob_N1_CamRot_y%i.png', curr_rot);
        N1 = imread(fullfile(orig_N1_dir, curr_N1_orig));
        figure(); image(N1); map=gray(256); colormap(map)
        hold on;
        [col_bounds_N1, row_bounds_N1] = FindImageBoundingBox_call( N1, FlagPlotBoundaries );

        title('ORIGINAL: N1')
        disp(['N1 SIZE row: ', num2str(row_bounds_N1(2)-row_bounds_N1(1)+1)])
        disp(['N1 SIZE col: ', num2str(col_bounds_N1(2)-col_bounds_N1(1)+1)])
        figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_N1_orig));
        saveas(gcf, figpath);
        close(gcf);

        % Get BB for N2:
        curr_N2_orig = sprintf('Blob_N2_CamRot_y%i.png', curr_rot);
        N2 = imread(fullfile(orig_N2_dir, curr_N2_orig));
        figure(); image(N2); map=gray(256); colormap(map)
        hold on;
        [col_bounds_N2, row_bounds_N2] = FindImageBoundingBox_call( N2, FlagPlotBoundaries );
        title('ORIGINAL: N2')
        %disp(['N2 SIZE row: ', num2str(row_bounds_N2(2)-row_bounds_N2(1)+1)])
        %disp(['N2 SIZE col: ', num2str(col_bounds_N2(2)-col_bounds_N2(1)+1)])
        figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_N2_orig));
        saveas(gcf, figpath);
        close(gcf);


        % Apply same shift to morph images
        for morph=0:(nmorph_imgs-1)

            % Get BB for current morph image:
            curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot);
            im1 = imread(fullfile(size_dir, curr_morph_fn));
            figure(); image(im1); map=gray(256); colormap(map)
            hold on;
            [col_bounds_im1, row_bounds_im1] = FindImageBoundingBox_call( im1, FlagPlotBoundaries );
            title(curr_morph_fn)
            %disp(['im1 SIZE row: ', num2str(row_bounds_im1(2)-row_bounds_im1(1)+1)])
            %disp(['im1 SIZE col: ', num2str(col_bounds_im1(2)-col_bounds_im1(1)+1)])
            figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_morph_fn));
            saveas(gcf, figpath);
            close(gcf);

            % Create correct-sized background:
            crop = im1(row_bounds_im1(1):row_bounds_im1(2), col_bounds_im1(1):col_bounds_im1(2));
            img_new = PasteImageIntoBackgroundWithGivenDimensions( crop, size(N1,1), size(N1,2) );
            [col_bounds_new, row_bounds_new] = FindImageBoundingBox_call( img_new, FlagPlotBoundaries );

            % Shift object by appropriate # pixels to diff-match N1 (or N2):
    %         if morph < middle_morph_idx
    %             row_shift = row_bounds_N1(2) - row_bounds_new(2);
    %             col_shift = col_bounds_N1(2) - col_bounds_new(2);
    %         elseif morph > middle_morph_idx
    %              row_shift = row_bounds_N2(2) - row_bounds_new(2);
    %              col_shift = col_bounds_N2(2) - col_bounds_new(2);
    %         else
    %              row_shift = round((row_bounds_N1(2) + row_bounds_N2(2))/2) - row_bounds_new(2);
    %              col_shift = round((col_bounds_N1(2) + col_bounds_N2(2))/2) - col_bounds_new(2);
    %         end
            if morph==0
                row_shift = row_bounds_N1(2) - row_bounds_new(2);
                col_shift = col_bounds_N1(2) - col_bounds_new(2);
            else
                row_shift = row_bounds_N2(2) - row_bounds_new(2);
                col_shift = col_bounds_N2(2) - col_bounds_new(2);
            end


            se = translate(strel(1), [row_shift col_shift]);
            img_tr = imdilate(img_new,se);
            [col_bounds_tr, row_bounds_tr] = FindImageBoundingBox_call( img_tr, FlagPlotBoundaries );
            if morph==0
                if morph==0 && all(row_bounds_tr==row_bounds_N1) && all(col_bounds_tr==col_bounds_N1)
                    disp('MATCH!')
                elseif morph==1 && all(row_bounds_tr==row_bounds_N2) && all(col_bounds_tr==col_bounds_N2)
                    disp('MATCH!')
                else
                    disp('BAD match...')
                end
            end

            outpath = fullfile(final_dir, curr_morph_fn);
            imwrite( img_tr, outpath); 

            if morph == 0 %< middle_morph_idx
                DIFF = N1 - img_tr;
                ref = 'D1';
            elseif morph == 1 %morph > middle_morph_idx
                DIFF = N2 - img_tr;
                ref = 'D2';
            else
                DIFF = ((N1+N2)./2) - img_tr;
                ref = 'mid';
            end
            figure(); image(DIFF);
            title(sprintf('DIFF: %s - final image', ref));
            figpath = fullfile(result_fig_dir, sprintf('DIFF_%s_morph%i', ref, morph));
            saveas(gcf, figpath);
            close(gcf);
        end
    end
end


end