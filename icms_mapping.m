%% Set up table
% channels = [1;1;2;2;3;3;4;4;5;5;6;6;7;7;8;8;9;9;10;10;11;11;12;12;13;13;14;14;15;15;16;16;17;17;18;18;19;19;20;20;21;21;22;22;23;23;24;24;25;25;26;26;27;27;28;28;29;29;30;30;31;31;32;32;1;1;2;2;3;3;4;4;5;5;6;6;7;7;8;8;9;9;10;10;11;11;12;12;13;13;14;14;15;15;16;16;17;17;18;18;19;19;20;20;21;21;22;22;23;23;24;24;25;25;26;26;27;27;28;28;29;29;30;30;31;31;32;32];
% map_date = [1:size(channels,1)]';
% thresh_date = [1:size(channels,1)]';
% array = zeros(128,1);
% array(1:64) = 1;
% array(65:128) = 2;
% I = table(channels,array,map_date,thresh_date);
% I = addprop(I,{'AnimalID','mapOrientation','Impedances'},{'table','table','table'});
% I.Properties.CustomProperties.AnimalID = ''; % set rat surgical name
% I.Properties.CustomProperties.mapOrientation = ''; % set to L or R depending on which array 1 corresponds to on maps
% I.Properties.CustomProperties.Impedances = ''; % enter file location of impT here

% input map values in table I now. There are two values for each channel so
% that you can demarcate mixed sites. If a single joint/response is noted
% duplicate. The first 32 channels are for one array and the next 32
% channels should be used for the second.
% key for movements evoked: 0=NR;1=dFl;2=pFl;3=trunk/neck;4=face;5=whiskers

%% Run basic motor map with secondary movements
clearvars nI
% set patch points
x1 = [1 2 2 3 3 4 4 5 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 ...
    1 1 2 2 3 3 4 4 5 5 6 1 2 2 3 3 4 4 5 8 9 9 10 10 11 11 12 7 8 8 9 9 10 10 11 11 12 12 13 7 8 ...
    8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 ...
    8 9 9 10 10 11 11 12];
x2 = [2 2 3 3 4 4 5 5 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 ...
    1 1 2 2 3 3 4 4 5 5 6 6 2 2 3 3 4 4 5 5 9 9 10 10 11 11 12 12 8 8 9 9 10 10 11 11 12 12 13 13 8 ...
    8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 ...
    9 9 10 10 11 11 12 12];
x3 = x2 - 1;
y1 = [6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 ...
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 ...
    4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1];
y2 = [6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 ...
    2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 ...
    4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 ];
y3 = y1 - 1;
xAll = [x1; x2; x3];
yAll = [y1; y2; y3];

% set colors for map
% 0=NR;1=dFl;2=pFl;3=trunk/neck;4=face;5=whiskers
colors = [0 0 0;
    0.6350 0.0780 0.1840;
    0.8500 0.3250 0.0980;
    0.4940 0.1840 0.5560;
    0.3010 0.7450 0.9330;
    0 0.4470 0.7410];

% rearrange values to match array design starting with the corner closest
% to the reference electrode

% reArr = [9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 8 7 6 5 4 3 2 1 ...
%     32 31 30 29 28 27 26 25 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 40 39 ...
%     38 37 36 35 34 33 64 63 62 61 60 59 58 57];   % ref for R20-98 and
%     R20-99

% reArr = [32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,...
%     10,9,8,7,6,5,4,3,2,1,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,...
%     46,45,44,43,42,41,40,39,38,37,36,35,34,33];   % ref for R21-09 and R21-10

reArr = [13 14 15 16 7 8 9 10 11 12 1 2 3 4 5 6 22 21 20 19 18 17 28 27 26 25 24 23 32 31 30 29 ...
    45 46 47 48 39 40 41 42 43 44 33 34 35 36 37 38 54 53 52 51 50 49 60 59 58 57 56 55 64 63 62 61]; % for all Microprobes arrays

for i = 1:64
    ref = reArr(i); % uses the key above for the index
    idx = (ref)+(ref-1); % indexes the first map response 
    idx2 = 2*ref; % indexes the second map response 
    fin = (i)+(i-1);  % orders the first response
    fin2 = 2*i; % orders the second response
    nI(fin,:) = I(idx,:); % creates a new table with the first and second responses in the order that they will get plotted  
    nI(fin2,:) = I(idx2,:);
end
nI.Properties = I.Properties;

% switch arrays to plot left then right RFA
if nI.Properties.CustomProperties.mapOrientation == 'R'
    st = nI;
    st(1:64,:) = nI(65:128,:);
    st(65:128,:) = nI(1:64,:);
    nI = st;
    if nI.array(1) == 1
        return
    end
