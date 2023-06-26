%% Pull each channel and set-up stats process
function setup_sig_rndBlanked_chLevel(DataStructure,idxA,idxD,useCAR,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms)
% last step in processing stim-evoked activity assays, pulls each channel
% and assigns it to run
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% useCAR; a logical for using CAR data
% useCluster; a logical for using the clusters for analysis
% smoothBW_ms; smoothing characteristic
% NResamp; number of repetitions of shuffled data where the precedent is 10,000
% MaxLatency_ms; sets upper limit for trial length
% DSms; sample frequency
%
% OUTPUT:
% saves stats in the block organization

UNC_Paths = {'\\kumc.edu\data\research\SOM RSCH\NUDOLAB\Processed_Data\', ...
    '\\kumc.edu\data\research\SOM RSCH\NUDOLAB\Recorded_Data\'};
Channels = 1:32; % # of channels on each array
if isempty(smoothBW_ms)
    smoothBW_ms = 0.2; % sets gaussian filter characteristics
end

for ii = idxA %1:length(DataStructure) % reps for number of animals
    for d = idxD %1:length(DataStructure(i).DateStr)
        for i = 1:length(DataStructure(ii).StimOn)% reps for number of trials with stim
            curFileName = [DataStructure(ii).AnimalName '_' ...
                DataStructure(ii).DateStr{d} '_' ...
                num2str(DataStructure(ii).Run{d}(i))];
            if DataStructure(ii).StimOn(i) == 1 % continues if a stim trial
                
                if useCluster == 0
                    disp([num2str(i) ': ' curFileName]);
                end
                
                % Stim File
                StimFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_StimTimes.mat']); % load stim file
                
                OutFolder = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_StimTriggeredStats_ChannelSpiking_RandomBlanked']); % save stats loc
                if useCluster == 1
                    OutFolder = [UNC_Paths{1} OutFolder((find(OutFolder == filesep,1,'first')+1):end)];
                    StimFile = [UNC_Paths{1} StimFile((find(StimFile == filesep,1,'first')+1):end)];
                end
                if ~exist(OutFolder,'dir')
                    mkdir(OutFolder);
                end
                
                for P2Plot = 1:2 % array number
                    figure;
                    hold on
                    for curChID = 1:length(Channels) % for each channel
                        curCh = curChID - 1;
                        if useCAR == 1 % use CAR data
                            SpikeFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                                curFileName,...
                                [curFileName '_TC-neg3.5_CAR_ThreshCross'],...
                                [curFileName '_ptrain_P' num2str(P2Plot) '_Ch_']);
                        else % or not
                            SpikeFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                                curFileName,...
                                [curFileName '_TC-neg3.5_ThreshCross'],...
                                [curFileName '_ptrain_P' num2str(P2Plot) '_Ch_']);
                        end
                        if useCluster == 1
                            SpikeFile = [UNC_Paths{1} SpikeFile((find(SpikeFile == filesep,1,'first')+1):end)];
                        end
                        
                        % Calculate Significance
                        [MeanSpikeRate,SpikeCount,MaxSpikeRate,Latency_ms,...
                            MeanRandomRate,RandomCount,p,...
                            fsDS,Time] = ...
                            calc_sig_rndBlanked_chLevel(SpikeFile,StimFile,curCh,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms);
                        % subplot(4,8,curChID);
                        % plot(Time,MeanSpikeRate);
                        % cap = fprintf('Array %1f, Channel %03f\n',P2Plot,curCh);
                        % title(cap);
                        OutFile = fullfile(OutFolder,[curFileName '_ChannelStats_P' num2str(P2Plot) '_Ch' num2str(curCh,'%03d') '.mat']);
                        %parsave_StimStats_GlobalRate(OutFile,MeanSpikeRate,SpikeCount,MaxSpikeRate,Latency_ms,...
                        %    MeanRandomRate,RandomCount,p,...
                        %    fsDS,Time);
                        pause(15);
                        save(OutFile,'MeanSpikeRate','SpikeCount','MaxSpikeRate','Latency_ms',...
                            'MeanRandomRate','RandomCount','p',...
                            'fsDS','Time','-v7.3');
                    end
                end
            end
        end
    end
    
    % Update parameters
    DataStructure(i).Pars.SmoothBW = smoothBW_ms;
    DataStructure(i).Pars.NResample = NResamp;
    DataStructure(i).Pars.DSms = DSms;
    DataStructure(i).Pars.MaxLatency = MaxLatency_ms;
    s = fullfile(DataStructure(i).NetworkPath,'SEC_DataStructure.mat');
    save(s,'DataStructure')
    
end