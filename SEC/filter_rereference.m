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

if isa(DataStructure,'struct')
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
elseif isa(DataStructure,'char')
    h = split(DataStructure,"\");
    f_an = h{7};
    n_ch = split(idxD,'_');
    Ch = str2double(n_ch{end});
    P = str2double(n_ch{1}(end));
    f_d = join(string({h{1:6}}),'\');
    Calc_Stim_HPFilter_CAR(f_d,f_an,idxA,Ch,P);
end

disp('Step 3 complete');