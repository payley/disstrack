%% Create table of channel stats 
function [chPlot] = channel_stats(C,idx,reArr,txt_id,txt_id2)
% loads the quick reference channel stats table if it exists
% creates, populates, and saves the table otherwise; set-up using
% select_data.m
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
%
% used within plot_array.m 

% check for variables and set-up table
if ~exist('reArr','var')
    reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
        24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
        60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels
end
if ~exist('txt_id','var') && ~exist('txt_id2','var')
    id = reArr(1:32) - 1; % actual channel titles
    id = [id;id];
    txt_id = compose('Ch%03d',id);
    txt_id2 = compose('Ch_%03d',id);
end

if exist('idx','var') % index included for a single block
    if ~exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_refstats.mat']),'file')
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
else % run all blocks selected
    for i = 1:size(C.Blocks,1)
        if ~exist(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']),'file')
            arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
            pk_latency = zeros(64,1);
            pk_rate = zeros(64,1);
            rand_sig = zeros(64,1);
            blank_win = zeros(64,1);
            mean_rate = cell(64,1);
            chPlot = table(arr,txt_id,reArr,pk_latency,pk_rate,rand_sig,blank_win,mean_rate,...
                'VariableNames',{'arr','ch','ch_ref','pk_latency','pk_rate','rand_sig','blank_win','mean_rate'});
            % iteratively accesses files associated with the channels
            for ii = 1:numel(reArr) % channels in plotting order
                chID = txt_id{ii};
                chID2 = txt_id2{ii};
                r = reArr(ii);
                if r <= 32
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                        [char(C.Blocks(i)),'_ChannelStats_P1_',chID,'.mat']));
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_Filtered_StimSmoothed'],...
                        [char(C.Blocks(i)),'_Filt_P1_',chID2,'.mat']));
                else
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTriggeredStats_ChannelSpiking_RandomBlanked'],...
                        [char(C.Blocks(i)),'_ChannelStats_P2_',chID,'.mat']));
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_Filtered_StimSmoothed'],...
                        [char(C.Blocks(i)),'_Filt_P2_',chID2,'.mat']));
                end
                chPlot.pk_latency(ii) = Latency_ms;
                chPlot.pk_rate(ii) = MaxSpikeRate;
                if isempty(p) % work around for now
                    chPlot.rand_sig(ii) = 1;
                else
                    chPlot.rand_sig(ii) = p;
                end
                chPlot.blank_win(ii) = TimeAfter_ms;
                chPlot.mean_rate{ii} = MeanSpikeRate;
            end
            save(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']),'chPlot');
        else
            load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_refstats.mat']),'chPlot');
        end
    end
end