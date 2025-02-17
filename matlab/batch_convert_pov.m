clear all
close all
clc

%%
% source_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/im/';
% gray_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/gray/';
% size_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/crop/';
% 
% final_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/POV/pov2000/final/';

%%
all_rots_y = [];
for f=1:length(fnames)
    rot_sidx = strfind(fnames{f}, '_y') + 2;
    rot_eidx = strfind(fnames{f}, '.png') -1;
    all_rots_y = [all_rots_y str2num(fnames{f}(rot_sidx:rot_eidx))];
end
all_rots_y = unique(all_rots_y);

nmorph_images = 22;
base_dir = '/tmp/morphs';

source_root=fullfile(base_dir, 'im'); %'/tmp/morphs/im/';
gray_root=fullfile(base_dir, 'gray'); %'/tmp/morphs/gray/';
size_root=fullfile(base_dir, 'crop'); %'/tmp/morphs/crop/';

final_root=fullfile(base_dir, 'final'); %'/tmp/morphs/final/';

result_fig_dir = fullfile(base_dir, 'results'); %'/tmp/morphs/results';
if ~exist(result_fig_dir)
    mkdir(result_fig_dir)
end

movie_dir = fullfile(base_dir, 'movies'); % '/tmp/morphs/movies';
if ~exist(movie_dir)
    mkdir(movie_dir)
end
%%
% Convert to grayscale:

% if ~isdir(gray_root)
%     mkdir(gray_root)
%     sprintf('Created output dir: %s', gray_root)
% end

if ~isdir(size_root)
    mkdir(size_root)
    sprintf('Created output dir: %s', size_root)
end

if ~isdir(final_root)
    mkdir(final_root)
    sprintf('Created FINAL dir: %s', final_root)
end


% imnames = dir([source_root,'*.png']);
% 
% for i=1:length(imnames)
%     
%     % load image
%     morph_idx = i-1;
%     
%     if mod(i, 100) == 0
%         sprintf('converting to grayscale: morph %s', num2str(morph_idx))
%     end
%          
%     curr_im = [source_root,'morph', num2str(morph_idx),'.png'];
%     im = imread(curr_im);
%     im = rgb2gray(im);
%     imwrite(im, [gray_root, sprintf('morph%i.png', morph_idx)]);
%       
% end

%%
% Resize and crop images:
% 
% gray_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/FINAL/gray/';
% size_root='/media/nas/volume1/behavior/stimuli/pnas_morphs/samples/FINAL/crop/';

finfo = dir([gray_root,'*.png']); % run resize on newly create grayscale ims
fnames = cell(1, length(finfo));
for i=1:length(finfo)
    fnames{i} = finfo(i).name;
end
fnames = sort_nat(fnames);

sprintf('Resizing %s images from dir: %s', num2str(length(fnames)), gray_root)
ResizeBlobRatStims_General_morphs(fnames, gray_root, size_root);
sprintf('FINISHED. Output saved to dir: %s', size_root)


%% CHECK IMAGE:

% First, IMAGE A:

FlagPlotBoundaries=1;

orig_N1_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D1_Rot_y/'

