%% Example data from analyis for a single channels
% creates an example  panel of the various steps of analysis at both a
% gross and fine time scale, plots spike waveforms from short timescale,
% and compares processed data to spiking activity 
chan = {'028'}; % add any channels for examination
chid = [28]; % match to above
arr = ['P1']; % arrays of interest
n = 4; % number of exemplar stim times
block = 'R21-09_2021_07_11_4';
dir = [fullfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\R21-09',block)];
load(fullfile(dir,[block,'_','StimTimes']));
tot = numel(StimOnsets);
idx = randperm(tot,n);
ref = StimOnsets(idx);
% ref = (4960730); % set stim rep number manually instead
x25 = linspace(0,25,751);
x200 = linspace(0,200,6001);
for i = 1:numel(chan)
    for ii = 1:n
        figure;
        hold on
        cap = sprintf('Channel %03d Sample %d\n',chid(i),ref(ii));
        set(gcf,'Name',cap);

        % raw data
        subplot(6,2,1);
        load(fullfile(dir,[block,'_RawData'],[block,'_Raw_',arr,'_Ch_',chan{i}]));
        plot(x200,data(ref(ii):(ref(ii)+6000)));
        title('Raw Data 200ms');
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        subplot(6,2,2);
        plot(x25,data(ref(ii):(ref(ii)+750)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Raw Data 25ms');

        % smoothed
        load(fullfile(dir,[block,'_RawData_StimSmoothed'],[block,'_Raw_StimSmoothed_',arr,'_Ch_',chan{i}]));
        subplot(6,2,3);
        plot(x200,data(ref(ii):(ref(ii)+6000)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Smooth Data 200ms');
        subplot(6,2,4);
        plot(x25,data(ref(ii):(ref(ii)+750)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Smooth Data 25ms');

        % car
        load(fullfile(dir,[block,'_FilteredCAR_StimSmoothed'],[block,'_FiltCAR_',arr,'_Ch_',chan{i}]));
        subplot(6,2,7);
        plot(x200,data(ref(ii):(ref(ii)+6000)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('CAR Data 200ms');
        subplot(6,2,8);
        plot(x25,data(ref(ii):(ref(ii)+750)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('CAR Data 25ms');

        % mean spike rate
        load(fullfile(dir,[block,'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],[block,'_ChannelStats_',arr,'_Ch',chan{i}]));
        subplot(6,2,11:12);
        t = linspace(0,25,251);
        plot(t,MeanSpikeRate);
        xlabel(['Time(ms)']);
        ylabel(['Spike Rate']);
        title('Mean Spiking Rate');

        % filtered
        load(fullfile(dir,[block,'_Filtered_StimSmoothed'],[block,'_Filt_',arr,'_Ch_',chan{i}]));
        subplot(6,2,5);
        plot(x200,data(ref(ii):(ref(ii)+6000)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Filt Data 200ms');
        subplot(6,2,6);
        plot(x25,data(ref(ii):(ref(ii)+750)));
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Filt Data 25ms');

        % thresh
        load(fullfile(dir,[block,'_TC-neg3.5_ThreshCross'],[block,'_ptrain_',arr,'_Ch_',chan{i}]));
        subplot(6,2,9);
        plot(x200,data(ref(ii):(ref(ii)+6000)));
        sp = find(logical(peak_train(ref(ii):(ref(ii)+6000))))/30;
        if sp > 0
            xline(sp,'m');
        end
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Thresh Data 200ms');
        subplot(6,2,10);
        plot(x25,data(ref(ii):(ref(ii)+750)));
        sp = find(logical(peak_train(ref(ii):(ref(ii)+750))))/30;
        if sp > 0
            xline(sp,'m');
        end
        xlabel(['Time(ms)']);
        ylabel(['uV']);
        title('Thresh Data 25ms');
        
        % additional plots of spike shape
        pl = sp < 7;
        if pl >= 1
           figure;
           cap = sprintf('Channel %03d Sample %d Spikes\n',chid(i),ref(ii));
           set(gcf,'Name',cap);
           nPl = sum(logical(peak_train(ref(ii):(ref(ii)+210))));
           lastRef = numel(find(peak_train(1:ref(ii))));
           for c = 1:nPl
               idP = lastRef + c;
               subplot(nPl,1,c);
               plot(spikes(idP,:))
           end
        end
    end
end
%% Overlay a single channel with smooth data, spike raster, and mean channel activity
% set up parameters
arrID = 'P1';
chID = '013';
figure;
hold on
cap = sprintf('Array %s Channel %s',arrID,chID);
set(gcf,'Name',cap);
SP = zeros(20,301);
s10 = linspace(0,10,301); % time in ms to match samples
t10 = linspace(0,10,101); % time in ms to match samples
tot = numel(StimOnsets);
idx = randperm(tot,3); % generate a random reference stim
idxR = randperm(tot,50); % generates random reference stims for the raster plot
ref = StimOnsets(idx);
refR = StimOnsets(idxR);

% plot smooth data
load(fullfile(dir,[block,'_RawData_StimSmoothed'],[block,'_Raw_StimSmoothed_',arrID,'_Ch_',chID]));
for i = 1:3 % number of examples of smooth data
    subplot(5,1,i)
    plot(s10,data(ref(i):(ref(i)+300)));
    ylabel(['uV']);
end

% plot spike rasters
load(fullfile(dir,[block,'_TC-neg3.5_ThreshCross'],[block,'_ptrain_',arrID,'_Ch_',chID]));
subplot(5,1,4)
for i = 1:50 % number of stim pulses
    SP(i,:) = logical(peak_train(refR(i):(refR(i)+300)));
end
plotSpikeRaster(logical(SP),'PlotType','vertline');
ylabel(['Trials']);
set(gca,'XTick',0:30:300)
set(gca,'XTickLabel',0:1:10)

% plot mean spiking activity
load(fullfile(dir,[block,'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],[block,'_ChannelStats_',arrID,'_Ch',chID]));
subplot(5,1,5);
plot(t10,MeanSpikeRate(1:101));
xlabel(['Time (ms)']);
ylabel(['Spike Rate']);