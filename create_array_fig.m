%% Creates an array schematic for plotting figures
function [fig,p,ax,xc,yc] = create_array_fig(flip,color)
% patch graphic for two custom 32ch arrays
%
% INPUT: 
% color; either a single value for all patches or a 64x1 array organized by patch 
% flip; indicates that the arrays are flipped from the default so that rRFA is P1 and lRFA is P2 
% OUTPUT:
% fig; figure handle
% p; patch handle
% ax; axes handle
% xc; x-coordinates for channel labels
% yc; y-coordinates for channel labels

% set coordinates
x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
    8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
    6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1];
if flip == 1 % switch order of plot depending on flip
    x1 = [x1(33:64),x1(1:32)];
end
x2 = x1 + 1;
x3 = x2;
x4 = x1;
y2 = y1;
y3 = y2 - 1;
y4 = y3;
xc = x1 + 0.25; % add value to shift left
yc = y1 - 0.5;
xAll = [x1; x2; x3; x4];
yAll = [y1; y2; y3; y4];

% set color values of patches
if exist('color')
    c = color;
else
    c = 'w';
end

fig = figure;
ax = axes('Position',[0 0 1 1],'xtick',[],'ytick',[],'box','on','XColor','none','YColor','none');
ylim(ax,[-1.5,7.5]); % adds borders to plot
xlim(ax,[-1.5,14.5]); 
% plot patches
p = patch(xAll,yAll,c);
