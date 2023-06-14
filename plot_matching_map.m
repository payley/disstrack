%% Plots closest map to neurophys assay
function [nI,I] = plot_matching_map(C,resp)
% plots data as a scatter plot with the circles representing both category 
% of evoked movements and minimum current threshold 
%
% INPUT: 
% C; a table of blocks selected and their respective stimulation array/channel
% resp; a variable indicating the use of multiple ICMS-evoked responses
% or just the major response (1 is primary response only, 2 would be
% multiple)
%
% OUTPUT:
% nI; a table of ICMS-evoked movements reorganized by plotting order
% I; original, unordered table of ICMS-evoked movements
%
% see also match_assay.m, order_maps.m, plot_array.m, and
% create_array_fig.m

%% Set variables
plot = 'map';
%% Runs through blocks
for i = 1:size(C.Blocks,1)
    %% Checks for necessary files and loads them
    [~,aN] = fileparts(char(C.Dir(i)));
    if i == 1
        meta = extractAfter(C.Blocks(:),[aN '_']);
        meta = split(meta,"_");
        meta(:,4) = [];
        bl_date = join(meta,'_');
        check = zeros(size(C.Blocks,1),1);
        [~,idx] = unique(bl_date);
        check(idx) = 1;
        check = logical(check);
    end
    if check(i) == 1 % run once for every date
        if isfile(fullfile(char(C.Dir(i)),[aN '_datematch.mat']))
            load(fullfile(char(C.Dir(i)),[aN '_datematch.mat']));
        else
            ref = C.Dir(i);
            match = match_assays(aN,ref);
        end
        load(fullfile('C:\MyRepos\disstrack\Map',[aN ' map data.mat']));
        if ~isprop(I,"mapOrientation")
            % I = addprop(I,{'AnimalID','mapOrientation','Impedances'},{'table','table','table'});
            % I.Properties.CustomProperties.AnimalID = ''; % set rat surgical name
            % I.Properties.CustomProperties.mapOrientation = ''; % set to L or R depending on which array 1 corresponds to on maps
            % I.Properties.CustomProperties.Impedances = ''; % enter file location of impT here
            disp('Add map orientation!')
            return
        end
        %% Reorders maps
        [nI] = order_maps(I,resp);
        %% Plots the ICMS evoked motor map corresponding to recording block
        m_date = match.map_date{bl_date(i) == match.stim_date};
        map = ['map_' m_date];
        thresh = ['thresh_' m_date];
        nm = {map,thresh};
        plot_array(plot,C,nI,nm);
    else
        return
    end
end