%% set conditions for statistical tests
% either 'activity' for testing for the presence of evoked activity,
% 'time' for testing evoked activity across days,
% 'group' for testing groups of evoked activity against each other (i.e.
% somatotopically grouped channels)
test = 'activity'; 
time_win = [0 10]; % timing of interest in ms 
%% select data
load('SEC_list.mat')
load('SEC_DataStructure.mat')
switch test
    case 'activity'
        [C,~] = select_data(L,DataStructure,1);
        while size(C,1) > 2
            disp('Please only select one block')
            [C,~] = select_data(L,DataStructure,1);
        end
        [idxBl,~] = listdlg('PromptString','Select run:','ListString',C.Blocks,'SelectionMode','single');
        probes = {'P1','P2'};
        [idxP,~] = listdlg('PromptString','Select probe:','ListString',probes,'SelectionMode','single');
        probe = probes(idxP);
        channels = compose('Ch_%03d',0:31);
        [idxCh,~] = listdlg('PromptString','Select channel:','ListString',channels);
        channel = channels(idxCh);
        if numel(channels) == 1
            disp(join([C.Blocks(idxBl) probe channel]));
        else
            disp(join([C.Blocks(idxBl) probe]));
        end
    case 'time'
        [C,~] = select_data(L,DataStructure,1);
        [idxA,~] = listdlg('PromptString','Select block 1:','ListString',C.Blocks,'SelectionMode','single');
        [idxB,~] = listdlg('PromptString','Select block 2:','ListString',C.Blocks,'SelectionMode','single');
        probes = {'P1','P2'};
        [idxP,~] = listdlg('PromptString','Select probe:','ListString',probes,'SelectionMode','single');
        probe = probes(idxP);
        channels = compose('Ch_%03d',0:31);
        [idxCh,~] = listdlg('PromptString','Select channel:','ListString',channels,'SelectionMode','single');
        channel = channels(idxCh);
        disp(join([C.Blocks(idxA) 'vs' C.Blocks(idxB) probe channel]));
    case 'group'
        disp('work in progress :(((')
end
%% run Kolmogorov-Smirnov test
switch test
    case 'activity'
        if numel(channel) == 1
            c = C(idxBl,:);
            [chPlot] = channel_stats(c,pars);
            idxPl = find(strcmp(string(chPlot.arr),probe{1}) & strcmp(string(chPlot.ch),channel{1}));
            if numel(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                    & chPlot.all_evoked_spikes{idxPl} > time_win(1))) == 0 |...
                    chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                    & chPlot.all_shuffled_spikes{idxPl} > time_win(1)) == 0
                p = nan;
            else
                e = fitdist(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                    & chPlot.all_evoked_spikes{idxPl} > time_win(1)), 'Kernel','Bandwidth',0.5);
                s = fitdist(chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                    & chPlot.all_shuffled_spikes{idxPl} > time_win(1)), 'Kernel','Bandwidth',0.5);
                cdfE = cdf(e,time_win(1):0.1:time_win(2));
                cdfS = cdf(s,time_win(1):0.1:time_win(2));
                [ks,idxK] = (max(abs(cdfE - cdfS)));
                n1 = numel(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                    & chPlot.all_evoked_spikes{idxPl} > time_win(1)));
                n2 = numel(chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                    & chPlot.all_shuffled_spikes{idxPl} > time_win(1)));
                n = n1 * n2 /(n1 + n2);
                lambda = max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * ks, 0);
                j = (1:101)';
                pValue = 2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
                p = min(max(pValue, 0), 1);
            end
            chPlot.sig_response(idxPl) = p;
            figure;
            hold on
            plot(cdfE);
            plot(cdfS);
            plot([idxK idxK],[cdfE(idxK) cdfS(idxK)])
            title(p);
