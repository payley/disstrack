%% Plotting spikes from a single channel around an event in a raster
% upating synced event times 
%load('P:\Extracted_Data_To_Move\Rat\Intan\phTest\phTest\R21-09\2-210711-222406_Block.mat') % load blockObj
vid = nigeLab.libs.VidScorer(blockObj.Cameras(1)); 
origTime = blockObj.Cameras(1).getTimeSeries; % original time series of video
events = blockObj.Events(end-20:end);
events(1) = [];
events(isnan([events.Ts])) = []; % isolate events 
ts = [events.Ts]; % array of event timestamps
for i = 1:numel(ts)
[~,idx] = min( abs(origTime  - ts(i) )); % finding the index of the event timestamp
newTs(i) = vid.VideoTime(idx); % indexing updated video times
end
for i = 1:10
events(i).Ts = newTs(i);
end
% finding spikes in a window around events
W = zeros(10,30001); % array containing the samples 500ms either side of the event with a spike by the number of events 
spTime = blockObj.getSpikeTimes(19); % spike times of the channel in the input
for i = 1:10 % number of events
    e = events(i).Ts/1000; % timestamp of event based on video frame in sec
    idx = spTime>(e-0.5)&spTime<(e+0.5); % index of spike times that fall in the window
    window = spTime(idx); % selecting those spike times
    window = round(window*30000); % converting into sample rate instead (assuming 30000Hz sample rate)
    window = window - round((e-0.5)*30000); % subtracting the sample start to zero out the beginning
    W(i,window) = 1; % assigning ones to the spike sample number
end
figure;
plotSpikeRaster(logical(W),'PlotType','vertline'); % located in _SD package and may need to add to path