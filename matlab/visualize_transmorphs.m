
function visualize_transmorphs(base_dir, nmorph_imgs)

base_dir = '/nas/volume1/behavior/stimuli/blob_transmorphs_all'
nmorph_imgs = 23;
% nmorph_imgs = str2num(nmorph_imgs);

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

middle_morph_idx = round(((nmorph_imgs-2)/2));

%%

finfo = dir(fullfile(final_dir,'*.png')); % run resize on newly create grayscale ims
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

%%
morph_levels = [0 5 11 16 21];
rots_to_plot = rot_y(1:6:end);

%%
pos = [180 1 730 1300];
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
pan_rots = [rots_to_plot fliplr(rots_to_plot)];

h=figure(); 
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
        im1 = imread(fullfile(final_dir, curr_morph_fn));
        image(im1); map=gray(256); colormap(map)
        title(object_names{midx})
        midx = midx + 1;
        %pause(1);
        set(gca,'xtick',[])
        set(gca,'ytick',[])
    end
    drawnow
    movegui(h)
    F(r) = getframe(gcf);
    pause(1);
end

movstring = strjoin(object_names, '_');
movpath = fullfile(movie_dir, sprintf('%s.avi', movstring));
movie2avi(F, movpath, 'fps', 1) %,'Compression','Cinepak')

%%

morphs_to_plot = 0:2:nmorph_imgs-1;
nrots = length(rots_to_plot);
nmorphs = length(morphs_to_plot);
figure()
pos = [100, 600, 2000, 700];
   
set(gcf, 'Position', pos);
plotidx = 1;
for r=1:nrots
    % Then load and check generated:
    curr_rot = rots_to_plot(r);

    for morph=0:2:nmorph_imgs-1 %0:(nmorph_images/2)-1
        subplot(nrots, nmorphs, plotidx)
        curr_morph_fn = sprintf('morph%i_y%i.png', morph, curr_rot);
        im1 = imread(fullfile(final_dir, curr_morph_fn));
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