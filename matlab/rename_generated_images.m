
source_dir = '/nas/volume1/behavior/stimuli/test_morphs_23levels/crop'
nmorphs = 23;
morph_levels = 0:(nmorphs-1)


% First, deal with Blob 1 (this is morph 0):
anchor1 = sprintf('morph%i', morph_levels(1))
fns = dir(fullfile(source_dir, sprintf('%s*.png', anchor1)));
fns = {fns(:).name}';

output_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D1_Rot_y'
if ~exist(output_dir)
    mkdir(output_dir)
end
for f=1:length(fns)
    fparts = strsplit(fns{f}, '_');
    rot_string = fparts{2};
    new_fn = sprintf('Blob_N1_CamRot_%s', rot_string);
    copyfile(fullfile(source_dir, fns{f}), fullfile(output_dir, new_fn));
end


% Now, do Blob 2 (morph 22):
anchor2 = sprintf('morph%i', morph_levels(end))
fns = dir(fullfile(source_dir, sprintf('%s*.png', anchor2)));
fns = {fns(:).name}';

output_dir = '/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_D2_Rot_y'
if ~exist(output_dir)
    mkdir(output_dir)
end
for f=1:length(fns)
    fparts = strsplit(fns{f}, '_');
    rot_string = fparts{2};
    new_fn = sprintf('Blob_N2_CamRot_%s', rot_string);
    copyfile(fullfile(source_dir, fns{f}), fullfile(output_dir, new_fn));
end

% Now for each morph, do the same:
for morph_level = 1:(nmorphs-2)
    fns = dir(fullfile(source_dir, sprintf('morph%i*.png', morph_level)));
    fns = {fns(:).name}';
    output_dir = sprintf('/home/juliana/Repositories/protocols/physiology/stimuli/images/Blob_M%i_Rot_y', morph_level)
    if ~exist(output_dir)
        mkdir(output_dir)
    end
    
    for f=1:length(fns)
        fparts = strsplit(fns{f}, '_');
        rot_string = fparts{2};
        new_fn = sprintf('morph%i_CamRot_%s', morph_level, rot_string);
        copyfile(fullfile(source_dir, fns{f}), fullfile(output_dir, new_fn));
    end
end
    