for r=1:length(all_rots_y)
    curr_rot = all_rots_y(r);

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

    % Then load and check generated:
    for morph=0:(nmorph_images/2)-1
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot)
        im1 = imread(fullfile(size_root, curr_morph_fn));
        figure(); image(im1); map=gray(256); colormap(map)
        hold on;
        [col_bounds_im1, row_bounds_im1] = FindImageBoundingBox_call( im1, FlagPlotBoundaries );

        title('IMAGE 1')
        disp(['im1 SIZE row: ', num2str(row_bounds_im1(2)-row_bounds_im1(1)+1)])
        disp(['im1 SIZE col: ', num2str(col_bounds_im1(2)-col_bounds_im1(1)+1)])
        figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_morph_fn));
        saveas(gcf, figpath);
        close(gcf);
    
        % Create correct-sized background:
        %imshow(im1(row_bounds_im1(1):row_bounds_im1(2), col_bounds_im1(1):col_bounds_im1(2)));
        crop = im1(row_bounds_im1(1):row_bounds_im1(2), col_bounds_im1(1):col_bounds_im1(2));
        img_new = PasteImageIntoBackgroundWithGivenDimensions( crop, size(N1,1), size(N1,2) );
        [col_bounds_new, row_bounds_new] = FindImageBoundingBox_call( img_new, FlagPlotBoundaries );

        % Shift object by appropriate # pixels to diff-match N1:
        row_shift = row_bounds_N1(2) - row_bounds_new(2);
        col_shift = col_bounds_N1(2) - col_bounds_new(2);

        se = translate(strel(1), [row_shift col_shift]);
        img_tr = imdilate(img_new,se);
        [col_bounds_tr, row_bounds_tr] = FindImageBoundingBox_call( img_tr, FlagPlotBoundaries );
        if all(row_bounds_tr==row_bounds_N1) && all(col_bounds_tr==col_bounds_N1)
            disp('MATCH!')
            disp(['N1 bounds row, ', mat2str(row_bounds_N1)])
            disp(['N1 bounds col, ', mat2str(col_bounds_N1)])
            disp(['SHIFT in ROW: ', num2str(row_shift)])
            disp(['SHIFT in COL: ', num2str(col_shift)])
        else
            disp('BAD MATCH!')
            disp(['N1 bounds row, ', mat2str(row_bounds_N1)])
            disp(['N1 bounds col, ', mat2str(col_bounds_N1)])
            disp(['N1 SIZE row: ', num2str(row_bounds_N1(2)-row_bounds_N1(1)+1)])
            disp(['N1 SIZE col: ', num2str(col_bounds_N1(2)-col_bounds_N1(1)+1)])
        end

        outpath = fullfile(final_root, curr_morph_fn);
        imwrite( img_tr, outpath); 

        DIFF = N1 - img_tr;
        figure(); image(DIFF);
        title('DIFF: N1 - final image')
        figpath = fullfile(result_fig_dir, sprintf('DIFF_%s', curr_N1_orig));
        saveas(gcf, figpath);
        close(gcf);
    
    % Apply same shift to morph images of same rotation:
    end

end

%%

%% IMAGE 2:


% Then, IMAGE B:
orig_N2_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D2_Rot_y/'

for r=1:length(all_rots_y)
    curr_rot = all_rots_y(r);

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

    % Read in LAST morph:
    % Then load and check generated:
    % Then load and check generated:
    for morph=(nmorph_images/2):nmorph_images-1
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot)
        
        im2 = imread(fullfile(size_root, curr_morph_fn));
        figure(); image(im2); map=gray(256); colormap(map)
        hold on;
        [col_bounds_im2, row_bounds_im2] = FindImageBoundingBox_call( im2, FlagPlotBoundaries );

        title('IMAGE 2')
        disp(['im2 SIZE row: ', num2str(row_bounds_im2(2)-row_bounds_im2(1)+1)])
        disp(['im2 SIZE col: ', num2str(col_bounds_im2(2)-col_bounds_im2(1)+1)])
        figpath = fullfile(result_fig_dir, sprintf('BB_%s', curr_morph_fn));
        saveas(gcf, figpath);
        close(gcf);
    
        % Create correct-sized background:
        crop = im2(row_bounds_im2(1):row_bounds_im2(2), col_bounds_im2(1):col_bounds_im2(2));
        img_new2 = PasteImageIntoBackgroundWithGivenDimensions( crop, size(N2,1), size(N2,2) );
        [col_bounds_new2, row_bounds_new2] = FindImageBoundingBox_call( img_new2, FlagPlotBoundaries );

        % Shift object by appropriate # pixels to diff-match N1:
        row_shift2 = row_bounds_N2(2) - row_bounds_new2(2);
        col_shift2 = col_bounds_N2(2) - col_bounds_new2(2);

        se = translate(strel(1), [row_shift2 col_shift2]);
        img_tr2 = imdilate(img_new2,se);
        [col_bounds_tr2, row_bounds_tr2] = FindImageBoundingBox_call( img_tr2, FlagPlotBoundaries );
        if all(row_bounds_tr2==row_bounds_N2) && all(col_bounds_tr2==col_bounds_N2)
            disp('MATCH!')
            disp(['N2 bounds row, ', mat2str(row_bounds_N2)])
            disp(['N2 bounds col, ', mat2str(col_bounds_N2)])
            disp(['SHIFT in ROW: ', num2str(row_shift2)])
            disp(['SHIFT in COL: ', num2str(col_shift2)])
        else
            disp('BAD MATCH!')
            disp(['N2 bounds row, ', mat2str(row_bounds_N2)])
            disp(['N2 bounds col, ', mat2str(col_bounds_N2)])
            disp(['N2 SIZE row: ', num2str(row_bounds_N2(2)-row_bounds_N2(1)+1)])
            disp(['N2 SIZE col: ', num2str(col_bounds_N2(2)-col_bounds_N2(1)+1)])
        end

        outpath = fullfile(final_root, curr_morph_fn);
        imwrite( img_tr2, outpath ); 

        DIFF = N2 - img_tr2;
        figure(); image(DIFF);
        title('DIFF: N2 - final image')
        figpath = fullfile(result_fig_dir, sprintf('DIFF_%s', curr_N2_orig));
        saveas(gcf, figpath);
        close(gcf);
    end
