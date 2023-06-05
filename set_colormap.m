%% Map colors for a colormap
function [cmap] = set_colormap(low_lim,up_lim,mid)
% sets a colormap based on the lower - upper limits of the data
% can adjust the relative color change using mid
% uses red/yellow/green scale for one midpoint
% adds blue to end of scale for two midpoints
%
% INPUT: 
% low_lim; a numeric value for the red point
% up_lim; a numeric value for the green point
% mid; single for the mid-way yellow point 
%
% OUTPUT:
% cmap; a color map

range = linspace(low_lim,up_lim,50);
if ~exist('mid')
    mid = 25;
end
if numel(mid) == 1
    [~,match] = min(abs(range - mid));
    cmap = zeros(50,3);
    cmap(1,:) = [1 0 0];
    cmap(match,:) = [1 1 0];
    cmap(end,:) = [0 1 0];
    before = match;
    cB = linspace(0,1,before);
    after = 50 - match;
    cA = flip(linspace(0,1,after + 1));
    for i = 2:(before - 1)
        cmap(i,:) = [1 cB(i) 0];
    end
    for i = 2:after
        fill = match + i - 1;
        cmap(fill,:) = [cA(i) 1 0];
    end
elseif numel(mid) == 2
    [~,match1] = min(abs(range - mid(1)));
    [~,match2] = min(abs(range - mid(2)));
    cmap = zeros(50,3);
    cmap(1,:) = [1 0 0];
    cmap(match1,:) = [1 1 0];
    cmap(match2,:) = [0 1 0];
    cmap(end,:) = [0 0 1];
    before = match1;
    cB = linspace(0,1,before);
    middle = match2 - match1;
    cM = flip(linspace(0,1,middle + 1));
    after = 50 - match2;
    cA2 = linspace(0,1,after + 1);
    cA1 = flip(cA2);
    for i = 2:(before - 1)
        cmap(i,:) = [1 cB(i) 0];
    end
    for i = 2:middle
        fill = match1 + i - 1;
        cmap(fill,:) = [cM(i) 1 0];
    end
    for i = 2:after
        fill = match2 + i - 1;
        cmap(fill,:) = [0 cA1(i) cA2(i)];
    end
end