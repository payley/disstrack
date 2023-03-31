% load(filename);
%% Quantify map changes
nMap = (size(I,2) - 1)/2; % number of maps
mI = table2array(I(:,(contains(I.Properties.VariableNames,'Map')))); % isolate movement type from map
mI(mI == 0) = NaN; % sets NR sites as NaN values 
mI = mI(65:128,:); % split to do one array at a time
% mI(mI == 2) = 1; % collapse dFl and pFl movementsI
col = zeros(size(mI,1),1); 
mI = cat(2,mI,col); % add new column
for i = 1:size(mI,1)
    row = mI(i,1:end-1); % isolate row
    allResp = row(~isnan(row)); % removes NaN values from consideration
    mI(i,end) = numel(unique(allResp)); % calculate changes in movements between maps
end
nCh = size(mI,1)/2;
Channel = [1:nCh]';
Change = [zeros(nCh,1)];
V = table(Channel,Change);


% accounts (maybe?!??) for slight variations in dual representations if you
% use the below
for i = 1:nCh
    c = i*2-1; % channel value 1
    cc = i*2;  % channel value 2 (to account for dual sites)
    V(i,2) = {((mI(c,end) + mI(cc,end))/2)};
end
chV = floor(table2array(V(:,2))); 
V(:,2) = num2cell(chV); 
noResp = V{:,2} == 0;
V(noResp,:) = []; % removes channels with no responses overall
nChAdj = size(V,1);
no_change = sum(chV == 1); % number of channels with no change in representation over time
percent_no_change = no_change/nChAdj;
some_change = sum(chV == 1 | chV == 2); % includes channels with just a single change in representation
percent_some_change = some_change/nChAdj;

% % the below just eliminates secondary movements
% for i = 1:nCh
%     c = i*2-1; % channel value 1
%     V(i,2) = {mI(c,end)- 1};
% end
% chV = table2array(V(:,2)); 
% no_change = sum(chV == 0);
% percent_no_change = no_change/nCh;

%% Quantify percent of map
nMap = (size(I,2) - 1)/2; % number of maps
mI = table2array(I(:,(contains(I.Properties.VariableNames,'Map')))); % isolate movement type from map
mI = mI(65:128,:); % split to do one array at a time
nCh = size(mI,1); % number of channels
mvmtType = [0:5]';
label = {'NR','dFl','pFl','Trunk','Face','Vibrissa'}';
map = cell(6,nMap);
M = table(mvmtType,label,map);
for i = 1:nMap
    for ii = 1:6
        mID = ii-1;
        M.map(ii,i) = {(sum(mI(:,i) == mID)/nCh)*100};
    end
end
% NOTE: this method needs to be rethought as it deals with sites with mixed
% responses
%% Quantify percent of map new method
nMap = (size(I,2) - 1)/2; % number of maps
mI = table2array(I(:,(contains(I.Properties.VariableNames,'Map')))); % isolate movement type from map
mI = mI(65:128,:); % split to do one array at a time
nCh = (size(mI,1))/2; % number of channels
add = zeros(64,4) + 6; % filled with sixes to not get them counted as NR
mI = cat(1,mI,add); % add space to table
mvmtType = [0:5]';
label = {'NR','dFl','pFl','Trunk','Face','Vibrissa'}';
map = cell(6,nMap);
M = table(mvmtType,label,map);
for i = 1:4
    for ii = 1:nCh
        c = (ii*2) - 1;
        cc = ii*2;
        d = c + 64;
        dd = cc + 64;
        if mI(c,i) ~= mI(cc,i)
            mI(d,i) = mI(c,i);
            mI(dd,i) = mI(cc,i);
        end
    end
end
for i = 1:nMap
    for ii = 1:6
        mID = ii-1;
        M.map(ii,i) = {(sum(mI(:,i) == mID)/2)*0.0625}; %uses area represented by the site
    end
end
%% Quantify map changes (deprecated version)
% nMap = (size(I,2) - 1)/2; % number of maps
% mI = table2array(I(:,(contains(I.Properties.VariableNames,'Map')))); % isolate movement type from map
% mI = mI(65:128,:); % split to do one array at a time
% col = zeros(size(mI,1),1); 
% mI = cat(2,mI,col); % add new column
% mI(mI == 2) = 1; % collapse dFl and pFl movements
% for i = 1:size(mI,1)
%     mI(i,end) = numel(unique(mI(i,1:end-1))); % calculate changes in movements between maps
% end
% nCh = size(mI,1)/2;
% Channel = [1:nCh]';
% Change = [zeros(nCh,1)];
% V = table(Channel,Change);


% accounts (maybe?!??) for slight variations in dual representations if you
% use the below
% for i = 1:nCh
%     c = i*2-1; % channel value 1
%     cc = i*2;  % channel value 2 (to account for dual sites)
%     V(i,2) = {((mI(c,end) + mI(cc,end))/2)-1};
% end
% chV = floor(table2array(V(:,2))); 
% V(:,2) = num2cell(chV); 
% no_change = sum(chV == 0);
% percent_no_change = no_change/nCh;


% % the below just eliminates secondary movements
% for i = 1:nCh
%     c = i*2-1; % channel value 1
%     V(i,2) = {mI(c,end)- 1};
% end
% chV = table2array(V(:,2)); 
% no_change = sum(chV == 0);
% percent_no_change = no_change/nCh;
