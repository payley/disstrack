%% Load files and set variables
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

% set variables for color mapping
low_lim = 0.8;
up_lim = 20;
mid = 4;
cut_off = []; % set to low_lim or up_lim if values should be grayed out
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
    txt = text(xc,yc,txt_id,'Interpreter','none');
    title = text(5,7,char(C.Blocks(i)),'Interpreter','none','FontSize',18); % not sure why title call is not working
    if C.Probe_Flip(i) == 1 % flip arrays
        text(10,6.5,'P1','FontSize',14);
        text(3,6.5,'P2','FontSize',14);
    else
        text(3,6.5,'P1','FontSize',14);
        text(10,6.5,'P2','FontSize',14);
    end
    arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
    pk_latency = zeros(64,1);
    pk_rate = zeros(64,1);
    rand_sig = zeros(64,1);
    mean_rate = cell(64,1);
    chPlot = table(arr,txt_id,reArr,pk_latency,pk_rate,rand_sig,mean_rate,...
        'VariableNames',{'arr','ch','ch_ref','pk_latency','pk_rate','rand_sig','mean_rate'});
    if ~exist(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']))
        for ii = 1:numel(reArr) % channels in order of plotting P1 to P2
            chID = txt_id{ii};
            r = reArr(ii);
            if r <= 32 
                load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                    [char(C.Blocks(i)),'_ChannelStats_P1_',chID,'.mat']));
            else
                load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                    [char(C.Blocks(i)),'_ChannelStats_P2_',chID,'.mat']));
            end
            chPlot.pk_latency(ii) = Latency_ms;
            chPlot.pk_rate(ii) = MaxSpikeRate;
            if isempty(p) % work around for now
                chPlot.rand_sig(ii) = 1;
            else
            chPlot.rand_sig(ii) = p;
            end
            chPlot.mean_rate{ii} = MeanSpikeRate;
        end
        save(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']),'chPlot');
    else
        load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']),'chPlot');
    end
    % assign patch colors based on latency
    pat.FaceColor = 'flat';
    pat.FaceVertexCData = chPlot.pk_latency;
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
    
end
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