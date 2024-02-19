%% Make colormap for z-scored heatmaps
function [cm,bins] = set_colors(thresh,up_lim,low_lim,stops)
% creates a colormap similar to 'hot' to correspond to changes in significant z-scores
%
% INPUT: 
% thresh; z-score value above/below is considered modulated
% up_lim; cutoff for color changes
% low_lim; cutoff for color changes
% stops; optional structure for setting points for color change
%
% OUTPUT:
% cm; custom colormap

if exist('stops','var')
    if isfield(stops,'red')
        sr = stops.red;
    else
        sr = 0;
    end
    if isfield(stops,'orange')
        so = stops.orange;
    else
        so = thresh;
    end
    if isfield(stops,'yellow')
        sy = stops.yellow;
    else
        sy = 5;
    end
    if isfield(stops,'white')
        sw = stops.white;
    else
        sw = up_lim;
    end
    bins = low_lim:0.01:up_lim;
    np = size(bins,2);
    cm = zeros(np,3);
    cm(:,1) = 1;
    redR = size(low_lim:0.01:sr,2);
    redV = linspace(0,1,redR)';
    idxR = bins >= low_lim & bins <= sr;
    cm(idxR,1) = redV;
    orangeR = size(0:0.01:so,2);
    orangeV = linspace(0,0.5,orangeR)';
    idxO = bins >= 0 & bins <= so;
    cm(idxO,1) = 1;
    cm(idxO,2) = orangeV;
    yellowR = size(so:0.01:sy,2);
    yellowV = linspace(0.5,1,yellowR)';
    idxY = bins >= so & bins <= sy;
    cm(idxY,1) = 1;
    cm(idxY,2) = yellowV;
    whiteR = size(sy:0.01:sw,2);
    whiteV = linspace(0,1,whiteR)';
    idxW = bins >= sy & bins <= sw;
    cm(idxW,1) = 1;
    cm(idxW,2) = 1;
    cm(idxW,3) = whiteV;
else
    bins = low_lim:0.01:up_lim;
    np = size(bins,2);
    cm = zeros(np,3);
    redR = size(low_lim:0.01:0,2);
    redV = linspace(0,1,redR)';
    idxR = bins >= low_lim & bins <= 0;
    cm(idxR,1) = redV;
    orangeR = size(0:0.01:thresh,2);
    orangeV = linspace(0,0.5,orangeR-1)';
    idxO = bins >= 0 & bins <= thresh;
    cm(idxO,1) = 1;
    cm(idxO,2) = orangeV;
    yellowR = size(thresh:0.01:5,2);
    yellowV = linspace(0.5,1,yellowR)';
    idxY = bins >= thresh & bins <= 5;
    cm(idxY,1) = 1;
    cm(idxY,2) = yellowV;
    whiteR = size(5:0.01:up_lim,2);
    whiteV = linspace(0,1,whiteR)';
    idxW = bins >= 5 & bins <= up_lim;
    cm(idxW,1) = 1;
    cm(idxW,2) = 1;
    cm(idxW,3) = whiteV;
end