end

% plot icms maps
sz = (size(nI,2) - 1)/2; % number of maps
h = zeros(size(nI,1),1); % temporary cell array to hold transparency value
mapID = find(contains(nI.Properties.VariableNames,'map')); % indices of maps
for i = 1:sz
    mvmt = mapID(i);
    c = table2array(nI(:,mvmt));
    fc = c';
    figure('Position', [10 10 1000 475]);
    p = patch(xAll,yAll,fc,'LineStyle','none');
    set(gca,'XColor','none','YColor','none')
    str = nI.Properties.VariableNames(mvmt);
    dt = extractAfter(str,'map_'); % get dates for impedance tests
    dt = string(datetime(dt,'InputFormat','yyyy_MM_dd','Format','MM/dd/yyyy'));
    txt = '%s Map %d %s';
    title(sprintf(txt,I.Properties.Description,i,dt));
    colormap(colors);
    caxis ([0 6]);
    colorbar('Ticks',[0.5,1.5,2.5,3.5,4.5,5.5],...
        'TickLabels',{'No Response','Distal Forelimb','Proximal Forelimb','Trunk/Neck','Face','Vibrissa'})
end

clearvars -except I impT nI
%% Run square movement map with thresholds
clearvars nI
% set patch points
x1 = [1 2 2 3 3 4 4 5 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 ...
    1 1 2 2 3 3 4 4 5 5 6 1 2 2 3 3 4 4 5 8 9 9 10 10 11 11 12 7 8 8 9 9 10 10 11 11 12 12 13 7 8 ...
    8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 ...
    8 9 9 10 10 11 11 12];
x2 = [2 2 3 3 4 4 5 5 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 ...
    1 1 2 2 3 3 4 4 5 5 6 6 2 2 3 3 4 4 5 5 9 9 10 10 11 11 12 12 8 8 9 9 10 10 11 11 12 12 13 13 8 ...
    8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 ...
    9 9 10 10 11 11 12 12];
x3 = x2 - 1;
y1 = [6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 ...
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 ...
    4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1];
y2 = [6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 ...
    2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 ...
    4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 ];
y3 = y1 - 1;
xAll = [x1; x2; x3];
yAll = [y1; y2; y3];

% set colors for map
% 0=NR;1=dFl;2=pFl;3=trunk/neck;4=face;5=whiskers
colors = [0 0 0;
    0.6350 0.0780 0.1840;
    0.8500 0.3250 0.0980;
    0.4940 0.1840 0.5560;
    0.3010 0.7450 0.9330;
    0 0.4470 0.7410];

% rearrange values to match array design starting with the corner closest
% to the reference electrode

% reArr = [9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 8 7 6 5 4 3 2 1 ...
%     32 31 30 29 28 27 26 25 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 40 39 ...
%     38 37 36 35 34 33 64 63 62 61 60 59 58 57];   % ref for R20-98 and
%     R20-99

% reArr = [32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,...
%     10,9,8,7,6,5,4,3,2,1,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,...
%     46,45,44,43,42,41,40,39,38,37,36,35,34,33];   % ref for R21-09 and R21-10

reArr = [13 14 15 16 7 8 9 10 11 12 1 2 3 4 5 6 22 21 20 19 18 17 28 27 26 25 24 23 32 31 30 29 ...
    45 46 47 48 39 40 41 42 43 44 33 34 35 36 37 38 54 53 52 51 50 49 60 59 58 57 56 55 64 63 62 61]; % for all Microprobes arrays

for i = 1:64
    ref = reArr(i); % uses the key above for the index
    idx = (ref)+(ref-1); % indexes the first map response 
    idx2 = 2*ref; % indexes the second map response 
    fin = (i)+(i-1);  % orders the first response
    fin2 = 2*i; % orders the second response
    nI(fin,:) = I(idx,:); % creates a new table with the first and second responses in the order that they will get plotted  
    nI(fin2,:) = I(idx2,:);
end
nI.Properties = I.Properties;

% switch arrays to plot left then right RFA
if nI.Properties.CustomProperties.mapOrientation == 'R'
    st = nI;
    st(1:64,:) = nI(65:128,:);
    st(65:128,:) = nI(1:64,:);
    nI = st;
    if nI.array(1) == 1
        return
    end
end

