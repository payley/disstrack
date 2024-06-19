%% Plot array
% load chPlot for the respective block
[C,sel] = select_data(L,DataStructure,1);
for bl = 1:2
    load(fullfile(C.Dir{bl},C.Blocks{bl},[C.Blocks{bl} '_stats_swtteo.mat']),'chPlot');
    ct = 10; % set time window to 10ms
    bin_sz = 0.5;
    ns_bins = 30000 * (bin_sz/1000);
    samp = 200/bin_sz + 1; % edges for new downsampled bins for all 200ms
    if C.Probe_Flip(bl) == 0
        x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
            8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
    else
        x1 = [8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11 ...
            1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4];
    end
    x1 = x1 + 0.5;
    y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
        6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1];
    y1 = y1 - 0.5;
    colors = [0 0 0; autumn(ct)];
    rad = [];
    fill = [];

    figure('Position', [10 10 1400 700]);
    hold on
    for i = 1:size(chPlot,1)
        [bSp,edge] = histcounts(chPlot.all_evoked_spikes{i},linspace(0,200,samp));
        tr = min(reshape(chPlot.blank_win{i},[ns_bins,size(chPlot.blank_win{i},2)/ns_bins])); % number of trials for each bin
        bSp = bSp./tr;
        chdat = bSp(1:(ct/bin_sz));
        chdat_z = (chdat - chPlot.z_mean{i})./chPlot.z_std{i};
        [pk,idxP] = max(chdat_z); % set z-score above thresh
        if pk < 3.09
            rad = 100;
            thresh = 0;
        elseif pk >= 3.09 && pk < 3.5
            rad = 800;
            thresh = 1;
        elseif pk >= 3.5 && pk < 5
            rad = 1500;
            thresh = 1;
        elseif pk >= 5 && pk < 8
            rad = 2200;
            thresh = 1;
        elseif pk >= 8
            rad = 2900;
            thresh = 1;
        end
        switch thresh
            case 1
                idxF = ceil(idxP/(1/bin_sz)); % set color based on pk time in ms
            case 0
                idxF = 0;
        end
        fill = colors(idxF + 1,:);
        s = scatter(x1(i),y1(i),rad,'MarkerFaceColor',fill,'MarkerEdgeColor',fill);
    end

    set(gca,'XColor','none','YColor','none')
    xlim([-0.5 13.5]);
    ylim([-0.5 6.5]);
    colormap(colors);
    caxis ([0 ct+1]);
    colorbar('TickLabels',["No Response", string(0:10)])
    title(sprintf('%s stim ch %03d in %s',C.Blocks{bl},C.Stim_Ch(bl) - 1,C.Stim_Array{bl}),'Interpreter','none');
end