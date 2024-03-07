%% Sanity checks
%% Plots filtered data around a grasp
for i = 4
    figure;
    for ii = 1:16
        chId = compose('%03d',ii-1);
        load(sprintf('CAR_P%d_Ch_%s.mat',i,chId{1}));
        subplot(4,4,ii)
        tt = round(grasps(14).Ts*30000);
        plot(data(tt-30000:tt+30000));
    end
end
%% Plots spiking around a grasp
tt = round(grasps(20).Ts*30000);
h = [];
for i = 1:64
    sp = blockObj.getSpikeTrain(i);
    spIdx = sp(sp >= tt-30000 & sp <= tt+30000);
    spIdx = spIdx - (tt-30000);
    hh = zeros(1,60000);
    hh(spIdx) = 1;
    hh = sparse(hh);
    h = [h; hh];
end
plotSpikeRaster(logical(h),'PlotType','vertline');
%% Plots overlapped filtered data
c = 1;
figure;
hold on
for i = 1:2
    for ii = 1:16
        chId = compose('%03d',ii-1);
        load(sprintf('CAR_P%d_Ch_%s.mat',i,chId{1}));
        tt = round(grasps(14).Ts*30000);
        plot(data(tt-30000:tt-10000));
    end
end
%% Plots mean spiking around grasp event
% load block
cc = [];
chid = 61;
sp = blockObj.getSpikeTimes(chid);
succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
for iv = 1:size(succE,2)
    ev = succE(iv).Ts; % events in seconds and converted to samples
    idxV = sp(sp>(ev-1) & sp<=(ev+1)); % index of spike times that fall in the window 1s on either side of grasp
    winV = idxV - ev; % zeroing beginning of trial
    cc = [cc; winV];
end
figure;
histogram(cc,100);