% plot icms maps
sz = (size(nI,2) - 1)/2; % number of maps
h = zeros(size(nI,1),1); % temporary cell array to hold transparency value
mapID = find(contains(nI.Properties.VariableNames,'map')); % indices of maps
thrID = find(contains(nI.Properties.VariableNames,'thresh')); % indices of threshold variables 
for i = 1:sz
    mvmt = mapID(i);
    thresh = thrID(i);
    % assign transparency for icms threshold
    idx = nI{:,thresh} == 80;
    nI{idx,thresh} = 0.4;
    idx = nI{:,thresh} > 60;
    nI{idx,thresh} = 0.55;
    idx = nI{:,thresh} > 40;
    nI{idx,thresh} = 0.7;
    idx = nI{:,thresh} > 20;
    nI{idx,thresh} = 0.85;
    idx = nI{:,thresh} > 1;
    nI{idx,thresh} = 1;
    c = table2array(nI(:,mvmt));
    fc = c';
    figure('Position', [10 10 1000 475]);
    p = patch(xAll,yAll,fc,'FaceAlpha','flat','FaceVertexAlphaData',nI{:,thresh}, ...
        'AlphaDataMapping','none','LineStyle','none');
    set(gca,'XColor','none','YColor','none')
    str = nI.Properties.VariableNames(mvmt);
    dt = extractAfter(str,'map_'); % get dates for impedance tests
    dt = string(datetime(dt,'InputFormat','yyyy_MM_dd','Format','MM/dd/yyyy'));
    txt = '%s Map %d %s';
    title(sprintf(txt,I.Properties.Description,i,dt));
    colormap(colors);
    caxis ([0 6]);
    colorbar('Ticks',[0.5,1.5,2.5,3.5,4.5,5.5],...
        'TickLabels',{'No Response','Distal Forelimb','Proximal Forelimb','Trunk/Neck','Face','Vibrissa'})
end

clearvars -except I impT nI
%% Run circle movement map with thresholds
clearvars nI nimpT
% set patch points
x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
    8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
x1 = x1 + 0.5;
y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
    6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1];
y1 = y1 - 0.5;
% I([2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62, ...
%     64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126,end],:) = [];

% set colors for map
% 0=NR;1=dFl;2=pFl;3=trunk/neck;4=face;5=whiskers
colors = [0 0 0;
    0.6350 0.0780 0.1840;
    0.8500 0.3250 0.0980;
    0.4940 0.1840 0.5560;
    0.3010 0.7450 0.9330;
    0 0.4470 0.7410];

% rearrange values to match array design
% reArr = [9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 8 7 6 5 4 3 2 1 ...
%     32 31 30 29 28 27 26 25 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 40 39 ...
%     38 37 36 35 34 33 64 63 62 61 60 59 58 57];   % ref for R20-98 and
%     R20-99

% reArr = [32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,...
%     10,9,8,7,6,5,4,3,2,1,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,...
%     46,45,44,43,42,41,40,39,38,37,36,35,34,33];   % ref for R21-09 and R21-10


reArr = [13 14 15 16 7 8 9 10 11 12 1 2 3 4 5 6 22 21 20 19 18 17 28 27 26 25 24 23 32 31 30 29 ...
    45 46 47 48 39 40 41 42 43 44 33 34 35 36 37 38 54 53 52 51 50 49 60 59 58 57 56 55 64 63 62 61];

for i = 1:64
    ref = reArr(i); % uses the key above for the index
    idx = (ref)+(ref-1); % indexes the first map response 
    idx2 = 2*ref; % indexes the second map response 
    fin = (i)+(i-1);  % orders the first response
    fin2 = 2*i; % orders the second response
    nI(fin,:) = I(idx,:); % creates a new table with the first and second responses in the order that they will get plotted  
    nI(fin2,:) = I(idx2,:);
end
nI([2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62, ...
    64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126,end],:) = []; % remove secondary movements
nI.Properties = I.Properties;

% switch arrays to plot left then right RFA
if nI.Properties.CustomProperties.mapOrientation == 'R'
    st = nI;
    st(1:32,:) = nI(33:64,:);
    st(33:64,:) = nI(1:32,:);
    nI = st;
    if nI.array(1) == 1
        return
    end
end

