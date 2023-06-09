%% Finds closest dates between mapping and neurophys assays 
function [match] = match_assays(animalID,ref)
% shortcut to obtain and hold matching assay information
% should be checked manually
% may add a later functionality to flag days where matching data may not be
% feasible
%
% INPUT: 
% animalID; a character array of the animal ID
% ref; an array with the file location for the directory
%
% OUTPUT:
% match; a table with the dates of the neurophys and their corresponding
% map dates as well as the time difference between the two

%% Set-up variables and create directory
ref = dir(ref);
ref = ref([ref.isdir]);
ref = ref(~ismember({ref.name},{'.','..'}));
%% Parse recording dates and match with map days
meta = {ref.name}';
meta = extractAfter(meta,[animalID '_']);
hold = split(meta,"_"); %
hold(:,4) = []; % collapse different trials and just pull out day info
meta = join(hold,"_");
meta = unique(meta,'rows');
meta_d = datetime(meta,'Format','yyyy_MM_dd');
tot = numel(meta);

load(fullfile('C:\MyRepos\disstrack\Map',[animalID ' map data.mat']));
maps = string(I.Properties.VariableNames);
maps = maps(contains(maps,'map'));
maps = extractAfter(maps,'map_');
maps_d = datetime(maps,'Format','yyyy_MM_dd')';

match = cell(tot,3);
match(:,1) = meta;
for i = 1:tot
    [differ,idx] = min(abs(maps_d - meta_d(i))); % finds closest map to rec date
    match{i,2} = char(maps(idx)); % saves map name
    match{i,3} = (days(differ)); % saves difference in dates
end
%% Convert to table and save variables
match = cell2table(match,'VariableNames',{'stim_date','map_date','t_diff'});
f = sprintf('%s_datematch',animalID);
ff = fullfile([ref(1).folder],[f '.mat']);
save(ff,'match');