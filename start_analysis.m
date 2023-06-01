%% Set path and determine blocks
% Open level of interest in cd (likely animal)
nArr = {'rRFA','lRFA'}; % set array designations
currLoc = pwd;
level_list = dirr(currLoc); % directory at level
ndir = 0;
for i = 1:numel(level_list)
    if isfolder(level_list(i).name) % checks for folders in directory
        ndir=1+ndir;
        block_list(ndir)=level_list(i); % folders are designated as blocks
    end
end
nBlocks = length(block_list);
%% Make new analysis location
for i = 1:nBlocks
    locB =(fullfile(currLoc, block_list(i).name, 'Analysis')); % define name/location of folder
    if exist(locB,'dir')==0 % if non-existent, make new folder
        mkdir(locB)
    end
end
clearvars -except currLoc nArr block_list nBlocks
%% Load spike data and save spike trains
for i = 1:nBlocks % block level
    locSp=(fullfile(currLoc, block_list(i).name,'_Spikes'));
    load(fullfile(currLoc,[block_list(i).name,'_Block.mat']))
    fs = blockObj.SampleRate;
    lenMin = blockObj.Samples./fs./60;
    lenSec = blockObj.Samples./fs;
    totSamples = floor(blockObj.Samples);
    ch_list = dirr(fullfile(locSp));
    for ii = 1:length(ch_list) % channel level
        store = load(fullfile(locSp,ch_list(ii).name));
        sp = store.data;
        pkTrain = zeros(totSamples,1);
        ts = sp(:,4)*fs; % time stamps (by sample) for identified spikes
        pkTrain(round(ts)) = 1; % set samples at timestamps to 1
        spikes = sp(:,5:end);
        artifact = [];
        if contains(ch_list(ii).name,['P1','P2']) % change if less than 32ch arrays are being used 
            idx = (strfind(ch_list(ii).name,'Ch_'))+3;
            nCh = str2num(ch_list(ii).name(idx:(idx+2)));
            if contains(ch_list(ii).name,'P2')
                nCh = nCh+16;
            end
            n = [block_list(i).name,'_ptrain_Ch_',nCh];
            save(fullfile(arr1,n),'spikes','artifact','pkTrain','-v7.3')
        else
            idx = (strfind(ch_list(ii).name,'Ch_'))+3;
            nCh = str2num(ch_list(ii).name(idx:(idx+2)));
            if contains(ch_list(ii).name,'P4')
                nCh = nCh+16;
            end
            n = [block_list(i).name '_ptrain_Ch_',nCh];
            save(fullfile(arr2,n),'spikes','artifact','pkTrain','-v7.3')
        end
    end
end
clearvars -except currLoc nArr arr1 arr2 block_list