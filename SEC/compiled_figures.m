%% Make histograms with mean spike rate overlaid
idx = 21;
ct = 50;
bin_sz = 0.5;
ns_bins = 30000 * (bin_sz/1000);
samp = 200/bin_sz + 1;
[bSp,edge] = histcounts(chPlot.all_evoked_spikes{idx},linspace(0,200,samp));
tr = min(reshape(chPlot.blank_win{idx},[ns_bins,size(chPlot.blank_win{idx},2)/ns_bins]))'; 
bSp = (bSp./tr(find(edge == ct)-1));
% bSp = (bSp./tr(find(edge == ct)-1))*1000/bin_sz; % deprecated rate output
figure('Position', [500 500 560 272]); bar(bSp(1:100)); % set to 50 ms window
hold on
yline(chPlot.z_mean{idx} - (chPlot.z_std{idx}*3.09),'--');
yline(chPlot.z_mean{idx} + (chPlot.z_std{idx}*3.09),'--');
yline(chPlot.z_mean{idx});
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticks((0:20:100) + 0.5);
xticklabels(0:10:50);
xlim([0.5 100.5]);
xlabel('Time (ms)');
ylabel('Probability (spikes/stim)');