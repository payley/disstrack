%% Create GUI for spike rasters for different channels
function [dir,blockid,fig,g,ax,d] = plot_trial_rasters(dir,blockid)

% INPUT:
% dir; file directory
% blockid; recording block name
%
% OUTPUT:
% dir; file directory
% blockid; recording block name
% fig; figure handle
% g; ui parent handle
% ax; a cell array of axes handle
% d; a cell array of uidropdown handles

% generate figure
fig = uifigure('Name',blockid);
g = uigridlayout(fig);
g.RowHeight = {'1x','fit'};
g.ColumnWidth = {'fit','fit','fit','1x'};

d{1} = uidropdown(g,...
    "Items",["","P1","P2"], ...
    "ItemsData",["","P1","P2"],"Tag","Probe");
d{1}.Layout.Row = 2;
d{1}.Layout.Column = 1;

d{2} = uidropdown(g,...
    "Items",["" compose('Ch%03d',0:31)], ...
    "ItemsData",["" compose('Ch%03d',0:31)],"Tag","Channel");
d{2}.Layout.Row = 2;
d{2}.Layout.Column = 2;

ax = uiaxes(g);
ax.Layout.Row = 1;
ax.Layout.Column = [2 4];
ax.TitleHorizontalAlignment = 'left';
b = uibutton(g,"Text","Plot","ButtonPushedFcn",@(src,event) updatePlot(dir,blockid,ax,d));
b.Layout.Row = 1;
b.Layout.Column = 1;
b.HorizontalAlignment = 'center';

end

function updatePlot(dir,blockid,ax,d)
cla(ax);
probe = char(d{1}.Value);
channel = char(d{2}.Value);
load(fullfile(dir,[blockid '_refstats.mat']),'chPlot');
idx = strcmp(chPlot.arr,probe) & strcmp(chPlot.ch,channel); 
LineFormat = struct();
LineFormat.LineWidth = 1;
data = logical(chPlot.trials{idx});
plotSpikeRaster(data,'PlotType','vertline','LineFormat',LineFormat);
f = gcf;
ax2 = gca;
copyobj(ax2.Children,ax);
close(f)
% ax.XLim = [0 300];
% ax.XTick = linspace(0,300,11);
% ax.XTickLabel = 0:10;
ax.YLim = [0 1000];
ax.Title.String = sprintf("%s %s",probe,channel);
end