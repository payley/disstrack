function Calc_ChannelSpikeTriggeredStats_RatConnectivity_RandomBlanked(DataStructure,UseCluster,SmoothBW_ms,UseCAR)

%% File Info:
DataStructure = DataStructure;

UNC_Paths = {'\\kumc.edu\data\research\SOM RSCH\NUDOLAB\Processed_Data\', ...
    '\\kumc.edu\data\research\SOM RSCH\NUDOLAB\Recorded_Data\'};

if isempty(SmoothBW_ms)
    SmoothBW_ms = 0.2; % sets gaussian filter characteristics
end

NResamp = 10000; % number of repetitions of shuffled data, precedent is 10,000
%NResamp=100;
MaxLatency_ms = 25; % sets upper limit for trial length
DSms = 0.1; % sample frequency (for gaussian filter???)
Channels = 1:32; % # of channels on each array
for ii = 1:length(DataStructure) % reps for number of animals
    for d = 1:length(DataStructure(i).DateStr)
        for i = 1:length(DataStructure(ii).StimOn)% reps for number of trials with stim
            curFileName = [DataStructure(ii).AnimalName '_' ...
                DataStructure(ii).DateStr{d} '_' ...
                num2str(DataStructure(ii).Run{d}(i))];
            if DataStructure(ii).StimOn(i) == 1 % continues if a stim trial
                
                if UseCluster == 0
                    disp([num2str(i) ': ' curFileName]);
                end
                
                % Stim File
                StimFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_StimTimes.mat']); % load stim file
                
                OutFolder = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_StimTriggeredStats_ChannelSpiking_RandomBlanked']); % save stats loc
                if UseCluster == 1
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
                        if UseCAR == 1 % use CAR data
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
                        if UseCluster == 1
                            SpikeFile=[UNC_Paths{1} SpikeFile((find(SpikeFile == filesep,1,'first')+1):end)];
                        end
                        
                        % Calculate Significance
                        [MeanSpikeRate,SpikeCount,MaxSpikeRate,Latency_ms,...
                            MeanRandomRate,RandomCount,p,...
                            fsDS,Time]=...
                            ChannelStimEvokedSpikingSignificance_RandomBlanked(SpikeFile,StimFile,curCh,NResamp,SmoothBW_ms,DSms,MaxLatency_ms,UseCluster);
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
    DataStructure(i).Pars.SmoothBW = SmoothBW_ms;
    DataStructure(i).Pars.NResample = NResamp;
    DataStructure(i).Pars.DSms = DSms;
    DataStructure(i).Pars.MaxLatency = MaxLatency_ms;
    s = fullfile(DataStructure.NetworkPath,'SEC_DataStructure.mat');
    save(s,'DataStructure')
    
end