end

%%
pos = [180 1 730 1300];
morph_levels = [0 5 16 21];
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
pan_rots = [all_rots_y fliplr(all_rots_y)];


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
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot)
        im1 = imread(fullfile(size_root, curr_morph_fn));
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


%% Paste BW images into correct bounding box:

if row_shift2==row_shift
    
    % Do the same for all:
    disp(['Bounding Box + Translation for all ', num2str(length(fnames)), ' images!'])
    
    % Loop on all stimuli
    for Stim = 1:length(fnames)

        % Load image:
        Image2Load = [size_root, fnames{Stim}];
        [img map] = imread( Image2Load );
        
        [img_new] = PasteImageIntoBackgroundWithGivenDimensions( img, size(N1,1), size(N1,2) );
        
        se = translate(strel(1), [row_shift 0]);

        img_tr = imdilate(img_new,se);

        OutName = [final_root, fnames{Stim}]
        imwrite( img_tr, OutName, 'png' ); 
        %imshow(img_tr);
        %rawnow;

    end; %for Stim


else
    
    disp(['DIFF # pixels needed to match FIRST and LAST image:'])
    disp(['im1 to N1: ', num2str(row_shift)])
    disp(['im2 to N2: ', num2str(row_shift2)])

end


%% Get 1st and last image to be exactly the same:
% 
% % LOAD ORIGINALS:
% 
% % First, IMAGE A:
% FlagPlotBoundaries=1;
% 
% N1 = imread('/home/juliana/Repositories/morph-pov/originals/Blob_N1_CamRot_y0.png');
% figure(); image(N1); map=gray(256); colormap(map)
% hold on;
% [col_bounds_N1, row_bounds_N1] = FindImageBoundingBox_call( N1, FlagPlotBoundaries );
% 
% title('ORIGINAL: N1')
% disp(['N1 SIZE row: ', num2str(row_bounds_N1(2)-row_bounds_N1(1)+1)])
% disp(['N1 SIZE col: ', num2str(col_bounds_N1(2)-col_bounds_N1(1)+1)])
% 
% % Then, IMAGE B:
% 
% N2 = imread('/home/juliana/Repositories/morph-pov/originals/Blob_N2_CamRot_y0.png');
% figure(); image(N2); map=gray(256); colormap(map)
% hold on;
% [col_bounds_N2, row_bounds_N2] = FindImageBoundingBox_call( N2, FlagPlotBoundaries );
% 
% title('ORIGINAL: N2')
% disp(['N2 SIZE row: ', num2str(row_bounds_N2(2)-row_bounds_N2(1)+1)])
% disp(['N2 SIZE col: ', num2str(col_bounds_N2(2)-col_bounds_N2(1)+1)])
% 
% 
% 
% %%
% 
% curr_im = fnames{1}
% Image2Load = [out_root, curr_im]; 
% [img map] = imread( Image2Load ); 
% 
% figure(); image(img); map=gray(256); colormap(map)
% hold on;
% [col_bounds, row_bounds] = FindImageBoundingBox_call( img, FlagPlotBoundaries );
% title('cropped A')
% 
% disp(['IM SIZE row: ', num2str(row_bounds(2)-row_bounds(1)+1)])
% disp(['IM SIZE col: ', num2str(col_bounds(2)-col_bounds(1)+1)])
% 
% 
% 
% %%
% 
% xmin = col_bounds_N1(1);
% ymin = row_bounds_N1(1);
% width = col_bounds_N1(2) - col_bounds_N1(1)  ;
% height = row_bounds_N1(2) - row_bounds_N1(1) ;
% 
% N1_crop = imcrop(N1, [xmin ymin width height]);
% 
% xmin = col_bounds(1);
% ymin = row_bounds(1);
% width = col_bounds(2) - col_bounds(1)  ;
% height = row_bounds(2) - row_bounds(1) ;
% 
% % img_crop = imcrop(img, [xmin-2 ymin-2 width+4 height+4]);
% 
% 
% % Try just image from above w/ funny res:
% 
% % [img_new] = PasteImageIntoBackgroundWithGivenDimensions( img, 617, 1080 );
% % 
% % % needs shifting...
% % se = translate(strel(1), [-3 0]);
% % img_tr = imdilate(img,se);
% 
% img_pad = padarray(img, [0 col_bounds_N1(1)-col_bounds(1)], 'pre');
% img_pad2 = padarray(img_pad, [5 col_bounds_N1(2)-col_bounds(2)], 'post');
% size(img_pad2)
% 
% [img_new] = PasteImageIntoBackgroundWithGivenDimensions( img_pad2, 617, 1080 );
% [col_bounds_im, row_bounds_im] = FindImageBoundingBox_call( img_pad2, FlagPlotBoundaries );
% 
% %%
% 
% % THIS WORKS WITH 1.02 scale PERL
% 
% % SCALE:
% imscale = imresize(img, [614 710], 'bicubic');  % <-- trial and error...! 
% % TRANSLATE:
% se = translate(strel(1), [0 0]); 
% img_tr = imdilate(imscale,se); 
% [img_new] = PasteImageIntoBackgroundWithGivenDimensions( img_tr, 617, 1080 ); 
% 
% figure(); image(img_new); map=gray(256); colormap(map);
% hold on;
% [col_bounds, row_bounds] = FindImageBoundingBox_call( img_new, FlagPlotBoundaries ); 
% 
% disp(['IM SIZE row: ', num2str(row_bounds(2)-row_bounds(1)+1)])
% disp(['IM SIZE col: ', num2str(col_bounds(2)-col_bounds(1)+1)])
% 
% %%
% 
% 
% % SAVE:
% 
% if ~isdir(final_root)
%     mkdir(final_root)
%     sprintf('Created FINAL output dir: %s', final_root)
% end
% 
% OutName = [final_root, curr_im];
% h_f = figure;
% imshow(img_new);
% imwrite( img_new, OutName, 'png' ); 
% 
% close(h_f);
% 
% DIFF = img_new - N1;
% image(DIFF)
% map=gray(256); colormap(map)
% 
% % Now, deal with IMAGE B
% 
% N2 = imread('/home/juliana/Repositories/morph-pov/originals/Blob_N2_CamRot_y0.png');
% [col_bounds_N2, row_bounds_N2] = FindImageBoundingBox_call( N2, FlagPlotBoundaries );
% 
% disp(['N2 SIZE row: ', num2str(row_bounds_N2(2)-row_bounds_N2(1)+1)])
% disp(['N2 SIZE col: ', num2str(col_bounds_N2(2)-col_bounds_N2(1)+1)])
% 
% Image2Load = [outdir, fnames{end}]; 
% [img map] = imread( Image2Load ); 
% imscale = imresize(img, [615 NaN]);  % <-- trial and error...! 
% figure(); image(imscale); map=gray(256); colormap(map)
% [col_bounds, row_bounds] = FindImageBoundingBox_call( imscale, FlagPlotBoundaries );
% disp(['IM SIZE row: ', num2str(row_bounds(2)-row_bounds(1)+1)])
% disp(['IM SIZE col: ', num2str(col_bounds(2)-col_bounds(1)+1)])
% 
% 
