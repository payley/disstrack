%% Run stats process for each channel
function [MeanSpikeRate,SpikeCount,MaxSpikeRate,Latency_ms,...
    MeanRandomRate,RandomCount,p,fsDS,Time] = calc_sig_rndBlanked_chLevel(SpikeFile,StimFile,curCh,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms);
% last step in processing stim-evoked activity assays, runs each channel
% through shuffling procedure and outputs stats
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% SpikeFile; spiking data
% StimFile; stimulation data
% curCh; current channel id
% useCluster; a logical for using the clusters for analysis
% smoothBW_ms; smoothing characteristic
% NResamp; number of repetitions of shuffled data where the precedent is 10,000
% MaxLatency_ms; sets upper limit for trial length
% DSms; sample frequency
%
% OUTPUT:
% MeanSpikeRate; mean spike rate
% SpikeCount; overall spike count
% MaxSpikeRate; spike rate at its peak
% Latency_ms; latency of the peak
% MeanRandomRate; mean rate determined from shuffling
% RandomCount; ?
% p; significance of peak over shuffled mean rate
% fsDS; ?
% Time; ?

% stim parameters
load(StimFile);
StimInt_samp = median(StimOnsets(2:end)-StimOffsets(1:end-1)); % samples during stim times

% spike detection parameters
load([SpikeFile num2str(0,'%03d') '.mat']); % load channel data to get sample rate
fs = pars.FS; % sample rate
%PostStimBlanking_ms=pars.POST_STIM_BLANKING;
%PreStimBlanking_ms=pars.PRE_STIM_BLANKING;
%PreStimBlanking_Samp=ceil(fs*PreStimBlanking_ms/1000);
%PostStimBlanking_Samp=ceil(fs*PostStimBlanking_ms/1000);

% analysis window
%Pre_ms=0;Pre_samp=Pre_ms*fs/1000;
Post_ms = MaxLatency_ms; % sets upper limit for the trial
Post_samp = Post_ms*fs/1000; % converts to samples 
fsDS = 1000/DSms; % converts sampling to ms

% unshuffled
AllSpikeTimes=[];
load([SpikeFile num2str(curCh,'%03d') '.mat']); % load channels iteratively based on selection of CAR data or not
PostStimBlanking_ms = pars.POST_STIM_BLANKING; % loads parameters from previous RunDetectSpikes
PreStimBlanking_ms = pars.PRE_STIM_BLANKING;
PreStimBlanking_Samp = ceil(fs*PreStimBlanking_ms/1000); % convert to samples
PostStimBlanking_Samp = ceil(fs*PostStimBlanking_ms/1000);
artifact(artifact == 0) = []; % removes extra numbers
artifactTimeCourse = zeros(size(peak_train));
artifactTimeCourse(artifact) = 1;

for curTrial = 1:length(StimOnsets) % for every stim period
    StartSamp_Anal = StimOffsets(curTrial); % start when stim ends
    EndSamp_Anal = StimOffsets(curTrial) + Post_samp; % end of trial
    StartSamp_Art = StimOffsets(curTrial) + PostStimBlanking_Samp + 1; % start after blanking period
    EndSamp_Art = StimOffsets(curTrial) + StimInt_samp - PreStimBlanking_Samp - 1; % end of samples before next blanking period
    if sum(artifactTimeCourse(StartSamp_Art:EndSamp_Art)) == 0
        curSpikeTimes = find(peak_train(StartSamp_Anal:EndSamp_Anal)); % finds indices of spikes in window
        curSpikeTimes = 1000*curSpikeTimes/fs;
        AllSpikeTimes = vertcat(AllSpikeTimes,curSpikeTimes); % appends all the spike times
    end
end

if ~isempty(AllSpikeTimes) % proceeds if there is data present
    [MeanSpikeRate,Time] = ksdensity(AllSpikeTimes,0:DSms:MaxLatency_ms,'Bandwidth',smoothBW_ms); % runs kernel smoothing
    MeanSpikeRate = MeanSpikeRate*length(AllSpikeTimes)*DSms; % calculates mean spike rate
    SpikeCount = length(AllSpikeTimes); % calculates number of spikes
    [MaxSpikeRate,Latency] = max(MeanSpikeRate); % max mean spike rate
    Latency_ms = Time(Latency); % converts to time
    fprintf('Peak of %3.2f at %02.2f ms for Channel %03d\n',MaxSpikeRate,Latency_ms,curCh);
else % if no data
    Time = 0:DSms:MaxLatency_ms; % creates array of times by sampling frequency
    MeanSpikeRate = zeros(size(Time));
    SpikeCount = 0;
    MaxSpikeRate = 0;
    Latency = 0;
    Latency_ms = 0;
end

% shuffled
if isempty(AllSpikeTimes) % if no data is present
    MeanRandomRate = zeros(NResamp,length(MeanSpikeRate));
    RandomCount = zeros(NResamp,1);
    p = 1;
