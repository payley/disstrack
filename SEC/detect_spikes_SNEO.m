%% Detect spikes
function detect_spikes_SNEO(DataStructure,idxA,idxD,pars)
% fifth step in processing stim-evoked activity assays

% INPUT:
% DataStructure; a structure of the stimulation assay blocks organized by animal
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% pars; a structure of parameters
%
% OUTPUT:
% saves spike  times in the block organization

% set-up default parameters

if isempty(pars.PeakDur)
    pars.PeakDur = 1;
end

if isempty(pars.MultCoeff)
    pars.MultCoeff = 4.5;
end

pars.SmoothN    = 5;   
pars.NSaround   = 7;    
pars.RefrTime   = 0.5; 
pars.Polarity   =  -1;

if isa(DataStructure,'struct')
    for ii = idxA %1:length(DataStructure)
        StimOn = DataStructure(ii).StimOn;
        disp([DataStructure(ii).AnimalName]);
        for d = idxD %1:length(DataStructure(i).DateStr
            for i = 1:length(DataStructure(ii).Run{d})
                Path = DataStructure(ii).NetworkPath;
                AnimalName = DataStructure(idxA).AnimalName;
                curFileName = [DataStructure(ii).AnimalName '_' ...
                    DataStructure(ii).DateStr{d} '_' ...
                    num2str(DataStructure(ii).Run{d}(i))];

                % load filtered data files and their metadata
                % start combined section from previous function
                if DataStructure(ii).StimOn(i) == 1
                    Filt_PathID = '_Filtered_StimSmoothed'; % setting for naming scheme
                elseif DataStructure(ii).StimOn(i) == 0
                    Filt_PathID = '_Filtered'; % setting for naming scheme
                end
                Filt_FileID = '_Filt';
                Spike_PathID = '_SD_SNEO';
                Spike_FileID = '_ptrain';

                InPath = fullfile(Path,AnimalName,curFileName,[curFileName Filt_PathID]); % draws from RAW files
                OutPath = fullfile(Path,AnimalName,curFileName,[curFileName Spike_PathID]); % outputs SMOOTH files

                AllFiles = dir(fullfile(InPath,[curFileName Filt_FileID '*Ch*.mat'])); % creates a list of all the files in the RAW file folder
                AllFiles = {AllFiles.name}.';

                % load artifact file
                aFile = fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_NEOArtifact.mat']);
                load(aFile);

                ArtStartIdx = ArtifactNEO(find(diff([-1 ArtifactNEO])>1));
                ArtEndIdx = ArtifactNEO(find(diff([ArtifactNEO length(ArtNEOTimeCourse)+10])>1));

                art = zeros(2,length(ArtStartIdx));
                art(1,:) = ArtStartIdx(:);
                art(2,:) = ArtEndIdx(:);

                CHANS=[];
                PROBES=[];

                for iCh = 1:numel(AllFiles) % creates a list of names from channels and probes
                    temp = strsplit(AllFiles{iCh}(1:(end-4)), '_');
                    iPNum = str2double(temp{end-2}(2:end));
                    PROBES = [PROBES, iPNum];
                    ch = str2double(temp{end});
                    CHANS = [CHANS, ch];
                end

                for iC = 1:length(CHANS)
                    load(fullfile(InPath,...
                        [curFileName Filt_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']));
                    pars.fs = fs;
                    pars.W_PRE = round(0.4 / 1000 * pars.fs);
                    pars.W_POST = round(0.8 / 1000 * pars.fs);
                    pars.ls = double(pars.W_PRE + pars.W_POST); % Length of spike
                    pars.PRE_STIM_BLANKING = 0;
                    pars.POST_STIM_BLANKING = 0.8;
                    pars.ARTIFACT = art;

                    % remove artifacts
                    [data_ART,artifact] = Remove_Artifact_Periods(data,art);

                    % run spike detection
                    [ts,p2pamp,pp,pw] = SD_SNEO(data_ART,pars);
                    out_of_record = ts <= pars.W_PRE + 1 | ts >= numel(data)-pars.W_POST - 2; % removes any spikes at the beginning and end of recording
                    ts(out_of_record) = [];
                    p2pamp(out_of_record) = [];
                    pw(out_of_record) = [];
                    pp(out_of_record) = [];

                    % build spike train
                    p2pamp = double(p2pamp);
                    if (any(ts))
                        nspk = numel(ts);
                        spikes = zeros(nspk,pars.ls+4);
                        for ispk = 1:nspk
                            spikes(ispk,:) = data((ts(ispk)-double(pars.W_PRE) - 1): ...
                                (ts(ispk)+double(pars.W_POST) +2));
                        end
                        peak_train = sparse(ts,1,p2pamp,numel(data_ART),1);
                    else
                        peak_train = sparse(double(numel(data)) + double(numel(data)), double(1));
                        spikes = [];
                    end

                    spikedata.peak_train = peak_train;      % Spike (neg.) peak times
                    spikedata.artifact = artifact;          % Artifact times
                    spikedata.spikes = spikes;              % Spike snippets
                    spikedata.pp = pp;                      % Prominence
                    spikedata.pw = pw;                      % Width

                    pars = rmfield(pars,'fs');
                    pars.FS = fs;

                    if ~exist(fullfile(OutPath),'dir')
                        mkdir(fullfile(OutPath))
                    end

                    % save file
                    parsavedata(fullfile(OutPath,...
                        [curFileName Spike_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']), ...
                        'spikes', spikedata.spikes, ...
                        'artifact', spikedata.artifact, ...
                        'peak_train',  spikedata.peak_train, ...
                        'pw', spikedata.pw, ...
                        'pp', spikedata.pp, ...
                        'pars', pars);
                end
            end
        end

        % update parameters
        DataStructure(ii).Pars.SNEO = pars;
        s = fullfile(DataStructure(ii).NetworkPath,'SEC_DataStructure.mat');
        save(s,'DataStructure')

    end
elseif isa(DataStructure,'char')
    Filt_PathID = '_Filtered_StimSmoothed'; % setting for naming scheme
    Filt_FileID = '_Filt';
    Spike_PathID = '_SD_SNEO';
    Spike_FileID = '_ptrain';

    InPath = fullfile(DataStructure,[idxA Filt_PathID]);
    OutPath = fullfile(DataStructure,[idxA Spike_PathID]);

    load(fullfile(DataStructure,...
        [idxA '_StimTimes.mat']));  % load stim times .mat file
    load(fullfile(DataStructure,...
        [idxA '_NEOArtifact.mat']));
    ArtStartIdx = ArtifactNEO(find(diff([-1 ArtifactNEO])>1));
    ArtEndIdx = ArtifactNEO(find(diff([ArtifactNEO length(ArtNEOTimeCourse)+10])>1));

    art = zeros(2,length(ArtStartIdx));
    art(1,:) = ArtStartIdx(:);
    art(2,:) = ArtEndIdx(:);

    load(fullfile(InPath, [idxA, Filt_FileID, '_', idxD '.mat']),'data','fs');

    pars.fs = fs;
    pars.W_PRE = round(0.4 / 1000 * pars.fs);
    pars.W_POST = round(0.8 / 1000 * pars.fs);
    pars.ls = double(pars.W_PRE + pars.W_POST); % Length of spike
    pars.PRE_STIM_BLANKING = 0;
    pars.POST_STIM_BLANKING = 0.8;
    pars.ARTIFACT = art;

    % remove artifacts
    [data_ART,artifact] = Remove_Artifact_Periods(data,pars);

    % run spike detection
    [ts,p2pamp,pp,pw] = SD_SNEO(data_ART,pars);
    out_of_record = ts <= pars.W_PRE + 1 | ts >= numel(data)-pars.W_POST - 2; % removes any spikes at the beginning and end of recording
    ts(out_of_record) = [];
    p2pamp(out_of_record) = [];
    pw(out_of_record) = [];
    pp(out_of_record) = [];

    % build spike train
    p2pamp = double(p2pamp);
    if (any(ts))
        nspk = numel(ts);
        spikes = zeros(nspk,pars.ls+4);
        for ispk = 1:nspk
            spikes(ispk,:) = data((ts(ispk)-double(pars.W_PRE) - 1): ...
                (ts(ispk)+double(pars.W_POST) +2));
        end
        peak_train = sparse(ts,1,p2pamp,numel(data_ART),1);
    else
        peak_train = sparse(double(numel(data)) + double(numel(data)), double(1));
        spikes = [];
    end

    spikedata.peak_train = peak_train;      % Spike (neg.) peak times
    spikedata.artifact = artifact;          % Artifact times
    spikedata.spikes = spikes;              % Spike snippets
    spikedata.pp = pp;                      % Prominence
    spikedata.pw = pw;                      % Width

    pars = rmfield(pars,'fs');
    pars.FS = fs;

    if ~exist(fullfile(OutPath),'dir')
        mkdir(fullfile(OutPath))
    end

    % save file
    parsavedata(fullfile(OutPath,...
        [idxA Spike_FileID '_' idxD '.mat']), ...
        'spikes', spikedata.spikes, ...
        'artifact', spikedata.artifact, ...
        'peak_train',  spikedata.peak_train, ...
        'pw', spikedata.pw, ...
        'pp', spikedata.pp, ...
        'pars', pars);
end

disp('Step 5 complete');