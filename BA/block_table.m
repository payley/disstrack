%% Load file
load('phProject_Tank.mat')
%% Create table of blocks for aim 2
nb = tankObj.getNumBlocks;
injN = ["R22-01","R22-05","R22-27","R22-28","R22-29","R23-01","R23-06","R23-09","R23-10"];
animal_name = cell(nb,1);
block_name = cell(nb,1);
exp_group = zeros(nb,1);
exp_time = nan(nb,1);
listBl.reach = cell(nb,1);
listBl.array_order = cell(nb,1);
listBl = table(animal_name,block_name,exp_group,exp_time);
for i = 1:numel(tankObj.Children)
    start = find(cellfun(@isempty,listBl.animal_name),1,'first');
    bl = string({tankObj.Children(i).Children.Name});
    nbl = numel(bl);
    for ii = 0:nbl-1
        idx = start + ii;
        listBl.block_name{idx} = char(bl(ii+1));
        listBl.animal_name{idx} = char(tankObj.Children(i).Name);
        if sum(injN == tankObj.Children(i).Name) > 0
            listBl.exp_group(idx) = 1;
        end
    end
end
% manually labeled time in exp_time and laterality for reach and
% array_order variables
%% Create array for 
listBl.incl_control = zeros(size(listBl,1),1);
if ~exist('impl_dates','var')
    load('C:\MyRepos\disstrack\BA\implant_dates.mat')
end
for i = 1:size(listBl,1)
sDat = impl_dates.dates(strcmp(listBl.animal_name{i},impl_dates.animal_name)); 
meta = split(listBl.block_name{i},'-');
date = meta{2};
full_date = datetime(['20' date(1:2) '-' date(3:4) '-' date(5:6)]);
dat_diff = char(between(sDat,full_date,'Days'));
fill_dat = str2double(dat_diff(1:end-1));
listBl.incl_control(i) = fill_dat;
end
listBl.incl_control(~(isnan(listBl.exp_time) | listBl.exp_time == 0)) = NaN;