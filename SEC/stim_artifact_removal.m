%% Removes stimulation artifact and fits any resulting curve to center the data
function stim_artifact_removal(DataStructure,idxA,idxD,tBefore,tAfter,meth,polyOrder)
% second step in processing stim-evoked activity assays
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% tBefore; the default time before the stimulation that is blanked
% tAfter; the default minimum time after the stimulation that is blanked
% meth; the method of fitting
% polyOrder; polynomial order for fitting
%
% OUTPUT:
% saves smoothed data in block structure

for i = idxA %1:length(DataStructure)
    StimOn = DataStructure(i).StimOn; % select trials that have stimulation
    for d = idxD %1:length(DataStructure(i).DateStr
        for j = 1:length(StimOn)
            if StimOn(j)== 1
                curFileName = [DataStructure(i).AnimalName '_' ...
                    DataStructure(i).DateStr{d} '_' ...
                    num2str(DataStructure(i).Run{d}(j))];
                disp(curFileName);
                load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,curFileName,...
                    [curFileName '_StimTimes.mat']));  % load stim times .mat file
                UseClust = 0; % Set to not use cluster
                RawDataStimArtifactRemoval_CustomBlanking(DataStructure(i).NetworkPath,DataStructure(idxA).AnimalName,...
                    curFileName,...
                    StimOffsets,tBefore,tAfter,meth,polyOrder,UseClust);
            end
        end
    end
    
    % Update parameters
    DataStructure(i).Pars.TimeBeforeStim = tBefore;
    DataStructure(i).Pars.TimeAfterStim = tAfter;
    DataStructure(i).Pars.ArtRemovalMethod = meth;
    DataStructure(i).Pars.PolyOrder = polyOrder;
    s = fullfile(DataStructure(i).NetworkPath,'SEC_DataStructure.mat');
    save(s,'DataStructure')
    
end

disp('Step complete');