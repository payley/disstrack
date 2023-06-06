%% Create table of channel stats 
function [chPlot] = channel_stats(C,idx,reArr,txt_id,txt_id2)
% loads the quick reference channel stats table if it exists
% creates, populates, and saves the table otherwise
%
% INPUT: 
% C; a reference table with blocks and their respective parameters
% idx; index for the associated block of the channel stats
% reArr; an array of the order of the channels of both arrays in their plotting order
% txt_id; a cell array of strings of the channel names without reference to
% the array
% txt_id2: another configuration of the above
%
% OUTPUT:
% chPlot; a table of all the channels for a block and their respective
% stats produced by the SEC workflow

% set-up table
if ~exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_refstats.mat']))
    arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
    pk_latency = zeros(64,1);
    pk_rate = zeros(64,1);
    rand_sig = zeros(64,1);
    blank_win = zeros(64,1);
    mean_rate = cell(64,1);
    chPlot = table(arr,txt_id,reArr,pk_latency,pk_rate,rand_sig,blank_win,mean_rate,...
        'VariableNames',{'arr','ch','ch_ref','pk_latency','pk_rate','rand_sig','blank_win','mean_rate'});
    % iteratively accesses files associated with the channels
    for i = 1:numel(reArr) % channels in plotting order
        chID = txt_id{i};
        chID2 = txt_id2{i};
        r = reArr(i);
        if r <= 32
            load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                [char(C.Blocks(idx)),'_ChannelStats_P1_',chID,'.mat']));
            load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_Filtered_StimSmoothed'],...
                [char(C.Blocks(idx)),'_Filt_P1_',chID2,'.mat']));
        else
            load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                [char(C.Blocks(idx)),'_ChannelStats_P2_',chID,'.mat']));
            load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_Filtered_StimSmoothed'],...
                [char(C.Blocks(idx)),'_Filt_P2_',chID2,'.mat']));
        end
        chPlot.pk_latency(i) = Latency_ms;
        chPlot.pk_rate(i) = MaxSpikeRate;
        if isempty(p) % work around for now
            chPlot.rand_sig(i) = 1;
        else
            chPlot.rand_sig(i) = p;
        end
        chPlot.blank_win(i) = TimeAfter_ms;
        chPlot.mean_rate{i} = MeanSpikeRate;
    end
    save(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_refstats.mat']),'chPlot');
else
    load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_refstats.mat']),'chPlot');
end