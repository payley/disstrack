%% Create table of channel stats 
function [chPlot] = channel_stats(C,pars)
% loads the quick reference channel stats table if it exists
% creates, populates, and saves the table otherwise; set-up using
% select_data.m
%
% INPUT: 
% C; a reference table with blocks and their respective parameters
% pars; structure with the following variables:
%   idx; index for the associated block of the channel stats
%   reArr; an array of the order of the channels of both arrays in their plotting order
%   txt_id; a cell array of strings of the channel names without reference to
%   the array
%
% OUTPUT:
% chPlot; a table of all the channels for a block and their respective
% stats produced by the SEC workflow
%
% used within plot_array.m 

% determine which sd detection parameters to use

out_file = '_stats_swtteo.mat';
in_folder = '_SD_SWTTEO';

% check for variables and set-up table
if isfield(pars,'reArr')
    reArr = pars.reArr;
else
    reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
        24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
        60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels

%         reArr = [11 12 13 14 15 16 5 6 7 ...
%         8 9 10 1 2 3 4 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
%         60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels if only 48 ch
end

if isfield(pars,'txt_id') && isfield(pars,'txt_id2')
    txt_id = pars.txt_id;
else
    id = reArr(1:32) - 1; % actual channel titles
    id = [id;id];
    txt_id = compose('Ch_%03d',id);

%     id = [0:15,0:31]';
%     txt_id = compose('Ch_%03d',id); % for 48 channels only
end

if isfield(pars,'idx')
    ct = pars.idx;
else
    ct = 1:size(C.Blocks,1);
end

% set up variables
arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
evoked_trials = cell(64,1);
shuffled_trials = cell(64,1);
pre_trial = cell(64,1);
sig_response = zeros(64,1);
mean_evoked_rate = cell(64,1);
all_evoked_spikes = cell(64,1);
all_shuffled_spikes = cell(64,1);
mean_spiking = zeros(64,1);
stdev_spiking = zeros(64,1);
seed = randi(64,64,1);
pk_latency = zeros(64,1);
pk_rate = zeros(64,1);
blank_win = cell(64,1);

for idx = ct
    if ~exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)) out_file]),'file')
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTimes.mat']),'StimOnsets','');
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_NEOArtifact.mat']),'idxArt');
        chPlot = table(arr,txt_id,seed,evoked_trials,shuffled_trials,pre_trial,sig_response,...
            mean_evoked_rate,all_evoked_spikes,all_shuffled_spikes,...
            mean_spiking,stdev_spiking,pk_latency,pk_rate,blank_win,...
            'VariableNames',{'arr','ch','seed','evoked_trials','shuffled_trials','pre_trial','sig_response',...
            'mean_evoked_rate','all_evoked_spikes','all_shuffled_spikes',...
            'mean_spiking','stdev_spiking','pk_latency','pk_rate','blank_win'});
        % iteratively accesses files associated with the channels
        for ii = 1:numel(reArr) % channels in plotting order
            chID = txt_id{ii};
            r = reArr(ii);
            rng(seed(ii));
            if r <= 32
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P1_',chID,'.mat']),'peak_train');
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_RawData_StimSmoothed'],...
                    [char(C.Blocks(idx)),'_Raw_StimSmoothed_P1_',chID,'.mat']),'pars');
            else
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P2_',chID,'.mat']),'peak_train');
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_RawData_StimSmoothed'],...
                    [char(C.Blocks(idx)),'_Raw_StimSmoothed_P2_',chID,'.mat']),'pars');
            end
            fs = pars.fs;
            sp = [];
            pre = [];
            shuf = [];
            allSp = [];
            allSh = [];
            spike_train = logical(peak_train);
            nStim = numel(StimOnsets);
            lengthTr = StimOnsets(2) - StimOnsets(1) -1;
            blankTr = zeros(nStim,lengthTr);
            % pulls data for each stimulation trial
            for iii = 1:numel(StimOnsets)
                % spike data
                trial = StimOnsets(iii);
                fill = (spike_train(trial:trial + 5999))';
                prefill = (spike_train(trial-1500:trial))';
                ss = find(fill);
                ss = (1000*ss/fs)'; % in ms
                allSp = vertcat(allSp,ss);
                sp = [sp; fill];
                pre = [pre; prefill];
                % shuffled data
                blanking = pars.trial_blanking(iii);
                if blanking > 6000 % stupid work-around
                    blanking = 6000;
                end
                shIdx = (randperm(6000-blanking)) + blanking;
                shIdx = [1:blanking shIdx];
                if any(shIdx == 6001)
                ff = 1;
                end
                fill = fill(shIdx);
                sh = find(fill);
                sh = (1000*sh/fs)'; % in ms
                allSh = vertcat(allSh,sh);
                shuf = [shuf; fill];
                % blanking time
                idxBl = zeros(1,lengthTr);
                idxBl(1:blanking) = 1;
                blankTr(iii,:) = idxBl | idxArt(iii,1:6000);
            end
            num_trials = nStim - sum(all(blankTr,2));
            chPlot.evoked_trials{ii} = sp;
            chPlot.shuffled_trials{ii} = shuf;
            chPlot.pre_trial{ii} = pre;
            sSp = sum(sp,1);
            sShuf = sum(shuf,1);
            chPlot.mean_spiking(ii) = (mean(sShuf,2)/num_trials)*fs; % in spikes/sec
            chPlot.stdev_spiking(ii) = (std(sShuf,0,2)/num_trials)*fs;
            mIdx = (sSp/num_trials)*fs > (chPlot.mean_spiking(ii) + chPlot.stdev_spiking(ii));
            [r,rIdx] = max(sSp(mIdx));
            if sum(mIdx) > 0 
                chPlot.pk_rate(ii) = (r/num_trials)*fs;
                l = find(mIdx);
                chPlot.pk_latency(ii) = (l(rIdx) * 1000)/fs;
            else
                chPlot.pk_rate(ii) = 0;
                chPlot.pk_latency(ii) = 0;
            end
            ct = 50; % window of interest length
            bin_sz = 0.5; % in ms
            ns_bins = fs * (bin_sz/1000); % number of samples in each bin
            hz = 1/(bin_sz/1000); % new sampling rate
            [b,a] = butter(3, 250/(hz/2), 'low');
            samp = 200/bin_sz + 1; % divides the 200ms window by size to find number of bins
            [bSp,edge] = histcounts(allSp,linspace(0,200,samp));
            sr = filtfilt(b,a,bSp(1:find(edge == ct)-1));
            chPlot.blank_win{ii} = size(blankTr,1) - sum(blankTr);
            tr = min(reshape(chPlot.blank_win{ii},[ns_bins,size(chPlot.blank_win{ii},2)/ns_bins]))'; 
            chPlot.mean_evoked_rate{ii} = (sr./tr(1:find(edge == ct)-1)')*1000/bin_sz;
            chPlot.all_evoked_spikes{ii} = allSp;
            chPlot.all_shuffled_spikes{ii} = allSh;
        end
        save(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot', '-v7.3');
    else
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
    end
end