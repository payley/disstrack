%% Map colors for a colormap
function [cmap,bound] = set_colormap(low_lim,up_lim,mid,cut_off)
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
% cmap; a colormap
% bound; values for scaling caxis, usually low_lim/up_lim unless cut-off is indicated

% values for creating a colormap
res = 50; % sets the number of values between the main shades
range = linspace(low_lim,up_lim,res);
if isempty(mid)
    mid = 25;
end

% fills colormap variable
if numel(mid) == 1
    [~,match] = min(abs(range - mid));
    cmap = zeros(res,3);
    cmap(1,:) = [1 0 0];
    cmap(match,:) = [1 1 0];
    cmap(end,:) = [0 1 0];
    before = match;
    cB = linspace(0,1,before);
    after = res - match;
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
    cmap = zeros(res,3);
    cmap(1,:) = [1 0 0];
    cmap(match1,:) = [1 1 0];
    cmap(match2,:) = [0 1 0];
    cmap(end,:) = [0 0 1];
    before = match1;
    cB = linspace(0,1,before);
    middle = match2 - match1;
    cM = flip(linspace(0,1,middle + 1));
    after = res - match2;
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
if isempty(cut_off)
        bound = [low_lim up_lim];
% adds a color to gray out values above/below a cut-off
else
    if cut_off == low_lim
        cmap = [0 0 0; cmap];
        hold = low_lim - ((low_lim + up_lim)/res);
        bound = [hold up_lim];
    elseif cut_off == up_lim
        cmap = [cmap; 0 0 0];
        hold = up_lim + ((low_lim + up_lim)/res); 
        bound = [low_lim hold];
    end
end