% plot icms maps
sz = (size(nI,2) - 1)/2; % number of maps
mapID = find(contains(nI.Properties.VariableNames,'map')); % indices of maps
thrID = find(contains(nI.Properties.VariableNames,'thresh')); % indices of threshold variables 
for i = 1:sz
    mvmt = mapID(i);
    thresh = thrID(i);
    figure('Position', [10 10 1000 475]);
    scatter(x1,y1);
    hold on
    c = table2array(nI(:,mvmt));
    for ii = 1:size(nI,1)
        idx = (nI{ii,mvmt})+1;
        fill = colors(idx,:); 
        radii = nI{ii,thresh};
        if radii == 80
            radii = 100;
        elseif radii > 60
            radii = 800;
        elseif radii > 40
            radii = 1500;
        elseif radii > 20
            radii = 2200;
        elseif radii > 0
            radii = 2900;
        end
        s = scatter(x1(ii),y1(ii),radii,'MarkerFaceColor',fill,'MarkerEdgeColor',fill);
    end
    set(gca,'XColor','none','YColor','none')
    str = nI.Properties.VariableNames(mvmt);
    dt = extractAfter(str,'map_'); % get dates for impedance tests
    dt = string(datetime(dt,'InputFormat','yyyy_MM_dd','Format','MM/dd/yyyy'));
    txt = '%s Map %d %s';
    title(sprintf(txt,I.Properties.Description,i,dt));
    xlim([-0.5 13.5]);
    ylim([-0.5 6.5]);
    colormap(colors);
    caxis ([0 6]);
    colorbar('Ticks',[0.5,1.5,2.5,3.5,4.5,5.5],...
        'TickLabels',{'No Response','Distal Forelimb','Proximal Forelimb','Trunk/Neck','Face','Vibrissa'})
    set(gcf, 'Position',  [0, 0, 1200, 600])
    hold off
end

clearvars -except I impT nI nimpT impdatmatchRef
%% Run square threshold map with impedances
clearvars nI
load(I.Properties.CustomProperties.Impedances);
% set patch points to be squares rather than triangles
x1 = [1 2 2 3 3 4 4 5 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 1 1 2 2 3 3 4 4 5 5 6 0 ...
    1 1 2 2 3 3 4 4 5 5 6 1 2 2 3 3 4 4 5 8 9 9 10 10 11 11 12 7 8 8 9 9 10 10 11 11 12 12 13 7 8 ...
    8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 7 8 8 9 9 10 10 11 11 12 12 13 ...
    8 9 9 10 10 11 11 12];
x2 = [2 2 3 3 4 4 5 5 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 1 1 2 2 3 3 4 4 5 5 6 6 ...
    1 1 2 2 3 3 4 4 5 5 6 6 2 2 3 3 4 4 5 5 9 9 10 10 11 11 12 12 8 8 9 9 10 10 11 11 12 12 13 13 8 ...
    8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 8 8 9 9 10 10 11 11 12 12 13 13 ...
    9 9 10 10 11 11 12 12];
x1 = x1(1:2:end);  
x4 = x1;
x3 = x2(2:2:end);
x2 = x2(1:2:end); 
y1 = [6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 ...
    2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 6 6 6 6 6 6 6 6 5 5 5 5 5 5 5 5 5 5 5 5 ...
    4 4 4 4 4 4 4 4 4 4 4 4 3 3 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1];
y2 = [6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 ...
    2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 6 5 6 5 6 5 6 5 5 4 5 4 5 4 5 4 5 4 5 4 ...
    4 3 4 3 4 3 4 3 4 3 4 3 3 2 3 2 3 2 3 2 3 2 3 2 2 1 2 1 2 1 2 1 2 1 2 1 1 0 1 0 1 0 1 0 ];
y1 = y1(1:2:end); 
y3 = y2(2:2:end);
y4 = y3;
y2 = y1;
xAll = [x1; x2; x3; x4];
yAll = [y1; y2; y3; y4];

% set colors for map
colors = [0 1 0; 0.1 1 0; 0.2 1 0; 0.3 1 0; 0.4 1 0; 0.5 1 0; 0.6 1 0; 0.7 1 0; 0.8 1 0; 0.9 1 0; ...
    1 1 0; 1 0.9 0; 1 0.8 0; 1 0.7 0; 1 0.6 0; 1 0.5 0; 1 0.4 0; 1 0.3 0; 1 0.2 0; 1 0.1 0; ...
    1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0];

% rearrange values to match array design
% reArr = [9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 8 7 6 5 4 3 2 1 ...
%     32 31 30 29 28 27 26 25 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 40 39 ...
%     38 37 36 35 34 33 64 63 62 61 60 59 58 57];   % ref for R20-98 and
%     R20-99

% reArr = [32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,...
%     10,9,8,7,6,5,4,3,2,1,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,...
%     46,45,44,43,42,41,40,39,38,37,36,35,34,33];   % ref for R21-09 and
%     R21-10

reArr = [13 14 15 16 7 8 9 10 11 12 1 2 3 4 5 6 22 21 20 19 18 17 28 27 26 25 24 23 32 31 30 29 ...
    45 46 47 48 39 40 41 42 43 44 33 34 35 36 37 38 54 53 52 51 50 49 60 59 58 57 56 55 64 63 62 61];

