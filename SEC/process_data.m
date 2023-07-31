%% Process data
load('SEC_DataStructure.mat');
[idxA,~] = listdlg('PromptString','Select animal(s):','ListString',{DataStructure.AnimalName});
[idxD,~] = listdlg('PromptString','Select day(s):','ListString',DataStructure(idxA).DateStr);
%% Step 1: id stim times
find_stim_times(DataStructure,idxA,idxD);
%% Step 2: clean stim artifact
algorithm = 'Salpa';
pars = struct('tBefore',1.0,'tAfter',0.8,'meth','SlidingPoly','polyOrder',8); % parameters for Bundy
stim_artifact_removal(DataStructure,idxA,idxD,pars);
%% BREAK: check if signal has been cleaned correctly
% assymetrical saturation points could introduce noise with larger
% interpolation points
check_processing(DataStructure,idxA,idxD);
%% Step 3: filter and remove average
filter_rereference(DataStructure,idxA,idxD)
%% Step 4: find periods of artifact
useCAR = 0;
threshRMS = 2.0;
threshMethod = 2; % 1. Abs Threshold, 2. Find Peaks
find_artifact_periods(DataStructure,idxA,idxD,useCAR,threshRMS,threshMethod)
%% Step 5: detect spikes
method = 'swtteo';
switch method
    case 'thresh'
        sdRMS = 3.5;
        useCluster = false;
        CLUSTER = 'CPLMJS';
        detect_spikes_THRESH(DataStructure,idxA,idxD,sdRMS,useCluster,CLUSTER)
    case 'swtteo'
        pars.PeakDur = [];
        pars.MultCoeff = [];
        detect_spikes_SWTTEO(DataStructure,idxA,idxD,pars)
end
%% Step 6: channel level stats
useCluster = 0;
useCAR = 0;
smoothBW_ms = 0.2;
NResamp = 10; % number of repetitions of shuffled data, precedent is 10,000
MaxLatency_ms = 25; % sets upper limit for trial length
DSms = 0.1; % sample frequency (for gaussian filter???)
run_sig_rndBlanked_chLevel(DataStructure,idxA,idxD,useCAR,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms)