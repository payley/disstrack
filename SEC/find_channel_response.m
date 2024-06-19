%% Pull out channels with a response
% load L and DataStructure
[C,sel] = select_data(L,DataStructure,1);
ct = 50; % time window in ms following stim
bin_sz = 0.5; % bin size in ms
ns_bins = 30000 * (bin_sz/1000); % samples assigned to each bin
samp = 200/bin_sz + 1; % downsampled number
for i = 1:2 % runs both blocks for a recording date
    load(fullfile(C.Dir{i},C.Blocks{i},[C.Blocks{i} '_stats_swtteo.mat']));
    ch_id = [];
    arr_id = [];
    stim_array = [];
    tr_timing = [];
    pk_timing = [];
    if  sum(strcmp(chPlot.Properties.VariableNames,'baseline')) < 1
        meta = split(C.Blocks{i},'_');
        idxR = contains({DataStructure.AnimalName},meta{1});
        idxD = contains(DataStructure(idxR).DateStr,join(meta(2:4),'_'));
        idxBl = DataStructure(idxR).Run{idxD}(1);
        block_id = join([meta(1:4);num2str(idxBl)],'_');
        f_loc = fullfile(DataStructure(idxR).NetworkPath,DataStructure(idxR).AnimalName,block_id,join([block_id,'SD_SWTTEO'],'_'));
        chPlot = base_spiking(chPlot,'catch',bin_sz,ct,f_loc,size(chPlot.evoked_trials{1},1));
        save(fullfile(C.Dir{i},C.Blocks{i},[C.Blocks{i} '_stats_swtteo.mat']),'chPlot');
    end
    for ii = 1:64
        upthresh = chPlot.z_mean{ii} + (chPlot.z_std{ii}*3);
        lowthresh = chPlot.z_mean{ii} - (chPlot.z_std{ii}*3);
        [bSp,edge] = histcounts(chPlot.all_evoked_spikes{ii},linspace(0,200,samp));
        tr = min(reshape(chPlot.blank_win{ii},[ns_bins,size(chPlot.blank_win{ii},2)/ns_bins]))';
        bSp = (bSp./tr(find(edge == ct)-1));
        bSp = bSp(1:(ct/bin_sz));
        idxCh = bSp > upthresh | bSp < lowthresh;
        if sum(idxCh) > 0
            blank = bin_data(chPlot.blank_win{ii},bin_sz,30000);
            blank = blank(1:(ct/bin_sz));
            tr = find(bSp < lowthresh & blank > 0);
            tr = {tr * bin_sz};
            pk = {find(bSp > upthresh) * bin_sz};
            if ~isempty(tr) || ~isempty(pk)
                ch_id = [ch_id; chPlot.ch{ii}];
                arr_id = [arr_id; chPlot.arr{ii}];
                st_arr = compose('P%d',C.Stim_Probe(i));
                if contains(st_arr,chPlot.arr(ii))
                    aa = 1;
                else
                    aa = 0;
                end
                stim_array = [stim_array; aa];
                tr_timing = [tr_timing; tr];
                pk_timing = [pk_timing; pk];
            end
        end
    end
chResp = table(ch_id,arr_id,stim_array,tr_timing,pk_timing);
save(fullfile(C.Dir{i},C.Blocks{i},[C.Blocks{i} '_chResp.mat']),'chResp');
end
%% Compile multiple block results to make a histogram of the responses
% make a plot of all the different suppression and excitation
listGr = [];
while 1
    [idxA,~] = listdlg('PromptString','Select animal:','ListString',{DataStructure.AnimalName},'SelectionMode','single');
    [idxD,~] = listdlg('PromptString','Select date:','ListString',DataStructure(idxA).DateStr,'SelectionMode','single');
    [idxR,~] = listdlg('PromptString','Select block:','ListString',string(DataStructure(idxA).Run{idxD}([2,4])),'SelectionMode','single');
    rr = ['2','4'];
    gg = join({DataStructure(idxA).AnimalName,DataStructure(idxA).DateStr{idxD},rr(idxR)},'_');
    fprintf('Block %s selected\n',gg{1});
    listGr = [listGr; gg];
    [aa,~] = listdlg('PromptString','Select another block?','ListString',{'Yes','No'},'SelectionMode','single');
    if aa == 2
        break
    end
end
[idxS,~] = listdlg('PromptString','Select which arrays to assess:','ListString',{'Stim','No stim','Both'},'SelectionMode','single');
root = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
allResp = [];
for i = 1:size(listGr,1)
    meta = split(listGr{i},'_');
    f_loc = fullfile(root,meta{1},listGr{i});
    cd(f_loc)
    load([listGr{i} '_chResp.mat']);
    chResp.block = repmat(listGr{i},size(chResp,1),1);
    switch idxS
        case 1
            subs = chResp.stim_array == 1;
        case 2
            subs = chResp.stim_array == 0;
        case 3
            subs = ones(size(chResp,1),1);
    end
    allResp = [allResp; chResp(subs,:)];
end

tt = (1:100) - 0.5;
pks = cell2mat(allResp.pk_timing');
[bP,~] = histcounts(pks,linspace(0,50,101));
figure;
bar(tt,bP);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xlim([0 100]);
xticklabels(0:10:50);
title('Incidence of peaks in spiking');

trs = cell2mat(allResp.tr_timing');
[bT,~] = histcounts(trs,linspace(0,50,101));
figure;
bar(tt,bT);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xlim([0 100]);
xticklabels(0:10:50);
title('Incidence of troughs in spiking');
