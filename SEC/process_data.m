%% Process data
load('SEC_DataStructure.mat');
[idxA,~] = listdlg('PromptString','Select animal(s):','ListString',{DataStructure.AnimalName});
[idxD,~] = listdlg('PromptString','Select day(s):','ListString',DataStructure(idxA).DateStr);
%% Step 1: id stim times
find_stim_times(DataStructure,idxA,idxD);
%% Step 2: clean stim artifact
algorithm = 'Fra';
% pars = struct('tBefore',1.0,'tAfter',0.8,'meth','SlidingPoly','polyOrder',8); % parameters for Bundy
stim_artifact_removal(DataStructure,idxA,idxD,algorithm);
clearvars -except DataStructure idxA idxD
%% Step 3: filter and remove average
filter_rereference(DataStructure,idxA,idxD)
%% BREAK: check if signal has been cleaned correctly
% assymetrical saturation points could introduce noise with larger
% interpolation points
alt = 'clean'; % set to either 'clean' or 'art'
check_processing(DataStructure,idxA,idxD,alt);
clearvars -except DataStructure idxA idxD
%% BREAK pt 2: re-run artifact cleaning on bad channels
% choose a different algorithm or a correction to run
algorithm = 'Fra';
alt = 'blank'; % not used with SALPA
% select specific channel 
dd = idxD;
if numel(dd) > 1
    [dd,~] = listdlg('PromptString','Select date:','ListString',{(DataStructure(idxA).DateStr{dd})});
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
else
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
end
probes = {'P1','P2'};
[idxP,~] = listdlg('PromptString','Select probe:','ListString',probes);
probe = string(probes(idxP));
channels = compose('Ch_%03d',0:31);
[idxCH,~] = listdlg('PromptString','Select channel:','ListString',channels);
channel = string(channels(idxCH));
f_ch = char(append(probe,'_',channel));
f_name = [DataStructure(idxA).AnimalName '_' DataStructure(idxA).DateStr{dd} '_' num2str(DataStructure(idxA).Run{dd}(rr))];
f_dir = fullfile(DataStructure(idxA).NetworkPath, DataStructure(idxA).AnimalName, f_name);
switch algorithm
    case 'Fra'
        switch alt
            % change parameters for any corrections
            case 'volt'
                pars.satVolt = [-3 2]; % voltage is in kV
            case 'blank'
                pars.blanking = 1.5 * 1e-3; % value is in s
        end
        stim_artifact_removal(f_dir,f_name,f_ch,'Fra',pars);     
    case 'Salpa'
        stim_artifact_removal(f_dir,f_name,f_ch,'Salpa');
end
filter_rereference(f_dir,f_name,f_ch);
clearvars -except DataStructure idxA idxD
%% BREAK pt 3: check if signal has been cleaned correctly
% check individual channels
alt = 'single';
dd = idxD;
if numel(dd) > 1
    [dd,~] = listdlg('PromptString','Select date:','ListString',{(DataStructure(idxA).DateStr{dd})});
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
else
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
end
probes = {'P1','P2'};
[idxP,~] = listdlg('PromptString','Select probe:','ListString',probes);
probe = string(probes(idxP));
channels = compose('Ch_%03d',0:31);
[idxCH,~] = listdlg('PromptString','Select channel:','ListString',channels);
channel = string(channels(idxCH));
f_ch = char(append(probe,'_',channel));
f_name = [DataStructure(idxA).AnimalName '_' DataStructure(idxA).DateStr{dd} '_' num2str(DataStructure(idxA).Run{dd}(rr))];
f_dir = fullfile(DataStructure(idxA).NetworkPath, DataStructure(idxA).AnimalName, f_name);
check_processing(f_dir,f_name,f_ch,alt);
clearvars -except DataStructure idxA idxD
%% Step 4: find periods of artifact
pars.useCAR = 0;
pars.threshRMS = 2;
pars.threshMethod = 1; % 1. Abs Threshold, 2. Find Peaks
find_artifact_periods(DataStructure,idxA,idxD,pars)
clearvars -except DataStructure idxA idxD
%% Step 5: detect spikes
method = 'swtteo';
switch method
    case 'thresh'
        sdRMS = 3;
        useCluster = false;
        CLUSTER = 'CPLMJS';
        detect_spikes_THRESH(DataStructure,idxA,idxD,sdRMS,useCluster,CLUSTER)
    case 'swtteo'
        pars.PeakDur = 2.5;
        pars.MultCoeff = 6;
        pars.LambdaPerc = 99;
        detect_spikes_SWTTEO(DataStructure,idxA,idxD,pars)
    case 'sneo'
        pars.PeakDur = 1;
        pars.MultCoeff = 4.5;
        detect_spikes_SNEO(DataStructure,idxA,idxD,pars);
    case 'adapt'
        pars = [];
        detect_spikes_THRESH_ADAPT(DataStructure,idxA,idxD,pars);
end
clearvars -except DataStructure idxA idxD
%% BREAK: re-run spike detection on single channels
% choose a different algorithm or a correction to run
method = 'swtteo';
% select specific channel 
dd = idxD;
if numel(dd) > 1
    [dd,~] = listdlg('PromptString','Select date:','ListString',{(DataStructure(idxA).DateStr{dd})});
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
else
    [rr,~] = listdlg('PromptString','Select run:','ListString',string(DataStructure(idxA).Run{dd}));
end
probes = {'P1','P2'};
[idxP,~] = listdlg('PromptString','Select probe:','ListString',probes);
probe = string(probes(idxP));
channels = compose('Ch_%03d',0:31);
[idxCH,~] = listdlg('PromptString','Select channel:','ListString',channels);
channel = string(channels(idxCH));
f_ch = char(append(probe,'_',channel));
f_name = [DataStructure(idxA).AnimalName '_' DataStructure(idxA).DateStr{dd} '_' num2str(DataStructure(idxA).Run{dd}(rr))];
f_dir = fullfile(DataStructure(idxA).NetworkPath, DataStructure(idxA).AnimalName, f_name);
switch method
    case 'thresh'
        sdRMS = 3;
        useCluster = false;
        CLUSTER = 'CPLMJS';
        detect_spikes_THRESH(f_dir,f_name,f_ch,sdRMS,useCluster,CLUSTER);
    case 'swtteo'
        pars.PeakDur = 2.5;
        pars.MultCoeff = 6;
        pars.LambdaPerc = 95;
        detect_spikes_SWTTEO(f_dir,f_name,f_ch,pars);
    case 'sneo'
        pars.PeakDur = 2.5;
        pars.MultCoeff = 6;
        detect_spikes_SNEO(f_dir,f_name,f_ch,pars);
    case 'adapt'
        pars = [];
        detect_spikes_THRESH_ADAPT(f_dir,f_name,f_ch,pars);
end
clearvars -except DataStructure idxA idxD
%% Deprecated: circular shift stats
% sd = 'swtteo';
% useCluster = 0;
% useCAR = 0;
% pars.smoothBW_ms = 0.2;
% pars.NResamp = 1; % number of repetitions of shuffled data, precedent is 10,000
% pars.MaxLatency_ms = 25; % sets upper limit for trial length
% pars.DSms = 0.1; % sample frequency (for gaussian filter???)
% run_sig_rndBlanked_chLevel(DataStructure,idxA,idxD,sd,useCAR,useCluster,pars)
% clearvars -except DataStructure idxA idxD