%% Detect spikes
function detect_spikes_SWTTEO(DataStructure,idxA,idxD,pars)
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
    pars.PeakDur = 2.5;
end

if isempty(pars.MultCoeff)
    pars.MultCoeff = 6;
end

pars.wavLevel = 2;
pars.waveName = 'sym6';
pars.winType = @hamming;
pars.smoothN = 25;
pars.winPars = {'symmetric'};
pars.RefrTime = 1;
pars.Polarity = -1;

for ii = idxA %1:length(DataStructure)
    StimOn = DataStructure(ii).StimOn;
    disp([DataStructure(ii).AnimalName]);
    for d = idxD %1:length(DataStructure(i).DateStr
        for i = 1:length(DataStructure(ii).StimOn)
            Path = DataStructure(ii).NetworkPath;
            AnimalName = DataStructure(idxA).AnimalName;
            curFileName = [DataStructure(ii).AnimalName '_' ...
                DataStructure(ii).DateStr{d} '_' ...
                num2str(DataStructure(ii).Run{d}(i))];
            % load filtered data files and their metadata
            % start combined section from previous function
            Filt_PathID = '_Filtered_stimSmoothed'; % setting for naming scheme
            Filt_FileID = '_Filt';
            Spike_PathID = '_SD_SWTTEO';
            Spike_FileID = '_ptrain';
            

            InPath = fullfile(Path,AnimalName,curFileName,[curFileName Filt_PathID]); % draws from RAW files
            OutPath = fullfile(Path,AnimalName,curFileName,[curFileName Spike_PathID]); % outputs SMOOTH files

            AllFiles = dir(fullfile(InPath,[curFileName Filt_FileID '*Ch*.mat'])); % creates a list of all the files in the RAW file folder
            AllFiles = {AllFiles.name}.';

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
                pars.w_pre = double(round(0.4 / 1000 * pars.fs));        % Samples before spike
                pars.w_post = double(round(0.8 / 1000 * pars.fs));       % Samples after spike
                pars.ls = double(pars.w_pre + pars.w_post);                    % Length of spike

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
                pars.ARTIFACT = art;
                
                % remove artifacts
                [data_ART,artifact] = Remove_Artifact_Periods(data,pars);
                
                % run spike detection
                [ts,p2pamp,pp,pw] = SD_SWTTEO(data_ART,pars);

                % build spike train
                p2pamp = double(p2pamp);
                if (any(ts)) 
                    nspk = numel(ts);
                    spikes = zeros(nspk,pars.ls+4);
                    for ispk = 1:nspk
                        spikes(ispk,:) = data((ts(ispk)-double(pars.w_pre) - 1): ...
                            (ts(ispk)+double(pars.w_post) +2));
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
    DataStructure(ii).Pars.SWTTEO = pars;
    s = fullfile(DataStructure(ii).NetworkPath,'SEC_DataStructure.mat');
    save(s,'DataStructure')

end

disp('Step 5 complete');