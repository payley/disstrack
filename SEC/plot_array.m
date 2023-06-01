%% Set coordinates for array plots
% need to have run match_assays.m prior to this
x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
    8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
x2 = x1 + 1;
x3 = x2;
x4 = x1;
y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
    6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1];
y2 = y1;
y3 = y2 - 1;
y4 = y3;
xc = x1 + 0.25; % add value to shift left
yc = y1 - 0.5;
xAll = [x1; x2; x3; x4];
yAll = [y1; y2; y3; y4];
clearvars -except xc yc xAll yAll
%% Match array schematics
% just a test
reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 24 25 26 17 18 19 20 ...
    36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 60 61 62 63 64 53 54 55 56 57 58 49 50 51 52];
txt_reArr = cellstr(string(reArr));
figure;
patch(xAll,yAll,'w');
text(xc,yc,txt_reArr);
%% Plot SEC data as an array

%% Plot against map data 
%% Make sure to match orientation
if ~exist('I.Properties.CustomProperties')
print('Add map orientation!')
return
end

if ~exist('I.Properties.CustomProperties.mapOrientation')
print('Add map orientation!')
return
end

% I = addprop(I,{'AnimalID','mapOrientation','Impedances'},{'table','table','table'});
% I.Properties.CustomProperties.AnimalID = ''; % set rat surgical name
% I.Properties.CustomProperties.mapOrientation = ''; % set to L or R depending on which array 1 corresponds to on maps
% I.Properties.CustomProperties.Impedances = ''; % enter file location of impT here

%% Create reference of evoked movements
%% Match recordings to map days
%% Run processing as normal with an additional layer of sorting by ID 