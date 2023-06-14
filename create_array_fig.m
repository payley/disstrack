%% Creates an array schematic for plotting figures
function [fig,p,ax,xc,yc,add] = create_array_fig(type,flip,color,size)
% patch graphic for two custom 32ch arrays
%
% INPUT: 
% type; case argument for plotting either patches or circles
% flip; indicates that the arrays are flipped from the default so that rRFA is P1 and lRFA is P2 
% color; either a single value for all objects or a 64x1 array organized in order of each object 
% size; a 64x1 array for scaling scatterpoints in circle plot
%
% OUTPUT:
% fig; figure handle
% p; patch handle
% ax; axes handle
% xc; x-coordinates for channel labels
% yc; y-coordinates for channel labels
% add; additional plotted point for stim channel

switch type
    case 'circ'
        % set coordinates 
        x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
            8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
        y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
            6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1]';
        if flip == 1 % switch order of plot depending on flip
            x1 = [x1(33:64),x1(1:32)];
        end
        % set colors
        if exist('color','var')
            c = color;
        else
            c = 'w';
        end
        x1 = x1';        
        fig = figure('Position',[0, 0, 1200, 800]);
        ax = gca;
        hold(ax,'on')
        % plot scatter points
        p = scatter(x1,y1,size,c,'filled');
        add = scatter(0,0,100,'w','filled','MarkerEdgeColor',[0,0,0],'LineWidth',1);
        ax.XColor = 'none';
        ax.YColor = 'none';
        xlim(ax,[-1 13.5]);
        ylim(ax,[-0.5 9]);
        xc = x1;
        yc = y1;
    case 'patch'
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
        if exist('color','var')
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
end

