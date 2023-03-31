%% New version with average impedance over time plots
% script to extract impedance data from excel files and plot over time

% Load files
info = dir('*.csv'); % directory should be set to the container folder
list = {info.name}; % converts field to character type
list = list(contains(list,['1000'])); % eliminates tests not done at 1000Hz

% INPUTS-->
rat = {'R22-05'}; % enter rat name here
ch = (0:31); % set # of channels for both arrays
channels = cat(2,ch,ch)'; % numbers channels like Intan does automatically
array = zeros(64,1);
array(1:32) = 1;
array(33:64) = 2;
impT = table(channels,array); % starts table that will contain impedances
impT = addprop(impT,{'AnimalID','recOrientation'},{'table','table'});
impT.Properties.CustomProperties.AnimalID = rat; % set rat surgical name
impT.Properties.CustomProperties.recOrientation = 'L'; % set to L or R depending on which array 1 corresponds to on recordings

% Run script
f = [rat{1},'_%d_%d_%d']; % creates format to parse file name
for i = 1:numel(list)
    metadat = num2cell(sscanf(list{i},f,[3 1]));
    metadat{2}= sprintf('%02d',metadat{2});
    metadat{3}= sprintf('%02d',metadat{3});
    metadat = string(metadat);
    dates{i} = char(strjoin(metadat,'_'));
end
dates = unique(string(dates)); % ids unique dates
nDat = numel(dates); % counts number of blocks
for i = 1:nDat % loop for each date
    c = list(contains(list,dates{i}));
    nC = numel(c);
    st = zeros(64,nC); % temporary table to store repeated tests for a single day
    for ii = 1:nC % loop for repeated tests
        temp = readtable(c{ii});
        if size(temp,1) == 64  
            st(:,ii) = temp.ImpedanceMagnitudeAt1000Hz_ohms_; % make an array of imp values for each
        else % replaces dysfunctional headstages/ports with missing channels with NaN values for now
            P = string(temp.Port);
            ports = unique(P);
            pA = P == ports(1);
            if sum(pA) < 32
                tt = NaN(64,size(temp,2));
                tt = array2table(tt);
                tt.Properties = temp.Properties;
                tt = convertvars(tt,{'ChannelNumber','ChannelName','Port'},'cell');
                tt(33:64,:) = temp(~pA,:);
                temp = tt;
            end
            pB = P == ports(2);
            if sum(pB) < 32
                tt = NaN(64,size(temp,2));
                tt = array2table(tt);
                tt.Properties = temp.Properties;
                tt = convertvars(tt,{'ChannelNumber','ChannelName','Port'},'cell');
                tt(1:32,:) = temp(~pB,:);
                temp = tt;
            end
            st(:,ii) = temp.ImpedanceMagnitudeAt1000Hz_ohms_;
        end
    end
    impT.new = mean(st,2); % calculate the mean for repeated tests at each day and add a column to the table
    impT.Properties.VariableNames(end) = {char(strcat('mean','_',dates(i)))};
    impT.new = std(st,0,2); % same for std
    impT.Properties.VariableNames(end) = {char(strcat('std','_',dates(i)))}; % std within a day DIFFERENT THAN B/TW CHANNELS
    clearvars st nC c
end
%% Plot box and whisker plots of impedance
idx = contains(impT.Properties.VariableNames,'mean');
xl = nDat + 1; % sets number of ticks on x-axis
arr1 = table2array(impT(1:32,idx))./1e3; % extract array 1 and convert to kOhms
arr2 = table2array(impT(33:64,idx))./1e3; % extract array 2 and convert to kOhms
figure;
hold on
boxplot(arr1);
title(strcat(rat,{' '},'Array 1'));
set(gca,'XTick',[1:nDat],'XTickLabel',dates);
ylabel('Impedance (kOhms)');
xlim([0 xl]);
ylim([0 5000]);
hold off
figure;
hold on
boxplot(arr2);
title(strcat(rat,{' '},'Array 2'));
set(gca,'XTick',[1:nDat],'XTickLabel',dates);
ylabel('Impedance (kOhms)');
xlim([0 xl]);
ylim([0 5000]);
hold off
%% Plot range of impedance values
impVar1 = range(arr1,2)';
figure;
hold on
bar(impVar1);
ylabel('Change in Impedance (kOhms)');
xlabel('Channel');
title(strcat(rat,{' '},'Array 1'));
ylim([0 5000]);
hold off
impVar2 = range(arr2,2)';
figure;
hold on
bar(impVar2);
ylabel('Change in Impedance (kOhms)');
xlabel('Channel');
title(strcat(rat,{' '},'Array 2'));
ylim([0 5000]);
hold off
%% Output
clearvars -except impT dates
%% Deprecated plot medians
% idx = contains(impT.Properties.VariableNames,'mean');
% arr1 = median(table2array(impT(1:32,idx)),1);
% arr2 = median(table2array(impT(33:64,idx)),1);
% arr1 = cat(1,arr1,std(table2array(impT(1:32,idx))));
% arr2 = cat(1,arr2,std(table2array(impT(33:64,idx))));
% arr1 = arr1/1e3; % in kOhms
% arr2 = arr2/1e3; 
% dates = strrep(dates,'_',' ');
% errorbar(arr1(1,:),arr1(2,:)); 
% hold on
% set(gca,'XTick',[1:nDat],'XTickLabel',dates);
% ylabel('Impedance (kOhms)');
% xlim([0 11]);
% title(strcat(rat,{' '},'Array 1'))
% hold off
% figure;
% errorbar(arr2(1,:),arr2(2,:)); 
% hold on
% set(gca,'XTick',[1:nDat],'XTickLabel',dates);
% ylabel('Impedance (kOhms)');
% xlim([0 11]);
% title(strcat(rat,{' '},'Array 2'))
% hold off
%% Deprecated original
% H = [1:15];
% H = array2table(H);
% input columns of impedance data (1:3,6:8,etc.)
 %% Start here
% for i = 1:3
%     n = (i * 5) - 4;
%     e = n + 2;
%     m = n + 3;
%     s = n + 4;
%     st = H{:,n:e};
%     H{:,m} = mean(st,2);
%     H{:,s} = std(st,0,2);
%     txtM = 'Mean_%dHz';
%     txtS = 'STD_%dHz';
%     title = H.Properties.VariableNames{n};
%     freq = str2num(extractAfter(title,"_"));
%     H.Properties.VariableNames{m} = sprintf(txtM,freq);
%     H.Properties.VariableNames{s} = sprintf(txtS,freq);
% end
% ch = array2table([1:64]');
% I = [ch,H(:,4),H(:,9),H(:,14)];
% clearvars -except I H