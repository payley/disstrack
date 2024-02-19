%% LOOKS LIKE IT IS WORKING BUT TIMING IS OFF
%% Analyze spiking, identify peaks, and save in table
function analyze_spiking(C,pVal,bin,post_ms)
% loads stats files, runs find peaks function, plots a figure, and saves
% table of peak info
%
% INPUT: 
% C; a reference table with blocks and their respective parameters
% pVal; the p-value for significance (i.e. 0.005)
% bin; bin width for 
% post_ms; the extent of the analysis period after stim start
%
% OUTPUT:
% none at this time
%
% uses table produced by select_data.m

for i = 1:size(C.Blocks,1)
    arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
    ch = [1:32,1:32]';
    ch = compose('Ch%03d',ch);
    n = zeros(64,1);
    c = cell(64,1);
    P = table(arr,ch,n,c,c,c,c,c,'VariableNames',{'Array','Channel','Number_Peaks', ...
        'Peak_Height','Peak_Latency','Spikes','Mean','Stdev'});
    load(fullfile(C.Dir{i},char(C.Blocks(i)),...
        [char(C.Blocks(i)) '_StimTimes.mat']));
    StimInt_samp = median(StimOnsets(2:end)-StimOffsets(1:end-1));
    StimTime = StimOffsets(1) - StimOnsets(1);
    
    AllSpikeTimes = [];
    for ii = 1:2 % for each array
        figure;
        hold on
        for iii = 1:32 % for every channel
            if ii == 1 
                rIdx = iii; % indices for inputting into a table
            elseif ii == 2
                rIdx = iii + 32;
            end
            ch_id = char(compose('Ch%03d',(iii-1)));
            ch_id2 = char(compose('%03d',(iii-1)));
            % pull spikes from post-stimulus time period
            load(fullfile(C.Dir{i},char(C.Blocks(i)),...
                [char(C.Blocks(i)) '_TC-neg3.5_ThreshCross'],...
                [char(C.Blocks(i)) '_ptrain_P' num2str(ii) '_Ch_' ch_id2]));
            fs = pars.FS;
            span = post_ms*2/bin + 1;
            factor = bin*fs/1000;
            post_samp = post_ms*fs/1000;
            PostStimBlanking_ms = pars.POST_STIM_BLANKING; % loads parameters from previous RunDetectSpikes
            PreStimBlanking_ms = pars.PRE_STIM_BLANKING;
            PreStimBlanking_samp = ceil(fs*PreStimBlanking_ms/1000); % convert to samples
            PostStimBlanking_samp = ceil(fs*PostStimBlanking_ms/1000);
            artifact(artifact == 0) = []; % removes extra numbers
            artifactTimeCourse = zeros(size(peak_train));
            artifactTimeCourse(artifact) = 1;
            for curTrial = 1:length(StimOnsets) % for every stim period
                StartSamp_Anal = StimOffsets(curTrial) - post_samp; % reflected start and end time around 0
                EndSamp_Anal = StimOffsets(curTrial) + post_samp - StimTime; % subtracted the stimulation period
                StartSamp_Art = StimOffsets(curTrial) + PostStimBlanking_samp + 1; % start after blanking period
                EndSamp_Art = StimOffsets(curTrial) + StimInt_samp - PreStimBlanking_samp - 1; % end of samples before next blanking period
                if sum(artifactTimeCourse(StartSamp_Art:EndSamp_Art)) == 0
                    curSpikeTimes = zeros(1,span); % creates a logical array with bins as set
                    spIdx = find(peak_train(StartSamp_Anal:EndSamp_Anal)); % finds indices of spikes in window
                    spIdx = ceil(spIdx/factor); % converts index to one that corresponds to new bin size
                    curSpikeTimes(spIdx) = 1;
                    AllSpikeTimes = [AllSpikeTimes; curSpikeTimes]; % appends all the spike times
                end
            end
            P.Spikes{rIdx} = AllSpikeTimes;
            P.Mean = mean(AllSpikeTimes,1);
            P.Stdev = std(AllSpikeTimes,0,1);
            % Determine peaks
            if ii == 1
                nm = fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)) ...
                    '_StimTriggeredStats_ChannelSpiking_RandomBlanked'], ...
                    [char(C.Blocks(i)) '_ChannelStats_P1_' ch_id]);
            elseif ii == 2
                nm = fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)) ...
                    '_StimTriggeredStats_ChannelSpiking_RandomBlanked'], ...
                    [char(C.Blocks(i)) '_ChannelStats_P2_' ch_id]);
            end
            load(nm);
            RandomRatePeak = max(MeanRandomRate,[],2);
            RandomRatePeak = sort(RandomRatePeak,'ascend');
            NResample = size(RandomCount,1);
            pIdx = NResample - (NResample*pVal);
            sigP = RandomRatePeak(pIdx);
            subplot(8,4,iii)
            findpeaks(MeanSpikeRate,Time,'NPeaks',5,'MinPeakHeight',sigP,'SortStr','descend','MinPeakDistance',1);
            [pkh,pki]= findpeaks(MeanSpikeRate,Time,'NPeaks',5,'MinPeakHeight',sigP,'SortStr','descend','MinPeakDistance',1);
            if isempty(pkh)
                P.Number_Peaks(rIdx) = 0;
                P.Peak_Height{rIdx} = NaN;
                P.Peak_Latency{rIdx} = NaN;
            end
            P.Number_Peaks(rIdx) = numel(pkh);
            P.Peak_Height{rIdx} = pkh;
            P.Peak_Latency{rIdx} = pki;
        end
        title([char(C.Blocks(i)) 'Array ' ii]);
    end
    t = -post_ms:bin:post_ms;
    P.data = P;
    P.pars = struct('post_ms',post_ms,'fs',fs,'time',t);
    save(fullfile(C.Dir{i},char(C.Blocks(i)),[char(C.Blocks(i)) '_peaks']),'P'); % save table
end