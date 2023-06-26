%% Filter and common average re-reference
function filter_rereference(DataStructure,idxA,idxD)
% third step in processing stim-evoked activity assays
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
%
% OUTPUT:
% saves cleaned files in the block organization

for i = idxA %1:length(DataStructure)
    for d = idxD %1:length(DataStructure(i).DateStr
        for j = 1:length(DataStructure(i).StimOn)
            if DataStructure(i).StimOn(j) == 1
                curFileName = [DataStructure(i).AnimalName '_' ...
                    DataStructure(i).DateStr{d} '_' ...
                    num2str(DataStructure(i).Run{d}(j))];
                
                disp(curFileName);
                
                Calc_Stim_HPFilter_CAR(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,curFileName);
            end
        end
    end
end

disp('Step 3 complete');