%% Make colormap for z-scored heatmaps
function [cm,bins] = set_parula(thresh,up_lim,low_lim,stops)
% creates a colormap similar to 'hot' to correspond to changes in significant z-scores
%
% INPUT: 
% thresh; z-score value above/below is considered modulated
% up_lim; cutoff for color changes
% low_lim; cutoff for color changes
% stops; structure for setting points for color change
%
% OUTPUT:
% cm; custom colormap

if isfield(stops,'teal')
    st = stops.teal;
else
    st = 0;
end
if isfield(stops,'green')
    sg = stops.green;
else
    sg = thresh;
end
if isfield(stops,'gold')
    sd = stops.gold;
else
    sd = 5;
end
if isfield(stops,'yellow')
    sy = stops.yellow;
else
    sy = up_lim;
end

bins = low_lim:0.01:up_lim;
np = size(bins,2);
cm = zeros(np,3);

% set blue low values
cm(1,:) = [0.2422 0.1504 0.6603];

% transition to teal
tealR = size(low_lim:0.01:st,2);
tealV{1} = linspace(0.2422,0,tealR)';
tealV{2} = linspace(0.1504,0.7248,tealR)';
tealV{3} = [linspace(0.6603,1,floor(tealR/2)), linspace(1,0.7815,ceil(tealR/2))]';
idxT = bins >= low_lim & bins <= st;
cm(idxT',1) = tealV{1};
cm(idxT',2) = tealV{2};
cm(idxT',3) = tealV{3};

% transition to green
greenR = size(0:0.01:sg,2);
greenV{1} = linspace(0,0.405,greenR)';
greenV{2} = linspace(0.7248,0.8031,greenR)';
greenV{3} = linspace(0.7815,0.4233,greenR)';
idxG = bins >= 0 & bins <= sg;
cm(idxG',1) = greenV{1};
cm(idxG',2) = greenV{2};
cm(idxG',3) = greenV{3};

% transition to gold 
goldR = size(sg:0.01:sd,2);
goldV{1} = linspace(0.405,1,goldR)';
goldV{2} = linspace(0.8031,0.7569,goldR)';
goldV{3} = linspace(0.4233,0.2267,goldR)';
idxD = bins >= sg & bins <= sd;
cm(idxD',1) = goldV{1};
cm(idxD',2) = goldV{2};
cm(idxD',3) = goldV{3};

% transition to yellow
yellowR = size(sd:0.01:sy,2);
yellowV{1} = ones(yellowR,1)';
yellowV{2} = linspace(0.7569,1,yellowR)';
yellowV{3} = linspace(0.2267,0,yellowR)';
idxY = bins >= sd & bins <= sy;
cm(idxY',1) = yellowV{1};
cm(idxY',2) = yellowV{2};
cm(idxY',3) = yellowV{3};