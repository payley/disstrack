%% Find artifactual periods in the data using a NEO
function find_artifact_periods(DataStructure,idxA,idxD,useCAR,threshRMS,threshMethod)
% fourth step in processing stim-evoked activity assays
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% useCAR; a logical variable indicating to use the previously extracted CAR data
% threshRMS; value for RMS threshold 
% threshMethod; index for the thresholding method: 1) absolute threshold or 2) find peaks
%
% OUTPUT:
% saves cleaned files in the block organization

ThreshRef = {'Abs Threshold','Find Peaks'};
for ii = idxA %length(DataStructure)
    StimOn = DataStructure(ii).StimOn;
    UseFile = ones(size(StimOn));
    for d = idxD %length(DataStructure(i).DateStr
        for i = 1:length(DataStructure(ii).StimOn)
            if UseFile(i) == 1
                curFileName = [DataStructure(ii).AnimalName '_' ...
                    DataStructure(ii).DateStr{d} '_' ...
                    num2str(DataStructure(ii).Run{d}(i))];
                if StimOn(i) == 1
                    % Load stimulus train
                    load(fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_Digital'],...
                        'STIM_DATA',...
                        [curFileName '_STIM_P' num2str(DataStructure(ii).StimProbe(i)) '_Ch_' num2str(DataStructure(ii).StimChannel{d}(i),'%03d') '.mat']));
                    StimTrain=data;
                    
                    load(fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_StimTimes.mat']));
                    StimOnsets = StimOnsets;
                    StimOffsets = StimOffsets;
                    
                    load(fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                        curFileName,...
                        [curFileName '_RawData_StimSmoothed'],...
                        [curFileName '_Raw_StimSmoothed_P' num2str(DataStructure(ii).StimProbe(i)) '_Ch_001.mat']));
                    %StimBlanking_ms = [TimeBefore_ms TimeAfter_ms];
                    
                    %[NEO,NEO_orig] = CalcSummedNEO(DataStructure.NetworkPath,DataStructure.AnimalName,DataStructure.FileName{i},1,StimOffsets,[StimOnsets(1) StimOffsets(end)],StimBlanking_ms,1000);
                    [NEO,NEO_orig] = CalcSummedNEO(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName,useCAR,StimOffsets,[StimOnsets(1) StimOffsets(end)],[],1000);
                else
                    
                    [NEO,NEO_orig] = CalcSummedNEO(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,curFileName,useCAR,[],[],[],1000);
                end
                Thresh = median(NEO)+threshRMS*rms(NEO);
                lowThresh = median(NEO)+0.1*rms(NEO);
                
                ArtNEOTimeCourse = zeros(size(NEO));
                if threshMethod == 1
                    ArtNEOTimeCourse(NEO>Thresh)=1;
                elseif threshMethod == 2
                    [Pks,Pklocs] = findpeaks(NEO,'MinPeakHeight',Thresh);
                    if ~isempty(Pks)
                        k = 1;
                        while k<=length(Pks)
                            leftEdge = find(NEO(1:Pklocs(k))<=lowThresh,1,'last');
                            rightEdge = find(NEO(Pklocs(k):end)<=lowThresh,1,'first');
                            rightEdge = rightEdge+Pklocs(k);
                            if isempty(leftEdge)
                                leftEdge = 1;
                            end
                            if isempty(rightEdge)
                                rightEdge = length(NEO);
                            end
                            ArtNEOTimeCourse(leftEdge:rightEdge)=1;
                            if k<length(Pks)
                                k = k+1;
                            end
                            if Pklocs(k) <= rightEdge
                                k = find(Pklocs>=rightEdge,1,'first');
                            end
                        end
                    end
                end
                ArtifactNEO = find(ArtNEOTimeCourse==1);
                
                %save file
                save(fullfile(DataStructure(ii).NetworkPath,DataStructure(ii).AnimalName,...
                    curFileName,...
                    [curFileName '_NEOArtifact.mat']),...
                    'NEO','ArtifactNEO','ArtNEOTimeCourse','Thresh','threshRMS');
            end
        end
    end
    
    % Update parameters
    DataStructure(ii).Pars.ThreshRMS = threshRMS;
    DataStructure(ii).Pars.ThreshMethod = ThreshRef{threshMethod};
    DataStructure(ii).Pars.UseCARforNEO = useCAR;
    s = fullfile(DataStructure(ii).NetworkPath,'SEC_DataStructure.mat');
    save(s,'DataStructure')
    
end

disp('Step 4 complete');