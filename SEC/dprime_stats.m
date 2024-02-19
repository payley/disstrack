%% set conditions for statistical tests
% either 'activity' for testing for the presence of evoked activity,
% 'time' for testing evoked activity across days,
% 'group' for testing groups of evoked activity against each other (i.e.
% somatotopically grouped channels)
test = 'block';
time_win = [0 10]; % timing of interest in ms
%% select channels
load('SEC_list.mat')
load('SEC_DataStructure.mat')
switch test
    case 'block'
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
end
%% find d' value an calculate significance
switch test
    case 'block'
        for i = 1:numel(channel)
            c = C(idxBl,:);
            pars = [];
            [chPlot] = channel_stats(c,pars);
            idxPl = find(strcmp(string(chPlot.arr),probe{1}) & strcmp(string(chPlot.ch),channel{i}));
            t = time_win(2)*(fs/1000)+1;
            mu_base =  [];
            mu_sig = [];
            std_base = [];
            std_sig = [];
            for ii = 1:1000
                bef = chPlot.pre_trial{idxPl}(end-t:end);
                aft = chPlot.evoked_trials{idxPl}(1:t);
                mu_base = [mu_base mean(bef)];
                mu_sig = [mu_sig mean(aft)];
                std_base = [std_base std(bef)];
                std_sig = [std_sig std(aft)];
            end
            mu_base = mean(mu_base);
            mu_sig = mean(mu_sig);
            std_base = std(std_base);
            std_sig = std(std_sig);
            chPlot.d_prime{idxPl} = (mu_sig - mu_base)./sqrt(0.5*((std_sig^2) + (std_base^2)));
            % calculate 
        end
end
