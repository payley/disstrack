%% Detect spikes
function detect_spikes_THRESH(DataStructure,idxA,idxD,sdRMS,useCluster,CLUSTER)
% fifth step in processing stim-evoked activity assays
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% sdRMS; value for spike detection RMS threshold 
% useCluster; a logical for using the clusters for analysis
% CLUSTER; cluster identity
%
% OUTPUT:
% saves spike  times in the block organization

if isa(DataStructure,'struct')
    for ii = idxA %1:length(DataStructure)
        StimOn = DataStructure(ii).StimOn;
        disp([DataStructure(ii).AnimalName]);
        for d = idxD %1:length(DataStructure(i).DateStr
            for i = 1:length(DataStructure(ii).StimOn)
                curFileName = [DataStructure(ii).AnimalName '_' ...
                    DataStructure(ii).DateStr{d} '_' ...
                    num2str(DataStructure(ii).Run{d}(i))];

                % only find stim data if we want to
                if StimOn(i)==1
                    % Load Stim Data and Find Stim Times
                    StimTimeFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_StimTimes.mat']);
                    load(StimTimeFile);

                    % load Artifact file
                    ArtifactFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_NEOArtifact.mat']);
                    load(ArtifactFile);

                    ArtStartIdx = ArtifactNEO(find(diff([-1 ArtifactNEO])>1));
                    ArtEndIdx = ArtifactNEO(find(diff([ArtifactNEO length(ArtNEOTimeCourse)+10])>1));

                    Artifacts = zeros(2,length(ArtStartIdx));
                    Artifacts(1,:) = ArtStartIdx(:);
                    Artifacts(2,:) = ArtEndIdx(:);

                    % stimulus blanking for spike detection

                    load(fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_RawData_StimSmoothed'],...
                        [curFileName '_Raw_StimSmoothed_P' num2str(DataStructure(ii).StimProbe(i)) '_Ch_001.mat']));

                    PRE_STIM_BLANKING  = tBefore; % Window to blank before specified stim times (ms)
                    POST_STIM_BLANKING = tAfter_ms; % Window to blank after specified stim times (ms)

                    % detect
                    disp(['A ' num2str(i)]);
                    qTC_StimSmoothed('CLUSTER',CLUSTER,...
                        'USE_CLUSTER',useCluster,...
                        'DIR',fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName),...
                        'USE_CAR',true,...
                        'PRE_STIM_BLANKING',PRE_STIM_BLANKING,...
                        'POST_STIM_BLANKING',POST_STIM_BLANKING,...
                        'STIM_TS',StimOffsets_s,...
                        'ARTIFACT',Artifacts,...
                        'RMSCOEFF',sdRMS);

                    disp(['B ' num2str(i)]);
                    qTC_StimSmoothed('CLUSTER',CLUSTER,...
                        'USE_CLUSTER',useCluster,...
                        'DIR',fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName),...
                        'USE_CAR',false,...
                        'PRE_STIM_BLANKING',PRE_STIM_BLANKING,...
                        'POST_STIM_BLANKING',POST_STIM_BLANKING,...
                        'STIM_TS',StimOffsets_s,...
                        'ARTIFACT',Artifacts,...
                        'RMSCOEFF',sdRMS);
                else
                    % load artifact file
                    ArtifactFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_NEOArtifact.mat']);
                    load(ArtifactFile);

                    ArtStartIdx = ArtifactNEO(find(diff([-1 ArtifactNEO])>1));
                    ArtEndIdx = ArtifactNEO(find(diff([ArtifactNEO length(ArtNEOTimeCourse)+10])>1));

                    Artifacts=zeros(2,length(ArtStartIdx));
                    Artifacts(1,:)=ArtStartIdx(:);
                    Artifacts(2,:)=ArtEndIdx(:);

                    % detect

                    disp(['A ' num2str(i)]);
                    qTC('CLUSTER',CLUSTER,...
                        'USE_CLUSTER',useCluster,...
                        'DIR',fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName),...
                        'USE_CAR',false,...
                        'ARTIFACT',Artifacts,...
                        'RMSCOEFF',sdRMS);

                    disp(['B ' num2str(i)]);
                    qTC('CLUSTER',CLUSTER,...
                        'USE_CLUSTER',useCluster,...
                        'DIR',fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName),...
                        'USE_CAR',false,...
                        'ARTIFACT',Artifacts,...
                        'RMSCOEFF',sdRMS);
                end
            end
        end

        % update parameters
        DataStructure(ii).Pars.sdRMS = sdRMS;
        s = fullfile(DataStructure(ii).NetworkPath,'SEC_DataStructure.mat');
        save(s,'DataStructure')

    end
elseif isa(DataStructure,'char')
    Filt_PathID = '_Filtered_StimSmoothed'; % setting for naming scheme
    Filt_FileID = '_Filt';
    Spike_PathID = '_TC-neg3.5_ThreshCross';
    Spike_FileID = '_ptrain';

    InPath = fullfile(DataStructure,[idxA Filt_PathID]);
    OutPath = fullfile(DataStructure,[idxA Spike_PathID]);

    load(fullfile(DataStructure,...
        [idxA '_StimTimes.mat']));  % load stim times .mat file
    load(fullfile(DataStructure,...
        [idxA '_NEOArtifact.mat']));
    load(fullfile(InPath, [idxA, Filt_FileID, '_', idxD '.mat']),'data','fs');

    ArtStartIdx = ArtifactNEO(find(diff([-1 ArtifactNEO])>1));
    ArtEndIdx = ArtifactNEO(find(diff([ArtifactNEO length(ArtNEOTimeCourse)+10])>1));
    Artifacts = zeros(2,length(ArtStartIdx));
    Artifacts(1,:) = ArtStartIdx(:);
    Artifacts(2,:) = ArtEndIdx(:);
    pars = Init_TC;
    pars.USE_CAR = 0;
    pars.USE_CLUSTER = 0;
    pars.DIR = idxA;
    pars.SAVE_LOC = idxA;
    pars.ARTIFACT = Artifacts;
    pars.FS = fs;

    [spikedata,pars] = SpikeTCDetectionArray(data, pars);

    if ~exist(fullfile(OutPath),'dir')
        mkdir(fullfile(OutPath))
    end

    parsavedata(fullfile(OutPath,...
        [idxA Spike_FileID '_' idxD '.mat']),...
        'spikes', spikedata.spikes, ...
        'artifact', spikedata.artifact, ...
        'peak_train',  spikedata.peak_train, ...%'features', spikedata.features, ...
        'pw', spikedata.pw, ...
        'pp', spikedata.pp, ...
        'pars', pars)
end
disp('Step 5 complete');