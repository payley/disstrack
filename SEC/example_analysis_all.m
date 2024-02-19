%% Example data from analyis for all channels both arrays
% creates figure for smoothed data, raster plots, and mean firing rate
% not recommended with the new chPlot tables for easier access to the data
arr = {'P1','P2'};
sGen = 0; % set to one if you want to randomly generate a reference stim
blN = 'R21-09_2021_07_11_4';
dir = [fullfile('C:\Users\Phayley2\Desktop\HOLD\FRA v2\')];
% dir = [fullfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\R21-09',blN)];
load(fullfile(['P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\R21-09\R21-09_2021_07_11_4'],[blN,'_','StimTimes']));
% load(fullfile(dir,[blN,'_','StimTimes']));
if sGen > 0 % random generation
    tot = numel(StimOnsets);
    idx = randperm(tot,sGen);
    ref = StimOnsets(idx);
else
    ref = (4960730); % set manually instead
end
x25 = linspace(0,25,751); % time in ms to match samples
%% Generate smoothed data samples for each channel
for i = 1:2 % based on number of arrays
    figure;
    hold on
    cap = sprintf('Array %1d Sample %d\n',i,ref);
    set(gcf,'Name',cap);
    for ii = 1:32 % number of channels
        ch = ii - 1;
        chID = sprintf('%03d',ch);
        load(fullfile(dir,[blN,'_Filtered_StimSmoothed'],[blN,'_Filt_',arr{i},'_Ch_',chID]));
        subplot(8,4,ii)
        plot(x25,data(ref:(ref+750)));
    end
end
%% Plot raster plots for first 50 reps of stim for all channels
tot = numel(StimOnsets);
idx = randperm(tot,50);
ref = StimOnsets(idx);
for i = 1:2 % based on number of arrays
    figure;
    hold on
    cap = sprintf('Array %1d\n',i);
    set(gcf,'Name',cap);
    for ii = 1:32 % number of channels
        SP = zeros(20,301);
        ch = ii - 1;
        chID = sprintf('%03d',ch);
        load(fullfile(dir,[blN,'_TC-neg3.5_ThreshCross'],[blN,'_ptrain_',arr{i},'_Ch_',chID]));
        subplot(8,4,ii)
        for iii = 1:50 % number of reps of stim pulses
            SP(iii,:) = logical(peak_train(ref(iii):(ref(iii)+300)));
        end
        plotSpikeRaster(logical(SP),'PlotType','vertline');        
        xlabel(['Time (ms)']);
        ylabel(['Trials']);
        set(gca,'XTick',0:30:300)
        set(gca,'XTickLabel',0:1:10)
    end
end
%% Generate mean firing rate plots for each channel
% repeat of SECperCh_Figs in repo
t25 = linspace(0,25,251); % time in ms to match samples
for i = 1:2 % based on number of arrays
    figure;
    hold on
    cap = sprintf('Array %1d\n',i);
    set(gcf,'Name',cap);
    for ii = 1:32 % number of channels
        ch = ii - 1;
        chID = sprintf('%03d',ch);
        load(fullfile(dir,[blN,'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],[blN,'_ChannelStats_',arr{i},'_Ch',chID]));
        subplot(8,4,ii)
        plot(t25,MeanSpikeRate(:));
        xlabel(['Time (ms)']);
        ylabel(['Rate']);
    end
end