else
    MeanRandomRate = zeros(NResamp,length(MeanSpikeRate)); % array with rows equaling the number of samples by the length of the window for analysis
    RandomCount = zeros(NResamp,1); % array the length of the number of samples
    rng(1); % random number generator
    RandomStarts = floor(rand(NResamp,length(StimOnsets))*StimInt_samp); % random start times in samples
    
    if useCluster == 1
        parfor curShuf = 1:NResamp % repeat for each random sampling
            %for curShuf=1:NResamp
            AllSpikeTimes = []; % empty AllSpikeTimes
            [peak_train,artifactTimeCourse,PreStimBlanking_ms,PostStimBlanking_ms]=parLoadSpikeFileGlobal([SpikeFile num2str(curCh,'%03d') '.mat']);
            PreStimBlanking_Samp = ceil(fs*PreStimBlanking_ms/1000); % window to blank before specified stim times (samples)
            PostStimBlanking_Samp = ceil(fs*PostStimBlanking_ms/1000);
            for curTrial=1:length(StimOnsets)
                StartSamp_Art = StimOffsets(curTrial) + PostStimBlanking_Samp + 1;
                EndSamp_Art = StimOffsets(curTrial) + StimInt_samp - PreStimBlanking_Samp - 1;
                if sum(artifactTimeCourse(StartSamp_Art:EndSamp_Art)) == 0 % skips trial if there is artifact
                    StartSamp_Trial = StimOffsets(curTrial); % finds trial times
                    EndSamp_Trial = StimOffsets(curTrial) + StimInt_samp - 1;
                    ResortedData = circshift(peak_train(StartSamp_Trial:EndSamp_Trial),RandomStarts(curShuf,curTrial)); % shuffles spikes
                    ResortedData(find(ResortedData(1:PostStimBlanking_Samp))) = []; % imitates blanking period
                    curSpikeTimes = find(ResortedData(1:Post_samp)); % isolates spikes in a comparable time frame
                    curSpikeTimes = 1000*curSpikeTimes/fs;
                    AllSpikeTimes = vertcat(AllSpikeTimes,curSpikeTimes);
                end
            end
            RandomCount(curShuf) = length(AllSpikeTimes);
            [MeanRandomRate(curShuf,:),~] = ksdensity(AllSpikeTimes,0:DSms:MaxLatency_ms,'Bandwidth',smoothBW_ms);
            MeanRandomRate(curShuf,:) = MeanRandomRate(curShuf,:)*length(AllSpikeTimes)*DSms;
        end
    else
        for curShuf = 1:NResamp
            if mod(curShuf,10) == 0
                disp([num2str(curShuf) ' ']);
            end
            AllSpikeTimes = [];
            [peak_train,artifactTimeCourse,PreStimBlanking_ms,PostStimBlanking_ms]=parLoadSpikeFileGlobal([SpikeFile num2str(curCh,'%03d') '.mat']);
            PreStimBlanking_Samp = ceil(fs*PreStimBlanking_ms/1000); % window to blank before specified stim times (samples)
            PostStimBlanking_Samp = ceil(fs*PostStimBlanking_ms/1000);
            for curTrial = 1:length(StimOnsets)
                StartSamp_Art = StimOffsets(curTrial) + PostStimBlanking_Samp + 1; 
                EndSamp_Art = StimOffsets(curTrial) + StimInt_samp - PreStimBlanking_Samp - 1;
                if sum(artifactTimeCourse(StartSamp_Art:EndSamp_Art)) == 0 % skips trial if there is artifact
                    StartSamp_Trial = StimOffsets(curTrial); % finds trial times
                    EndSamp_Trial = StimOffsets(curTrial) + StimInt_samp - 1;
                    ResortedData = circshift(peak_train(StartSamp_Trial:EndSamp_Trial),RandomStarts(curShuf,curTrial)); % shuffles spikes
                    curSpikeTimes = find(ResortedData(1:Post_samp)); % isolates spikes in a comparable time frame
                    curSpikeTimes = 1000*curSpikeTimes/fs;
                    AllSpikeTimes = vertcat(AllSpikeTimes,curSpikeTimes);
                end
            end
            RandomCount(curShuf) = length(AllSpikeTimes);
            if AllSpikeTimes > 0 
                [MeanRandomRate(curShuf,:),~] = ksdensity(AllSpikeTimes,0:DSms:MaxLatency_ms,'Bandwidth',smoothBW_ms);
                MeanRandomRate(curShuf,:) = MeanRandomRate(curShuf,:)*length(AllSpikeTimes)*DSms;
            elseif AllSpikeTimes == 0 % created to address channels with low baseline spiking
                MeanRandomRate = zeros(NResamp,Post_samp);
            end
        end
    end
    
    RandomRatePeak = max(MeanRandomRate,[],2);
    RandomRatePeak = sort(RandomRatePeak,'ascend');
    p = (NResamp - find(MaxSpikeRate>RandomRatePeak,1,'last'))/NResamp;
    fprintf('p-value of %0.5f\n',p);
end