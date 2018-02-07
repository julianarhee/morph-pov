
% clear all; clc;

% Input vars:
% base_dir = '/nas/volume1/behavior/stimuli/blob_transmorphs';
% nmorph_imgs = 23;

function format_pov(base_dir, nmorph_imgs)

nmorph_imgs = str2num(nmorph_imgs);

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

%%
FlagPlotBoundaries=1;

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
    disp(['N2 SIZE row: ', num2str(row_bounds_N2(2)-row_bounds_N2(1)+1)])
    disp(['N2 SIZE col: ', num2str(col_bounds_N2(2)-col_bounds_N2(1)+1)])
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
        disp(['im1 SIZE row: ', num2str(row_bounds_im1(2)-row_bounds_im1(1)+1)])
        disp(['im1 SIZE col: ', num2str(col_bounds_im1(2)-col_bounds_im1(1)+1)])
        figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_morph_fn));
        saveas(gcf, figpath);
        close(gcf);
    
        % Create correct-sized background:
        crop = im1(row_bounds_im1(1):row_bounds_im1(2), col_bounds_im1(1):col_bounds_im1(2));
        img_new = PasteImageIntoBackgroundWithGivenDimensions( crop, size(N1,1), size(N1,2) );
        [col_bounds_new, row_bounds_new] = FindImageBoundingBox_call( img_new, FlagPlotBoundaries );

        % Shift object by appropriate # pixels to diff-match N1 (or N2):
        if morph < middle_morph_idx
            row_shift = row_bounds_N1(2) - row_bounds_new(2);
            col_shift = col_bounds_N1(2) - col_bounds_new(2);
        elseif morph > middle_morph_idx
             row_shift = row_bounds_N2(2) - row_bounds_new(2);
             col_shift = col_bounds_N2(2) - col_bounds_new(2);
        else
             row_shift = round((row_bounds_N1(2) + row_bounds_N2(2))/2) - row_bounds_new(2);
             col_shift = round((col_bounds_N1(2) + col_bounds_N2(2))/2) - col_bounds_new(2);
        end

        se = translate(strel(1), [row_shift col_shift]);
        img_tr = imdilate(img_new,se);
        [col_bounds_tr, row_bounds_tr] = FindImageBoundingBox_call( img_tr, FlagPlotBoundaries );
%         if all(row_bounds_tr==row_bounds_N1) && all(col_bounds_tr==col_bounds_N1)
%             disp('MATCH!')
%             disp(['N1 bounds row, ', mat2str(row_bounds_N1)])
%             disp(['N1 bounds col, ', mat2str(col_bounds_N1)])
%             disp(['SHIFT in ROW: ', num2str(row_shift)])
%             disp(['SHIFT in COL: ', num2str(col_shift)])
%         else
%             disp('BAD MATCH!')
%             disp(['N1 bounds row, ', mat2str(row_bounds_N1)])
%             disp(['N1 bounds col, ', mat2str(col_bounds_N1)])
%             disp(['N1 SIZE row: ', num2str(row_bounds_N1(2)-row_bounds_N1(1)+1)])
%             disp(['N1 SIZE col: ', num2str(col_bounds_N1(2)-col_bounds_N1(1)+1)])
%         end

        outpath = fullfile(final_dir, curr_morph_fn);
        imwrite( img_tr, outpath); 
        
        if morph < middle_morph_idx
            DIFF = N1 - img_tr;
            ref = 'D1';
        elseif morph > middle_morph_idx
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

%%

pos = [180 1 730 1300];
morph_levels = [0 5 11 16 21];
object_names = {};
for mi=1:length(morph_levels)
    if mi==1
        object_names{end+1} = sprintf('D1');
    elseif mi==length(morph_levels)
        object_names{end+1} = sprintf('D2');
    else
        object_names{end+1} = sprintf('morph%i', morph_levels(mi)); 
    end
end    
pan_rots = [rot_y fliplr(rot_y)];


figure(); 
set(gcf, 'Position', pos)

loops = length(pan_rots);
F(loops) = struct('cdata',[],'colormap',[]);
nmorphs_display = length(morph_levels);

for r=1:length(pan_rots)
    % Then load and check generated:
    curr_rot = pan_rots(r);

    midx = 1;
    for morph=morph_levels %0:(nmorph_images/2)-1
        subplot(nmorphs_display,1,midx)
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot);
        im1 = imread(fullfile(size_dir, curr_morph_fn));
        image(im1); map=gray(256); colormap(map)
        title(object_names{midx})
        midx = midx + 1;
        %pause(1);
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    end
    drawnow
    F(r) = getframe(gcf);
    pause(1);
end

movstring = strjoin(object_names, '_');
movpath = fullfile(movie_dir, sprintf('%s.avi', movstring));
movie2avi(F, movpath, 'fps', 1) %,'Compression','Cinepak')

%%
rots_to_plot = rot_y(0:30:end);
morphs_to_plot = 0:2:nmorph_imgs-1;
nrots = length(rots_to_plot);
nmorphs = length(morphs_to_plot);
figure()
pos = [100, 600, 2000, 700];
   
set(gcf, 'Position', pos);
plotidx = 1;
for r=1:length(rot_y)
    % Then load and check generated:
    curr_rot = rot_y(r);

    for morph=0:2:nmorph_imgs-1 %0:(nmorph_images/2)-1
        subplot(nrots, nmorphs, plotidx)
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot);
        im1 = imread(fullfile(size_dir, curr_morph_fn));
        image(im1); map=gray(256); colormap(map)
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        plotidx = plotidx + 1;
    end
end
        
figpath = fullfile(base_dir, 'blob_transmorphs.png');
figpath_pdf = fullfile(base_dir, 'blob_transmorphs.pdf');   

img = getframe(gcf);
imwrite(img.cdata, figpath);

export_fig(figpath_pdf, gcf)

close all

end