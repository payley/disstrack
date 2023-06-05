%% Selects data to run
function [C,sel] = select_data(L,S,stim)
% runs through both arrays and all channels
% currently configured to work only with stim workflow
% needs to be reworked to also use with other workflows
%
% INPUT: 
% L; a table with strings of animals names and a cell array of strings called dates
% S; a 1 x number of animals structure with fields for AnimalName, StimOn, and Run 
% stim; a logical value to indicate stim workflow
%
% OUTPUT:
% C; a table of blocks selected and their respective stimulation array/channel
% sel; a sanity check of all the files selected

% opens GUI
[idx,tf] = listdlg('PromptString','Select animal(s):','ListString',L.animals);
if tf == 1
    aI = idx;
    aa = L.animals(idx);
end
dI = cell(numel(aa),1);
dd = cell(numel(aa),1);
for i = 1:numel(aa)
    pr = sprintf('Select recording dates for %s:',aa{i});
    [idx,tf] = listdlg('PromptString',pr,'ListString',L.dates{i});
    if tf == 1
        dI{i} = idx;
        dd{i} = L.dates{i}(idx);
    end
end
% table shows selections
sel = table(aa,dd,'VariableNames',{'Animal_Name','Date'}); 
dir = [];
bl_list = [];
stim_ch = [];
stim_probe = [];
probe_flip = [];
% runs through selections
if stim == 1 % workflow for stimulation experiments
    for i = 1:numel(aa) % animal level
        if iscell(S(aI).StimOn)
            disp('Not equipped to handle more than one experimental set-up at this time')
            return
        end
        anR = aI(i);
        sDates = dd{i};
        sIdx = dI{i};
        for ii = 1:numel(dd{i}) % date level
            iDate = sDates(ii);
            iIdx = sIdx(ii);
            for iii = [2,4] % operating on the condition that stim is on for two blocks, see if statement above
                dir = [dir {fullfile(S(anR).NetworkPath,S(anR).AnimalName)}];
                run = S(anR).Run{iIdx}(iii);
                bl_list = [bl_list string(fullfile([char(aa{i}) '_' char(iDate) '_' char(string(run))]))]; % y??
                stim = S(anR).StimChannel{iIdx}(iii);
                stim_ch = [stim_ch stim];
                stP = S(anR).StimProbe(iii);
                stim_probe = [stim_probe stP];
                if iscell(S(anR).P1Site)
                    disp('Not equipped to handle more than one experimental set-up at this time')
                    return
                end
                if S(anR).P1Site == 'rRFA'
                    probe_flip = [probe_flip 1];
                else
                    probe_flip = [probe_flip 0];
                end
            end
        end
    end
    C = table(bl_list',dir',stim_ch',stim_probe',probe_flip','VariableNames',{'Blocks','Dir','Stim_Ch','Stim_Probe','Probe_Flip'});
else
    disp('In progress...')
    return
end