for i = 1:64
    ref = reArr(i); % uses the key above for the index
    idx = (ref)+(ref-1); % indexes the first map response 
    idx2 = 2*ref; % indexes the second map response 
    fin = (i)+(i-1);  % orders the first response
    fin2 = 2*i; % orders the second response
    nI(fin,:) = I(idx,:); % creates a new table with the first and second responses in the order that they will get plotted  
    nI(fin2,:) = I(idx2,:);
end
nI([2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62, ...
    64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126,end],:) = []; % remove secondary movements
nI.Properties = I.Properties;

reArr2 = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 24 25 26 17 18 19 20 ...
        36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]; % uses index for the table3(ie ch# + 1)
    
for i = 1:64
    idx = reArr2(i);
    nimpT(i,:) = impT(idx,:);  
end
nimpT.Properties.VariableNames = impT.Properties.VariableNames;

% switch arrays to plot left then right RFA
if nI.Properties.CustomProperties.mapOrientation == 'R'
    st = nI;
    st(1:32,:) = nI(33:64,:);
    st(33:64,:) = nI(1:32,:);
    nI = st;
    if nI.array(1) == 1
        return
    end
end

if nimpT.Properties.CustomProperties.recOrientation == 'R'
    st = nimpT;
    st(1:32,:) = nimpT(33:64,:);
    st(33:64,:) = nimpT(1:32,:);
    nimpT = st;
    if nimpT.array(1) == 1
        return
    end
end

% add impedance values to table
idx = contains(nI.Properties.VariableNames,'map'); % index for maps
sz = sum(idx); % number of maps
ma = nI.Properties.VariableNames(idx); % list of maps
datesnI = extractAfter(ma,'map_'); % list of dates
imp = nimpT.Properties.VariableNames(contains(nimpT.Properties.VariableNames,'mean_')); 
datesnimpT = extractAfter(imp,'mean_'); % get dates for impedance tests
datesnI = datetime(datesnI,'Format','yyyy_MM_dd');
datesnimpT = datetime(datesnimpT,'Format','yyyy_MM_dd');
impdatmatchRef = cell(1);
for i = 1:sz
    [differ,match] = min(abs(datesnimpT - datesnI(i))); % finds closest impedance measurement to map date
    impdatmatchRef{1,i} = string(datesnimpT(match)); % saves a cell array of the impedance testing dates
    impdatmatchRef{2,i} = string(days(differ)); % saves a cell array of the difference in impedance testing dates
    nimpTnam = strcat('mean_',string(datesnimpT(match))); % recreates impedance variable name 
    idx = contains(nimpT.Properties.VariableNames,nimpTnam); % finds index for impedance variable
    val = table2array(nimpT(:,idx)); % stores data for impedance variable
    mapNam = strcat('map_',string(datesnI(i))); 
    nI = addvars(nI,val,'After',mapNam); % adds impedance values
    repl = find(contains(nI.Properties.VariableNames,'val')); 
    nI.Properties.VariableNames(repl) = {char(strcat('imp','_',string(datesnI(i))))}; % renames impedance variable
end

% plot icms maps
impID = find(contains(nI.Properties.VariableNames,'imp')); % indices of impedance variables 
thrID = find(contains(nI.Properties.VariableNames,'thresh')); % indices of threshold variables 
for i = 1:sz
    imp = impID(i); 
    thresh = thrID(i);
    % assign transparency for icms threshold
    idx = nI{:,thresh} == 80;
    nI{idx,thresh} = 0.4;
    idx = nI{:,thresh} > 60;
    nI{idx,thresh} = 0.55;
    idx = nI{:,thresh} > 40;
    nI{idx,thresh} = 0.7;
    idx = nI{:,thresh} > 20;
    nI{idx,thresh} = 0.85;
    idx = nI{:,thresh} > 1;
    nI{idx,thresh} = 1;
    c = table2array(nI(:,imp));
    fc = c';
    figure('Position', [10 10 1000 475]);
    p = patch(xAll,yAll,fc,'FaceAlpha','flat','FaceVertexAlphaData',nI{:,thresh}, ...
        'AlphaDataMapping','none','LineStyle','none');
    set(gca,'XColor','none','YColor','none')
    str = nI.Properties.VariableNames(thresh);
    dt = extractAfter(str,'thresh_'); % get dates for impedance tests
    dt = string(datetime(dt,'InputFormat','yyyy_MM_dd','Format','MM/dd/yyyy'));
    title(append(I.Properties.Description,' Impedance and Threshold Comparison ',dt));
    colormap(colors);
    colorbar;
    caxis ([10000 3000000]);
end

clearvars -except I impT nI nimpT impdatmatchRef