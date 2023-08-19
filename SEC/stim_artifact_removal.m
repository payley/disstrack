%% Removes stimulation artifact and fits any resulting curve to center the data
function stim_artifact_removal(DataStructure,idxA,idxD,algorithm,pars)
% second step in processing stim-evoked activity assays
% primary contributor David Bundy and Francesco Negri with some adaptations made by Page Hayley

% INPUT:
% DataStructure; a structure of the stimulation assay blocks organized by
% animal for normal function or a string indicating a channel to be re-run
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% algorithm; string input for setting the case
% pars; a structure of parameters specific to the algorithm: 
%   tBefore; the default time before the stimulation that is blanked
%   tAfter; the default minimum time after the stimulation that is blanked
%   meth; the method of fitting
%   polyOrder; polynomial order for fitting
%   satVolt; input argument to manually set the saturation voltages (i.e.
%   [-6000 4000])
%
% OUTPUT:
% saves smoothed data in block structure

if isa(DataStructure,'struct')
    for i = idxA %1:length(DataStructure)
        for d = idxD %1:length(DataStructure(i).DateStr
            StimOn = DataStructure(i).StimOn; % select trials that have stimulation
            for j = 1:length(StimOn)
                if StimOn(j)== 1
                    Path = DataStructure(i).NetworkPath;
                    AnimalName = DataStructure(idxA).AnimalName;
                    curFileName = [DataStructure(i).AnimalName '_' ...
                        DataStructure(i).DateStr{d} '_' ...
                        num2str(DataStructure(i).Run{d}(j))];
                    disp(curFileName);
                    load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,curFileName,...
                        [curFileName '_StimTimes.mat']));  % load stim times .mat file
                    UseClust = 0; % Set to not use cluster

                    % start combined section from previous function
                    RAW_PathID = '_RawData'; % setting for naming scheme
                    RAW_FileID = '_Raw';
                    Smooth_PathID = '_RawData_StimSmoothed';
                    Smooth_FileID = '_Raw_StimSmoothed';

                    InPath = fullfile(Path,AnimalName,curFileName,[curFileName RAW_PathID]); % draws from RAW files
                    OutPath = fullfile(Path,AnimalName,curFileName,[curFileName Smooth_PathID]); % outputs SMOOTH files


                    if ~exist(OutPath)  % makes directory if it doesn't exist
                        mkdir(OutPath);
                    end

                    % Determine probe/channel names
                    AllFiles = dir(fullfile(InPath,[curFileName RAW_FileID '*Ch*.mat'])); % creates a list of all the files in the RAW file folder
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

                    % determine sampling frequency and stim timing
                    load(fullfile(Path,AnimalName,curFileName,[curFileName RAW_PathID],...
                        [curFileName RAW_FileID '_P' num2str(PROBES(1)) '_Ch_' num2str(CHANS(1),'%03d') '.mat'])); % loads the first file

                    for iC = 1:length(CHANS)
                        % load data
                        [InData]=load(fullfile(InPath,...
                            [curFileName RAW_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']));
                        SmoothData = InData.data;

                        % run algorithm
                        switch algorithm
                            case 'Bundy'
                                tAfter = pars.tAfter;
                                meth = pars.meth;
                                polyOrder = pars.polyOrder;
                                pars.fs = fs;
                                pars.StimE = StimOffsets;
                                [data,tAfter_ms,PeakedDelay,FalloffDelay] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
                                OutFile = fullfile(OutPath,...
                                    [curFileName Smooth_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']);
                                save(OutFile,'data','fs','tBefore','tAfter','tAfter_ms','PeakedDelay','FalloffDelay','meth','polyOrder');
                            case 'Fra'
                                if ~exist('pars')
                                    pars = struct;
                                end
                                pars.fs = fs;
                                pars.StimI = StimOnsets;
                                [data] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
                                pars.algorithm = algorithm;
                                if isfield(pars,'blanking')
                                    tAfter_ms = pars.blanking * 1000;
                                else
                                    tAfter_ms = 1;
                                end
                                tBefore = 0;
                                PeakedDelay = 0;
                                FalloffDelay = 0;
                                OutFile = fullfile(OutPath,...
                                    [curFileName Smooth_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']);
                                save(OutFile,'data','fs','tBefore','tAfter_ms','PeakedDelay','FalloffDelay','pars');
                            case 'Salpa'
                                if ~exist('pars')
                                    pars = struct;
                                end
                                pars.StimI = StimOnsets;
                                pars.tau = 75;
                                pars.thresh = 3;
                                [data] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
                                pars.algorithm = algorithm;
                                tAfter_ms = 1;
                                tBefore = 0;
                                PeakedDelay = 0;
                                FalloffDelay = 0;
                                OutFile = fullfile(OutPath,...
                                    [curFileName Smooth_FileID '_P' num2str(PROBES(iC)) '_Ch_' num2str(CHANS(iC),'%03d') '.mat']);
                                save(OutFile,'data','fs','tBefore','tAfter_ms','PeakedDelay','FalloffDelay','pars');
                        end
                    end
                end
            end
        end

        % Update parameters
        DataStructure(i).Pars.TimeBeforeStim = tBefore;
        DataStructure(i).Pars.TimeAfterStim = tAfter_ms;
        s = fullfile(DataStructure(i).NetworkPath,'SEC_DataStructure.mat');
        save(s,'DataStructure')

    end
elseif isa(DataStructure,'char')
    RAW_PathID = '_RawData'; % setting for naming scheme
    RAW_FileID = '_Raw';
    Smooth_PathID = '_RawData_StimSmoothed';
    Smooth_FileID = '_Raw_StimSmoothed';

    InPath = fullfile(DataStructure,[idxA RAW_PathID]); % draws from RAW files
    OutPath = fullfile(DataStructure,[idxA Smooth_PathID]); % outputs SMOOTH files

    load(fullfile(DataStructure,...
        [idxA '_StimTimes.mat']));  % load stim times .mat file

    load(fullfile(InPath, [idxA, RAW_FileID, '_', idxD '.mat']),'data','fs');
    SmoothData = data;

    % run algorithm
    switch algorithm
        case 'Bundy'
            pars.fs = fs;
            pars.StimE = StimOffsets;
            [data,tAfter_ms,PeakedDelay,FalloffDelay] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
            OutFile = fullfile(OutPath, [idxA, Smooth_FileID, '_', idxD '.mat']);
            save(OutFile,'data','fs','tBefore','tAfter','tAfter_ms','PeakedDelay','FalloffDelay','pars');
        case 'Fra'
            if ~exist('pars')
                pars = struct;
            end
            pars.fs = fs;
            pars.StimI = StimOnsets;
            [data] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
            pars.algorithm = algorithm;
            tAfter_ms = 1;
            tBefore = 0;
            PeakedDelay = 0;
            FalloffDelay = 0;
            OutFile = fullfile(OutPath, [idxA, Smooth_FileID, '_', idxD '.mat']); 
            ff = figure; 
            plot(data); 
            uiwait(ff); 
            save(OutFile,'data','fs','tBefore','tAfter_ms','PeakedDelay','FalloffDelay','pars');
        case 'Salpa'
            if ~exist('pars')
                pars = struct;
            end
            pars.StimI = StimOnsets;
            pars.tau = 75;
            pars.thresh = 3;
            [data] = stim_artifact_removal_algorithm(SmoothData,algorithm,pars);
            pars.algorithm = algorithm;
            tAfter_ms = 0;
            tBefore = 0;
            PeakedDelay = 0;
            FalloffDelay = 0;
            OutFile = fullfile(OutPath, [idxA, Smooth_FileID, '_', idxD '.mat']);
            ff = figure;
            plot(data);
            uiwait(ff);
            save(OutFile,'data','fs','tBefore','tAfter_ms','PeakedDelay','FalloffDelay','pars');
    end
end
disp('Step 2 complete');