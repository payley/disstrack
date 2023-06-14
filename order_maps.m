%% Rearranges map data in plotting order
function [nI] = order_maps(I,resp)
% organizes map data from two 32 channel custom arrays based on array 
% location and respective channel arrangement 
%
% INPUT: 
% I; table of map data input in order of breakout box site stimulation
% resp; a variable indicating the use of multiple ICMS-evoked responses
% or just the major response (1 is primary response only, 2 would be
% multiple)
%
% OUTPUT:
% nI; table of map data input in order of spatial organization

%% Set-up variables
reArr = [13 14 15 16 7 8 9 10 11 12 1 2 3 4 5 6 22 21 20 19 18 17 28 27 26 25 24 23 32 31 30 29 ...
    45 46 47 48 39 40 41 42 43 44 33 34 35 36 37 38 54 53 52 51 50 49 60 59 58 57 56 55 64 63 62 61]; % specific to certain arrays??????????????
%% Reorient probes so that left is listed first
if I.Properties.CustomProperties.mapOrientation == 'R'
    I = [I(65:128,:) I(1:64,:)];
end
%% Reorder channels according to the electrode layout
for i = 1:64
    ref = reArr(i); % uses the key above for the index
    idx = (ref)+(ref-1); % indexes the first map response 
    idx2 = 2*ref; % indexes the second map response 
    fin = (i)+(i-1);  % orders the first response
    fin2 = 2*i; % orders the second response
    nI(fin,:) = I(idx,:); % creates a new table with the first and second responses in the order that they will get plotted  
    nI(fin2,:) = I(idx2,:);
end
%% Conditionally remove secondary responses
if resp == 1
  nI(2:2:end,:) = [];
elseif resp ~= 2
  disp('Not a valid input.')
  return
end
%% Assign old properties/metadata to new table
nI.Properties = I.Properties;