%             save(fullfile([c.dir,c.blocks,'_stats_swtteo.mat']),'chPlot', '-v7.3');
        else
            c = C(idxBl,:);
            pars = [];
            [chPlot] = channel_stats(c,pars);
            for i = 1:numel(channel)
                idxPl = find(strcmp(string(chPlot.arr),probe{1}) & strcmp(string(chPlot.ch),channel{i}));
                if numel(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                        & chPlot.all_evoked_spikes{idxPl} > time_win(1))) == 0 |...
                        chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                        & chPlot.all_shuffled_spikes{idxPl} > time_win(1)) == 0
                    p = nan;
                else
                    e = fitdist(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                        & chPlot.all_evoked_spikes{idxPl} > time_win(1)), 'Kernel','Bandwidth',0.5);
                    s = fitdist(chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                        & chPlot.all_shuffled_spikes{idxPl} > time_win(1)), 'Kernel','Bandwidth',0.5);
                    cdfE = cdf(e,time_win(1):0.1:time_win(2));
                    cdfS = cdf(s,time_win(1):0.1:time_win(2));
                    [ks,~] = (max(abs(cdfE - cdfS)));
                    n1 = numel(chPlot.all_evoked_spikes{idxPl}(chPlot.all_evoked_spikes{idxPl} < time_win(2)...
                        & chPlot.all_evoked_spikes{idxPl} > time_win(1)));
                    n2 = numel(chPlot.all_shuffled_spikes{idxPl}(chPlot.all_shuffled_spikes{idxPl} < time_win(2)...
                        & chPlot.all_shuffled_spikes{idxPl} > time_win(1)));
                    n = n1 * n2 /(n1 + n2);
                    lambda = max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * ks, 0);
                    j = (1:101)';
                    pValue = 2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
                    p = min(max(pValue, 0), 1);
                end
                chPlot.sig_response(idxPl) = p;
            end
            save(fullfile(c.Dir{1},char(c.Blocks),[char(c.Blocks) '_stats_swtteo.mat']),'chPlot', '-v7.3');
        end
    case 'time'
        c1 = C(idxA,:);
        c2 = C(idxB,:);
        pars = [];
        [chPlot1] = channel_stats(c1,pars);
        [chPlot2] = channel_stats(c2,pars);
        idxPl1 = find(strcmp(string(chPlot1.arr),probe{1}) & strcmp(string(chPlot1.ch),channel{1}));
        idxPl2 = find(strcmp(string(chPlot2.arr),probe{1}) & strcmp(string(chPlot2.ch),channel{1}));
        if numel(chPlot.all_evoked_spikes{idxPl1}(chPlot.all_evoked_spikes{idxPl1} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl1} > time_win(1))) == 0 |...
                chPlot.all_evoked_spikes{idxPl2}(chPlot.all_evoked_spikes{idxPl2} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl2} > time_win(1)) == 0
            p = nan;
        else
            e = fitdist(chPlot.all_evoked_spikes{idxPl1}(chPlot.all_evoked_spikes{idxPl1} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl1} > time_win(1)), 'Kernel','Bandwidth',0.5);
            e2 = fitdist(chPlot.all_evoked_spikes{idxPl2}(chPlot.all_evoked_spikes{idxPl2} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl2} > time_win(1)), 'Kernel','Bandwidth',0.5);
            cdfE1 = cdf(e1,time_win(1):0.1:time_win(2));
            cdfE2 = cdf(e2,time_win(1):0.1:time_win(2));
            [ks,idxK] = (max(abs(cdfE1 - cdfE2)));
            n1 = numel(chPlot.all_evoked_spikes{idxPl1}(chPlot.all_evoked_spikes{idxPl1} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl1} > time_win(1)));
            n2 = numel(chPlot.all_evoked_spikes{idxPl2}(chPlot.all_evoked_spikes{idxPl2} < time_win(2)...
                & chPlot.all_evoked_spikes{idxPl2} > time_win(1)));
            n = n1 * n2 /(n1 + n2);
            lambda = max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * ks, 0);
            j = (1:101)';
            pValue = 2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
            p = min(max(pValue, 0), 1);
        end
        figure;
        hold on
        plot(cdfE1);
        plot(cdfE2);
        plot([idxK idxK],[cdfE1(idxK) cdfE2(idxK)])
        title(p);
    case 'group'
        disp('work in progress :(((')
end
