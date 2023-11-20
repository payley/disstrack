%% Plotting spikes from a single channel around an event in a raster
% load block
% load('P:\Extracted_Data_To_Move\Rat\Intan\phTest\phTest\R21-09\2-210711-222406_Block.mat') % load blockObj
%% set-up parameters
channel = 39;
selector = 'all';
%% run script and produce spike rasters
% origTime = blockObj.Cameras(1).getTimeSeries; % original time series of video
% events = blockObj.Events(end-20:end);
% events(1) = [];
% events(isnan([events.Ts])) = []; % isolate events 
% ts = [events.Ts]; % array of event timestamps

failE = blockObj.filterEvt({'Name','GraspAttempted'});
successE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted')); % selects for both stereotyped and nonstereotyped trials
stereotypedE = blockObj.filterEvt({'Name','GraspStarted'});
nF = size(failE,2);
nS = size(successE,2);
nSt = size(stereotypedE,2);

% for i = 1:numel(ts)
% [~,idx] = min( abs(origTime  - ts(i) )); % finding the index of the event timestamp
% newTs(i) = vid.VideoTime(idx); % indexing updated video times
% end
% 
% for i = 1:10
% events(i).Ts = newTs(i);
% end

% finding spikes in a window around events
switch selector
    case 'stereotyped'
        W = zeros(nSt,30001); 
        for i = 1:nSt 
            st = stereotypedE(i).Ts/1000;
            idxSt = spTime(spTime>(st-0.5)&spTime<(st+0.5));
            winSt = round(idxSt*30000) - round((st-0.5)*30000);
            W(i,winSt) = 1;
            figure;
            plotSpikeRaster(logical(W),'PlotType','vertline'); 
        end
    case 'success'
        W = zeros(nS,30001);
        for i = 1:nS 
            ss = successE(i).Ts/1000;
            idxS = spTime(spTime>(ff-0.5)&spTime<(ff+0.5));
            winS = round(idxS*30000) - round((ss-0.5)*30000);
            W(i,winS) = 1;
        end
        figure;
        plotSpikeRaster(logical(W),'PlotType','vertline'); 
    case 'fail'
        W = zeros(nF,30001);
        for i = 1:nF % number of events
            ff = failE(i).Ts/1000;
            idxF = spTime(spTime>(ss-0.5)&spTime<(ss+0.5)); % index of spike times that fall in the window
            winF = round(idxF*30000) - round((ff-0.5)*30000); % converting into samples (assuming 30,000 Hz) subtracting the sample start to zero out the beginning
            W(i,winF) = 1; % assigning ones to the spike sample number
        end
        figure;
        plotSpikeRaster(logical(W),'PlotType','vertline'); % located in _SD package and may need to add to path
    case 'all'
        W{1} = zeros(nF,30001);
        W{2} = zeros(nS,30001);
        W{3} = zeros(nSt,30001);
        spTime = blockObj.getSpikeTimes(channel); % spike times of the channel in the input
        numb = {nF nS nSt};
        allEv = {failE successE stereotypedE};
        for i = 1:3 % number of event types
            for ii = 1:numb{i}
                %   e = events(i).Ts/1000; % timestamp of event based on video frame in sec
                Ev = allEv{i};
                vv = Ev(ii).Ts;
                idxV = spTime(spTime>(vv-0.5)&spTime<(vv+0.5)); % index of spike times that fall in the window
                winV = round(idxV*30000) - (round((vv-0.5)*30000)-1); % converting into samples (assuming 30,000 Hz) subtracting the sample start to zero out the beginning
                W{i}(ii,winV) = 1; % assigning ones to the spike sample number
            end
        end
        meta = blockObj.Meta;
        figure;
        plotSpikeRaster(logical(W{1}),'PlotType','vertline'); % located in _SD package and may need to add to path
        t = sprintf('%s_%s_%s_%s_%s ch_%d fail',meta.AnimalID,meta.Year,meta.Month,meta.Day,meta.Phase,channel);
        title(t,'Interpreter','none');
        xlim([0 30001]);
        xticks(linspace(0,30001,11));
        xticklabels(-50:10:50);
        figure;
        plotSpikeRaster(logical(W{2}),'PlotType','vertline');
        t = sprintf('%s_%s_%s_%s_%s  ch_%d success',meta.AnimalID,meta.Year,meta.Month,meta.Day,meta.Phase,channel);
        title(t,'Interpreter','none');
        xlim([0 30001]);
        xticks(linspace(0,30001,11));
        xticklabels(-50:10:50);
        figure;
        plotSpikeRaster(logical(W{3}),'PlotType','vertline');
        t = sprintf('%s_%s_%s_%s_%s  ch_%d stereotyped',meta.AnimalID,meta.Year,meta.Month,meta.Day,meta.Phase,channel);
        title(t,'Interpreter','none');
        xlim([0 30001]);
        xticks(linspace(0,30001,11));
        xticklabels(-50:10:50);
end
%% plot histogram
[~,col] = find(W{1});
histogram(col,20);
xlim([0 30001]);
xticks(linspace(0,30001,11));
xticklabels(-50:10:50);