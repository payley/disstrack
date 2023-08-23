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
end
if isfield(pars,'txt_id') && isfield(pars,'txt_id2')
    txt_id = pars.txt_id;
else
    id = reArr(1:32) - 1; % actual channel titles
    id = [id;id];
    txt_id = compose('Ch_%03d',id);
end

if isfield(pars,'idx') % index included for a single block
    idx = pars.idx;
    if ~exist(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)) out_file]),'file')
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTimes.mat']),'StimOnsets');
        arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
        evoked_trials = cell(64,1);
        shuffled_trials = cell(64,1);
        sig_response = zeros(64,1);
        mean_evoked_rate = cell(64,1);
        mean_shuffled_rate = cell(64,1);
        all_evoked_spikes = cell(64,1);
        all_shuffled_spikes = cell(64,1);
        mean_spiking = zeros(64,1);
        stdev_spiking = zeros(64,1);
        seed = randi(64,64,1);
        pk_latency = zeros(64,1);
        pk_rate = zeros(64,1);
        blank_win = zeros(64,1);
        chPlot = table(arr,txt_id,seed,evoked_trials,shuffled_trials,sig_response,...
            mean_evoked_rate,mean_shuffled_rate,all_evoked_spikes,all_shuffled_spikes,...
            mean_spiking,stdev_spiking,pk_latency,pk_rate,blank_win,...
            'VariableNames',{'arr','ch','seed','evoked_trials','shuffled_trials','sig_response',...
            'mean_evoked_rate','mean_shuffled_rate','all_evoked_spikes','all_shuffled_spikes',...
            'mean_spiking','stdev_spiking','pk_latency','pk_rate','blank_win'});
        % iteratively accesses files associated with the channels
        for ii = 1:numel(reArr) % channels in plotting order
            chID = txt_id{ii};
            r = reArr(ii);
            rng(seed(ii));
            if r <= 32
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P1_',chID,'.mat']),'peak_train');
%                 load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_RawData_StimSmoothed'],...
%                     [char(C.Blocks(idx)),'_Raw_StimSmoothed_P1_',chID,'.mat']),'pars');
            else
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P2_',chID,'.mat']),'peak_train');
%                 load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_RawData_StimSmoothed'],...
%                     [char(C.Blocks(idx)),'_Raw_StimSmoothed_P2_',chID,'.mat']),'pars');
            end
            fs = pars.fs;
            sp = [];
            shuf = [];
            sh = [];
            ssh = [];
            allSp = [];
            allSh = [];
            spike_train = logical(peak_train);
            % pulls data for each stimulation trial 
            for iii = 1:numel(StimOnsets)
                trial = StimOnsets(iii);
                fill = (spike_train(trial:trial + 6000))';
                ss = find(fill);
                ss = (1000*ss/fs)';
                allSp = vertcat(allSp,ss);
                sp = [sp; fill];
                shIdx = randperm(6001);
                fill = fill(shIdx);
                sh = find(fill);
                sh = (1000*sh/fs)';
                allSh = vertcat(allSh,sh);
                shuf = [shuf; fill];
            end
            chPlot.evoked_trials{ii} = sp;
            chPlot.shuffled_trials{ii} = shuf;
            sSp = sum(sp,1);
            sShuf = sum(shuf,1);
            chPlot.mean_spiking(ii) = mean(sShuf,2)*30; % in spikes/sec
            chPlot.stdev_spiking(ii) = std(sShuf,0,2)*30;
            mIdx = sSp*30 > (chPlot.mean_spiking(ii) + chPlot.stdev_spiking(ii));
            [r,rIdx] = max(sSp(mIdx));
            if ~isempty(mIdx)
                chPlot.pk_rate(ii) = r*30;
                l = find(mIdx);
                chPlot.pk_latency(ii) = (l(rIdx) * 1000)/fs;
            else
                chPlot.pk_rate = 0;
                chPlot.pk_latency = 0;
            end
            [sr,~] = ksdensity(allSp,0:0.1:10,'Bandwidth',0.25);
            [shr,~] = ksdensity(allSh,0:0.1:10,'Bandwidth',0.25);
            chPlot.mean_evoked_rate{ii} = sr*30;
            chPlot.mean_shuffled_rate{ii} = shr*30;
            chPlot.all_evoked_spikes{ii} = allSp;
            chPlot.all_shuffled_spikes{ii} = allSh;
            chPlot.blank_win(ii) = pars.blanking_period;
        end
        save(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
    else
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
    end
else % run all blocks selected
    for i = 1:size(C.Blocks,1)
        if ~exist(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'file')
            load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTimes.mat']),'StimOnsets');
            arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
            evoked_trials = cell(64,1);
            shuffled_trials = cell(64,1);
            sig_response = zeros(64,1);
            mean_evoked_rate = cell(64,1);
            mean_shuffled_rate = cell(64,1);
            all_evoked_spikes = cell(64,1);
            all_shuffled_spikes = cell(64,1);
            mean_spiking = zeros(64,1);
            stdev_spiking = zeros(64,1);
            seed = randi(64,64,1);
            pk_latency = zeros(64,1);
            pk_rate = zeros(64,1);
            blank_win = zeros(64,1);
        chPlot = table(arr,txt_id,seed,evoked_trials,shuffled_trials,sig_response,...
            mean_evoked_rate,mean_shuffled_rate,all_evoked_spikes,all_shuffled_spikes,...
            mean_spiking,stdev_spiking,pk_latency,pk_rate,blank_win,...
            'VariableNames',{'arr','ch','seed','evoked_trials','shuffled_trials','sig_response',...
            'mean_evoked_rate','mean_shuffled_rate','all_evoked_spikes','all_shuffled_spikes',...
            'mean_spiking','stdev_spiking','pk_latency','pk_rate','blank_win'});
            % iteratively accesses files associated with the channels
            for ii = 1:numel(reArr) % channels in plotting order
                chID = txt_id{ii};
                r = reArr(ii);
                rng(seed(ii));
                if r <= 32
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),in_folder],...
                        [char(C.Blocks(i)),'_ptrain_P1_',chID,'.mat']));
