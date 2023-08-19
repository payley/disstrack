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
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_StimTimes.mat']),'StimOffsets');
        arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
        trial_data = cell(64,1);
        shuffled_trials = cell(64,1);
        sig_response = zeros(64,1);
        mean_evoked_rate = cell(64,1);
        mean_shuffled_rate = cell(64,1);
        evoked_rates = cell(64,1);
        shuffled_rates = cell(64,1);
        mean_spiking = zeros(64,1);
        stdev_spiking = zeros(64,1);
        seed = randi(64,64,1);
        pk_latency = zeros(64,1);
        pk_rate = zeros(64,1);
        chPlot = table(arr,txt_id,seed,trial_data,shuffled_trials,sig_response,...
            mean_evoked_rate,mean_shuffled_rate,evoked_rates,shuffled_rates,mean_spiking,stdev_spiking,pk_latency,pk_rate,...
            'VariableNames',{'arr','ch','seed','trial_data','shuffled_trials','sig_response',...
            'mean_evoked_rate','mean_shuffled_rate','evoked_rates','shuffled_rates','mean_spiking','stdev_spiking','pk_latency','pk_rate'});
        % iteratively accesses files associated with the channels
        for ii = 1:numel(reArr) % channels in plotting order
            chID = txt_id{ii};
            r = reArr(ii);
            rng(seed(ii));
            if r <= 32
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P1_',chID,'.mat']));
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_Filtered_StimSmoothed'],...
                    [char(C.Blocks(idx)),'_Filt_P1_',chID,'.mat']),'pars');
            else
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),in_folder],...
                    [char(C.Blocks(idx)),'_ptrain_P2_',chID,'.mat']));
                load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),'_Filtered_StimSmoothed'],...
                    [char(C.Blocks(idx)),'_Filt_P2_',chID,'.mat']),'pars');
            end
            fs = pars.FS;
            sp = [];
            shuf = [];
            sh = [];
            ssh = [];
            allSp = [];
            allSh = [];
            eShort = [];
            shShort = [];
            spike_train = logical(peak_train);
            for iii = 1:numel(StimOffsets)
                trial = StimOffsets(iii);
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
                % limit to first 10ms
                fill = (spike_train(trial:trial + 300))';
                ssh = find(fill);
                ssh = (1000*ssh/fs)';
                if ~isempty(ssh)
                    [eSp,~] = ksdensity(ssh,0:0.1:10,'Bandwidth',0.2);
                else
                    eSp = zeros(1,101);
                end
                eShort = [eShort; eSp];
                %
                shIdx = randperm(301);
                fill = fill(shIdx);
                ssh = find(fill);
                ssh = (1000*ssh/fs)';
                if ~isempty(ssh)
                    [shSp,~] = ksdensity(sh,0:0.1:10,'Bandwidth',0.2);
                else
                    shSp = zeros(1,101);
                end
                shShort = [shShort; shSp];
            end
            chPlot.trial_data{ii} = sp;
            chPlot.shuffled_trials{ii} = shuf;
            chPlot.evoked_rates{ii} = eShort;
            chPlot.shuffled_rates{ii} = shShort;
            sSp = sum(sp,1);
            sShuf = sum(shuf,1);
            chPlot.mean_spiking(ii) = mean(sShuf,2);
            chPlot.stdev_spiking(ii) = std(sShuf,0,2);
            mIdx = sSp > (chPlot.mean_spiking(ii) + chPlot.stdev_spiking(ii));
            [r,rIdx] = max(sSp(mIdx));
            chPlot.pk_rate(ii) = r;
            l = find(mIdx);
            chPlot.pk_latency(ii) = (l(rIdx) * 1000)/fs;
            [sr,~] = ksdensity(allSp,0:0.5:10,'Bandwidth',0.5);
            [shr,~] = ksdensity(allSh,0:0.5:10,'Bandwidth',0.5);
            chPlot.mean_evoked_rate{ii} = sr;
            chPlot.mean_shuffled_rate{ii} = shr;
        end
        save(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
    else
        load(fullfile(C.Dir{idx},[char(C.Blocks(idx))],[char(C.Blocks(idx)),out_file]),'chPlot');
    end
else % run all blocks selected
    for i = 1:size(C.Blocks,1)
        if ~exist(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'file')
            load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_StimTimes.mat']),'StimOffsets');
            arr = [repmat(("P1"),32,1);repmat(("P2"),32,1)];
            trial_data = cell(64,1);
            shuffled_trials = cell(64,1);
            sig_response = zeros(64,1);
            mean_rate = cell(64,1);
            mean_spiking = zeros(64,1);
            stdev_spiking = zeros(64,1);
            seed = randi(64,64,1);
            pk_latency = zeros(64,1);
            pk_rate = zeros(64,1);
            blank_win = zeros(64,1);
            chPlot = table(arr,txt_id,seed,trial_data,shuffled_trials,sig_response,...
                mean_rate,mean_spiking,stdev_spiking,pk_latency,pk_rate,...
                'VariableNames',{'arr','ch','seed','trial_data','shuffled_trials','sig_response',...
                'mean_rate','mean_spiking','stdev_spiking','pk_latency','pk_rate'});
            % iteratively accesses files associated with the channels
            for ii = 1:numel(reArr) % channels in plotting order
                chID = txt_id{ii};
                r = reArr(ii);
                rng(seed(ii));
                if r <= 32
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),in_folder],...
                        [char(C.Blocks(i)),'_ptrain_P1_',chID,'.mat']));
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_Filtered_StimSmoothed'],...
                        [char(C.Blocks(i)),'_Filt_P1_',chID,'.mat']),'pars');
                else
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),in_folder],...
                        [char(C.Blocks(i)),'_ptrain_P2_',chID,'.mat']));
                    load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),'_Filtered_StimSmoothed'],...
                        [char(C.Blocks(i)),'_Filt_P2_',chID,'.mat']),'pars');
                end
                sp = [];
                shuf = [];
                for iii = 1:numel(StimOffsets)
                    trial = StimOffsets(iii);
                    fill = (peak_train(trial:trial + 6000))';
                    ss = find(fill);
                    ss = 1000*ss/fs;
                    allSp = vertcat(allSp,ss);
                    sp = [sp; fill];
                    shIdx = randperm(6001);
                    fill = fill(shIdx);
                    shuf = [shuf; fill];
                end
                chPlot.trial_data{ii} = sp;
                chPlot.shuffled_trials{ii} = shuf;
                sSp = sum(sp,1);
                sShuf = sum(shuf,1);
                chPlot.mean_spiking(ii) = mean(sShuf,2);
                chPlot.stdev_spiking(ii) = std(sShuf,0,2);
                mIdx = sSp > (chPlot.mean_spiking(ii) + chPlot.stdev_spiking(ii));
                [r,rIdx] = max(sSp(mIdx));
                chPlot.pk_rate(ii) = r;
                l = find(mIdx);
                chPlot.pk_latency(ii) = (l(rIdx) * 1000)/fs;
                [sr,~] = ksdensity(allSp,0:0.0333:200,'Bandwidth',0.2);
                chPlot.mean_rate{ii} = sr;
            end
            save(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'chPlot');
        else
            load(fullfile(C.Dir{i},[char(C.Blocks(i))],[char(C.Blocks(i)),out_file]),'chPlot');
        end
    end
end