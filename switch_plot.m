%% Create GUI for figure selection
function [dir,blockid,fig,g,ax,d,bb,StimOffsets] = switch_plot(dir,blockid,num_p,StimOffsets)

% INPUT:
% dir; file directory
% blockid; recording block name
% num_p, number of data panels to plot
% stimOffsets; stim offset times in samples
%
% OUTPUT:
% dir; file directory
% blockid; recording block name
% fig; figure handle
% g; ui parent handle
% ax; a cell array of axes handle
% d; a cell array of uidropdown handles
% bb; ui button handle
% stimOffsets; stim offset times in samples

% generate figure
fig = uifigure('Name',blockid);
g = uigridlayout(fig);
r = [repmat("1x",1,num_p) 'fit'];
g.RowHeight = r;
g.ColumnWidth = {'fit','fit','fit','fit','fit','1x'};

d{1} = uidropdown(g,...
    "Items",["","P1","P2"], ...
    "ItemsData",["","P1","P2"],"Tag","Probe");
d{1}.Layout.Row = num_p+1;
d{1}.Layout.Column = 1;

d{2} = uidropdown(g,...
    "Items",["" compose('Ch%03d',0:31)], ...
    "ItemsData",["" compose('%03d',0:31)],"Tag","Channel");
d{2}.Layout.Row = num_p+1;
d{2}.Layout.Column = 2;

d{3} = uidropdown(g, ...
    "Items",["","Raw","Artifact","Cleaned","Filtered","Spikes","Mean Rate"], ...
    "ItemsData",["","raw","art","clean","filt","sp","mfr"],"Tag","Type");
d{3}.Layout.Row = num_p+1;
d{3}.Layout.Column = 3;

% load associated stimulation file
if nargin < 4
    load(fullfile(dir,[blockid '_StimTimes.mat']));
end

bb = uibutton(g, ...
    "Text","Generate Trial","ButtonPushedFcn",@(src,event) updateTrial(src,StimOffsets));

tot = numel(StimOffsets);
idx = randperm(tot,1);
bb.Tag = sprintf('%8.0f', StimOffsets(idx));

l = uieditfield(g,"numeric", ...
        "ValueChangedFcn",@(l,event) textChanged(l,bb));

for i = 1:num_p
    ax{i} = uiaxes(g);
    ax{i}.Layout.Row = i;
    ax{i}.Layout.Column = [2 6];
    ax{i}.Title.String = bb.Tag;
    ax{i}.TitleHorizontalAlignment = 'left';
    b{i} = uibutton(g,"Text","Plot","ButtonPushedFcn",@(src,event) updatePlot(dir,blockid,ax{i},d,bb));
    b{i}.Layout.Row = i;
    b{i}.Layout.Column = 1;
    b{i}.HorizontalAlignment = 'center';

end

end

function updatePlot(dir,blockid,ax,d,bb)
probe = char(d{1}.Value);
channel = char(d{2}.Value);
type = d{3}.Value;
stim_trial = str2num(bb.Tag);
switch type
    case 'raw'
        ff = fullfile(dir,[blockid '_RawData'],[blockid '_Raw_' probe '_Ch_' channel]);
        load(ff,"data");
        % data(stim_trial:stim_trial+15) = 0; % just helps for scaling
        plot(ax,linspace(0,10,301),data(stim_trial:stim_trial+300),"Color","#000");
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 10];
    case 'art'
        load(fullfile(dir,[blockid '_RawData'],[blockid '_Raw_' probe '_Ch_' channel]),'data');
        raw = data;
        load(fullfile(dir,[blockid '_RawData_StimSmoothed'],[blockid '_Raw_StimSmoothed_' probe '_Ch_' channel]),'data');
        clean = data;
        data = raw - clean;
        plot(ax,linspace(0,10,301),data(stim_trial:stim_trial+300),"Color","#000");
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 10];
    case 'clean'
        ff = fullfile(dir,[blockid '_RawData_StimSmoothed'],[blockid '_Raw_StimSmoothed_' probe '_Ch_' channel]);
        load(ff,"data");
        plot(ax,linspace(0,10,301),data(stim_trial:stim_trial+300),"Color","#000");
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 10];
    case 'filt'
        ff = fullfile(dir,[blockid '_Filtered_StimSmoothed'],[blockid '_Filt_' probe '_Ch_' channel]);
        load(ff,"data");
        plot(ax,linspace(0,10,301),data(stim_trial:stim_trial+300),"Color","#000");
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 10];
    case 'sp'
        ff = fullfile(dir,[blockid '_TC-neg3.5_ThreshCross'],[blockid '_ptrain_' probe '_Ch_' channel]);
        load(ff,"peak_train");
        output = peak_train;
        output = find(output(stim_trial:stim_trial+300));
        cla(ax);
        if output > 0
            xline(ax,output,"Color","#000");
        end
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 300];
        ax.XTick = linspace(0,300,11);
        ax.XTickLabel = 0:10;
    case 'mfr'
        ff = fullfile(dir,[blockid '_StimTriggeredStats_ChannelSpiking_RandomBlanked'],[blockid '_ChannelStats_' probe '_Ch' channel]);
        load(ff,"MeanSpikeRate");
        output = MeanSpikeRate;
        plot(ax,linspace(0,10,101),output(1:101),"Color","#000");
        ax.Title.String = sprintf('%8.0f', stim_trial);
        ax.XLim = [0 10];
end
end

function updateTrial(src,StimOffsets)
tot = numel(StimOffsets);
idx = randperm(tot,1);
src.Tag = string(StimOffsets(idx));
end

function textChanged(l,bb)
bb.Tag = string(l.Value);
end