%                     load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_RawData_StimSmoothed'],...
%                         [char(C.Blocks(i)),'_RawData_StimSmoothed_P1_',chID,'.mat']),'pars');
                else
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),in_folder],...
                        [char(C.Blocks(i)),'_ptrain_P2_',chID,'.mat']));
%                     load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_RawData_StimSmoothed'],...
%                         [char(C.Blocks(i)),'_RawData_StimSmoothed_P2_',chID,'.mat']),'pars');
                end
                fs = pars.fs;
                sp = [];
                shuf = [];
                sh = [];
                ssh = [];
                allSp = [];
                allSh = [];
                spike_train = logical(peak_train);
                for iii = 1:numel(StimOnsets)
                    trial = StimOnsets(iii);
                    fill = (spike_train(trial:trial + 6000))';
                    ss = find(fill);
                    ss = (1000*ss/fs)';
                    allSp = vertcat(allSp,ss);
                    sp = [sp; fill];
                    shIdx = randperm(6000);
                    fill = fill(shIdx);
                    sh = find(fill);
                    sh = (1000*sh/fs)';
                    allSh = vertcat(allSh,sh);
                    shuf = [shuf; fill];
                end
                chPlot.evoked_trials{ii} = sp;
                chPlot.shuffled_trials{ii} = shuf;
                sSp = sum(sp,1);
                sShuf = sum(shuf,1);
                chPlot.mean_spiking(ii) = mean(sShuf,2)*30;
                chPlot.stdev_spiking(ii) = std(sShuf,0,2)*30;
                mIdx = sSp*30 > (chPlot.mean_spiking(ii) + chPlot.stdev_spiking(ii));
                [r,rIdx] = max(sSp(mIdx));
                if ~isempty(mIdx)
                    chPlot.pk_rate(ii) = r*30;
                    l = find(mIdx);
                    chPlot.pk_latency(ii) = (l(rIdx) * 1000)/fs;
                else
                    chPlot.pk_rate = 0;
                    chPlot.pk_latency = 0;
                end
                [sr,~] = ksdensity(allSp,0:0.1:10,'Bandwidth',0.25);
                [shr,~] = ksdensity(allSh,0:0.1:10,'Bandwidth',0.25);
                chPlot.mean_evoked_rate{ii} = sr*30;
                chPlot.mean_shuffled_rate{ii} = shr*30;
                chPlot.all_evoked_spikes{ii} = allSp;
                chPlot.all_shuffled_spikes{ii} = allSh;
                chPlot.blank_win(ii) = pars.blanking_period;
            end
            save(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'chPlot');
        else
            load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'chPlot');
        end
    end
end