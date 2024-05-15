%% Plot a spike raster of all the trials for a channel
function trial_raster(C,idx,sd)
% loads the quick reference channel stats table if it exists
% creates, populates, and saves the table otherwise; set-up using
% select_data.m
%
% INPUT: 
% C; a reference table with blocks and their respective parameters
% idx; index for the associated block of the channel stats
% sd; case for switching the spike detection method:
%   thresh; hard threshold
%   swtteo; wavelet energy operator

% choose file inputs 
switch sd
    case 'thresh'
        f_name = '_TC-neg3.5_ThreshCross';
        out_file = '_refstats_thresh.mat';
    case 'swtteo'
        f_name = '_SD_SWTTEO';
        out_file = '_stats_swtteo.mat';
end

% check that spike trains have been constructed
if ~exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),f_name]))
    disp('Run spike detection')
end

load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTimes.mat']));
D = dir(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),f_name], ...
    [char(C.Blocks(idx)),'_ptrain' '*Ch*.mat']));
name = string({D.name})';
meta = split(name,"_");
meta(:,9:10) = split(meta(:,9),'.');
meta(:,[1:6 8 10]) = [];
T = cell(size(D,1),1);
for i = 1:numel(D)
    load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),f_name], ...
        [char(C.Blocks(idx)) '_ptrain_' char(meta(i,1)) '_Ch_' char(meta(i,2))]));
    sp = [];
    for ii = 1:numel(StimOffsets)
        trial = StimOffsets(ii);
        fill = (peak_train(trial:trial + 300))';
        sp = [sp; fill];
    end
    reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
        24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
        60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]';
    idxR = reArr(i);
    T{idxR} = sp;
end
if exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'file')
    load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]))
    chPlot.trials = T;
    save(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
else
    disp('run channel_stats.m first')
    return
end
