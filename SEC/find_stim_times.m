%% Find stimulation times
function find_stim_times(DataStructure,idxA,idxD)
% first step in processing stim-evoked activity assays
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
%
% OUTPUT:
% saves stim times and parameters as a file in the block organization

for i = idxA % 1:length(DataStructure)
    AllNumStims = [];
    for d = idxD %1:length(DataStructure(i).DateStr)
        for j = 1:length(DataStructure(i).StimOn)
            % Only find stim data if we want to
            if DataStructure(i).StimOn(j) == 1
                curFileName = [DataStructure(i).AnimalName '_' ...
                    DataStructure(i).DateStr{d} '_' ...
                    num2str(DataStructure(i).Run{d}(j))];
                
                StimAmp = DataStructure(i).StimAmp(j);
                
                if StimAmp>0
                    load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                        curFileName,...
                        [curFileName '_Digital'],...
                        'STIM_DATA',...
                        [curFileName '_STIM_P' num2str(DataStructure(i).StimProbe(j)) '_Ch_' num2str(DataStructure(i).StimChID{d}{j}) '.mat']));
                    
                    StimTrain = data;
                    DiffStim = [0 diff(StimTrain)]; % differences between values
                    
                    % Find onset of stim (beginning of cathodic pulse) and offset of
                    % stim (end of anodic pulse).
                    if DataStructure(i).StimBiphasic(j) == 1
                        if DataStructure(i).CathLeading(j) == 1 % Cathodal leading biphasic
                            StimOnsets = find(StimTrain == -1 * StimAmp & DiffStim == -1 * StimAmp);
                            StimOffsets = find(StimTrain == 0 & DiffStim == -1 * StimAmp);
                        else % Anodal leading biphasic
                            StimOnsets = find(StimTrain == StimAmp & DiffStim==StimAmp);
                            StimOffsets = find(StimTrain == 0 & DiffStim==StimAmp);
                        end
                    else
                        if DataStructure(i).CathLeading{d}(j) == 1 % Cathodal leading monophasic
                            StimOnsets = find(StimTrain == -1*StimAmp & DiffStim == -1*StimAmp);
                            StimOffsets = find(StimTrain == 0 & DiffStim == StimAmp);
                        else % Anodal monophasic
                            StimOnsets = find(StimTrain == StimAmp & DiffStim == StimAmp);
                            StimOffsets = find(StimTrain == 0 & DiffStim == -1*StimAmp);
                        end
                    end
                    
                else
                    load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                        curFileName,...
                        [curFileName '_Digital'],...
                        [curFileName '_DIG_DIGITAL-IN-01.mat']));
                    
                    StimTrain = data;
                    DiffStim = [0 diff(StimTrain)];
                    StimOnsets = find(StimTrain == 1 & DiffStim == 1);
                    %StimOffsets=find(StimTrain==0 & DiffStim==-1);
                    StimOffsets = StimOnsets + fs*400/10^6;
                end
                
                StimOnsets_s = StimOnsets/fs;
                StimOffsets_s = StimOffsets/fs;
                AllNumStims = [AllNumStims length(StimOnsets)];
                
                %Save Data
                savename=fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                    curFileName,...
                    [curFileName '_StimTimes.mat']);
                save(savename,'StimOnsets','StimOffsets','StimOnsets_s','StimOffsets_s','StimAmp');
            else
                AllNumStims = [AllNumStims 0];
            end
        end
        
        % Update parameters
        DataStructure(i).Pars.NumStimPulses = [AllNumStims];
        s = fullfile(DataStructure(idxA).NetworkPath,'SEC_DataStructure.mat');
        save(s,'DataStructure')
        
    end
end

disp('Step complete');