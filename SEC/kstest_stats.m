%% set conditions for statistical tests
% either 'activity' for testing for the presence of evoked activity,
% 'time' for testing evoked activity across days,
% 'group' for testing groups of evoked activity against each other (i.e.
% somatotopically grouped channels)
test = 'activity'; 
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
        [idxA,~] = listdlg('PromptString','Select block 1:','ListString',{C.Blocks},'SelectionMode','single');
        [idxB,~] = listdlg('PromptString','Select block 2:','ListString',{C.Blocks},'SelectionMode','single');
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
            idxPl = find(strcmp(string(chPlot.arr),probe{1}) & strcmp(string(chPlot.ch),channel{i}));
            mean_evoked_rate = chPlot.mean_evoked_rate{idxPl};
            mean_shuffled_rate = chPlot.mean_shuffled_rate{idxPl};
            time = 0:0.1:10;
            idxT = time < (chPlot.blank_win(idxPl)/fs);
            mean_evoked_rate(idxT) = 0;
            mean_shuffled_rate(idxT) = 0;
            [h,p] = kstest2(mean_evoked_rate,mean_shuffled_rate,'Alpha',0.005);
            chPlot.sig_response(idxPl) = p;
            save(fullfile([c.dir,c.blocks,'_stats_swtteo.mat']),'chPlot');
        else
            c = C(idxBl,:);
            pars = [];
            [chPlot] = channel_stats(c,pars);
            for i = 1:numel(channel)
                idxPl = find(strcmp(string(chPlot.arr),probe{1}) & strcmp(string(chPlot.ch),channel{i}));
                mean_evoked_rate = chPlot.mean_evoked_rate{idxPl};
                mean_shuffled_rate = chPlot.mean_shuffled_rate{idxPl};
                time = linspace(0,0.01,101);
                idxT = time < (chPlot.blank_win(idxPl)/fs);
                mean_evoked_rate(idxT) = 0;
                mean_shuffled_rate(idxT) = 0;
                [~,p] = kstest2(mean_evoked_rate,mean_shuffled_rate,'Alpha',0.005);
                chPlot.sig_response(idxPl) = p;
            end
            save(fullfile(c.Dir{1},char(c.Blocks),[char(c.Blocks) '_stats_swtteo.mat']),'chPlot');
        end
        case 'time'
            c1 = C(idxA,:);
            c2 = C(idxB,:);
            pars = [];
            [chPlot1] = channel_stats(c1,pars);
            [chPlot2] = channel_stats(c2,pars);
            idxPl1 = find(strcmp(string(chPlot1.arr),probe{1}) & strcmp(string(chPlot1.ch),channel{i}));
            idxPl2 = find(strcmp(string(chPlot2.arr),probe{1}) & strcmp(string(chPlot2.ch),channel{i}));
            mean_evoked_rate1 = chPlot1.mean_evoked_rate{idxPl1};
            mean_evoked_rate2 = chPlot2.mean_evoked_rate{idxPl2};
            time = 0:0.1:10;
            idxT1 = time < (chPlot.blank_win(idxPl1)/fs);
            idxT2 = time < (chPlot.blank_win(idxPl2)/fs);
            mean_evoked_rate1(idxT1) = 0;
            mean_evoked_rate2(idxT2) = 0;
            [~,p] = kstest2(mean_evoked_rate1,mean_evoked_rate2,'Alpha',0.005);
        case 'group'
            disp('work in progress :(((')
end
