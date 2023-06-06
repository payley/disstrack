%% Load files
if exist('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_list.mat')
    load('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_list.mat');
else
    disp('Missing structual elements or wrong path');
    return
end

if exist('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_DataStructure.mat')
    load('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_DataStructure.mat');
else
    disp('Missing structual elements or wrong path');
    return
end
%% Set variables
% case for plotting:
% input 'lat' for plotting latency
% 'amp' for plotting amplitude of the response
plot = 'lat';
switch plot
    case 'lat'
        low_lim = 0.8;
        up_lim = 20;
        mid = 4;
        cut_off = 0.8; % set to low_lim or up_lim if values should be grayed out
    case 'amp'
        low_lim = 1;
        up_lim = 100;
        mid = 10;
        cut_off = [];
end
%% Plot SEC data as an array
[C,sel] = select_data(L,DataStructure,1); % run selection function
clearvars L DataStructure
for i = 1:size(C.Blocks,1)
    [fig,pat,ax,xc,yc] = create_array_fig(C.Probe_Flip(i));
    hold on
    reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
        24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
        60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels
    id = reArr(1:32) - 1; % actual channel titles
    id = [id;id];
    txt_id = compose('Ch%03d',id);
    txt_id2 = compose('Ch_%03d',id);
    txt = text(xc,yc,txt_id,'Interpreter','none');
    title = text(5,7,char(C.Blocks(i)),'Interpreter','none','FontSize',18); % not sure why title call is not working
    if C.Probe_Flip(i) == 1 % flip arrays
        text(10,6.5,'P1','FontSize',14);
        text(3,6.5,'P2','FontSize',14);
    else
        text(3,6.5,'P1','FontSize',14);
        text(10,6.5,'P2','FontSize',14);
    end
    % gets table of channels stats
    [chPlot] = channel_stats(C,i,reArr,txt_id,txt_id2);
    % assign patch colors based on latency
    pat.FaceColor = 'flat';
    switch plot
        case 'lat'
            if ~isempty(cut_off)
                cond = sum(chPlot.blank_win > cut_off);
                if cond > 0
                    f = find(chPlot.blank_win > 0.8);
                    chPlot.pk_latency(f) = 0;
                end
            end
            pat.FaceVertexCData = chPlot.pk_latency;
        case 'amp'
            if ~isempty(cut_off)
                cond = sum(chPlot.blank_win > cut_off);
                if cond > 0
                    f = find(chPlot.blank_win > 0.8);
                    chPlot.pk_rate(f) = 0;
                end
            end
            pat.FaceVertexCData = chPlot.pk_rate;
    end
    [cmap,bound] = set_colormap(low_lim,up_lim,mid,cut_off); 
    colormap(cmap);
    colorbar;
    caxis(bound);
    % id stim channel and label
    idxP = C.Stim_Probe(i);
    idxCh = C.Stim_Ch(i);
    if idxP == 1
        pr_list = [1:32];
        stCh = pr_list(idxCh);
    elseif idxP == 2
        pr_list = [33:64];
        stCh = pr_list(idxCh);
    end
    iCh = find(reArr == stCh);
    tStim = text(xc(iCh),yc(iCh),'X','Fontweight','bold','Fontsize',32);
    % filtering steps
end
%% Plot using dot plots for both latency and strength
%% Plot against map data 
% need to have run match_assays.m prior to this
%% Make sure to match orientation
% if ~exist('I.Properties.CustomProperties')
%     disp('Add map orientation!')
%     return
% end
% 
% if ~exist('I.Properties.CustomProperties.mapOrientation')
%     disp('Add map orientation!')
%     return
% end

% I = addprop(I,{'AnimalID','mapOrientation','Impedances'},{'table','table','table'});
% I.Properties.CustomProperties.AnimalID = ''; % set rat surgical name
% I.Properties.CustomProperties.mapOrientation = ''; % set to L or R depending on which array 1 corresponds to on maps
% I.Properties.CustomProperties.Impedances = ''; % enter file location of impT here

%% Create reference of evoked movements
%% Run processing as normal with an additional layer of sorting by ID 