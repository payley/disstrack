%% Determine mean firing rates
%% Make table with mean firing rates for inj animals
% if not re-run, open blocklist.m for listBl variable
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
idxT = ~isnan(listBl.exp_time);
listBlI = listBl(idxT,:); % new table with only injured animals
[uniq,idxU] = unique(listBlI(:,[1,4])); % find unique blocks for each experimental timepoint
nUniq = numel(idxU);
nAn = numel(unique(uniq.animal_name));
preInj = cell(nAn,1);
postInj1 = cell(nAn,1);
postInj2 = cell(nAn,1);
postInj3 = cell(nAn,1);
postInj4 = cell(nAn,1);
listMFR = table(preInj,postInj1,postInj2,postInj3,postInj4); % create table to store mfr data for each channel
listMFR.Properties.RowNames = unique(uniq.animal_name);
for i = 1:nUniq % create an entry in the table for every animal/date combination
    refN = idxU(i);
    check = listBlI(refN,[1,4]);
    c = ismember(listBlI(:,[1,4]),check,"rows"); % find any days with multiple blocks
    if sum(c) == 1 
        load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat'])); % load file
        nCh = numel(blockObj.Channels);
        hMFR = zeros(nCh,1);
        t = blockObj.Samples/blockObj.SampleRate; % block length, should be in sec
        for ii = 1:nCh
            sp = numel(blockObj.getSpikeTrain(ii)); % number of spikes (in samples? check in documentation)
            hMFR(ii) = sp/t; % spikes/sec
        end
        idxR = find(contains(listMFR.Properties.RowNames,listBlI.animal_name{refN})); % row number based on animal name
        idxC = listBlI.exp_time(refN) + 1; % column number based on timepoint
        listMFR(idxR,idxC) = {hMFR};
    else % takes into account multiple blocks for a session
        nbl = sum(c); 
        mBl{1} = load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat']));
        nCh = numel(mBl{1}.blockObj.Channels);
        hVal = zeros(nCh,nbl);
        t(1) = mBl{1}.blockObj.Samples/mBl{1}.blockObj.SampleRate;
        for ii = 1:nCh
            hVal(ii,1) = numel(mBl{1}.blockObj.getSpikeTrain(ii)); 
        end
        for cc = 2:nbl
            f = find(c);
            iC = f(cc);
            mBl{cc} = load(fullfile(cDir,listBlI.animal_name{iC},[listBlI.block_name{iC} '_Block.mat']));
            t(cc) = mBl{cc}.blockObj.Samples/mBl{cc}.blockObj.SampleRate;
            for ii = 1:nCh
                hVal(ii,cc) = numel(mBl{cc}.blockObj.getSpikeTrain(ii)); 
            end
            fOrd1 = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
            fOrd2 = contains(listBlI.array_order{iC}{1},listBlI.reach{iC});
            if ~isequal(fOrd1,fOrd2) % added to address the split block where the areas were switched
                holdVal = hVal(:,cc);
                hVal(1:32,cc) = holdVal(33:64,1);
                hVal(33:64,cc) = holdVal(1:32,1);
            end
        end
        hMFR = sum(hVal,2)./sum(t);
        idxR = find(contains(listMFR.Properties.RowNames,listBlI.animal_name{refN}));
        idxC = listBlI.exp_time(refN) + 1;
        listMFR(idxR,idxC) = {hMFR};
    end
clearvars -except listBl listBlI listMFR nUniq idxU tankObj cDir
end

%% Alternate method for finding mean firing rate of missing blocks
% uses stim assay data, have to go to the stim folders for each
dd = dir(cd);
dd = dd(~ismember({dd.name},{'.','..'}));
hmfr = [];
for i = 1:numel(dd)
    load(dd(i).name);
    fs = pars.FS;
    t = length(peak_train)/fs;
    sp = size(spikes,1);
    hmfr = [hmfr; sp/t];
end
%% Expand table to include average mean firing rates and mean firing rates by area
% listed as injured hemisphere to uninjured hemisphere, L to R
if ~(exist('listBlI','var'))
    load('block_list.mat')
    idxT = ~isnan(listBl.exp_time);
    listBlI = listBl(idxT,:);
    cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
end
r = size(listMFR,1);
c = 5;
% finds overall average mean firing rate for a block
listMFR.mean_preInj = cellfun(@mean,listMFR.preInj);
listMFR.mean_postInj1 = cellfun(@mean,listMFR.postInj1);
listMFR.mean_postInj2 = cellfun(@mean,listMFR.postInj2);
listMFR.mean_postInj3 = cellfun(@mean,listMFR.postInj3);
listMFR.mean_postInj4 = cellfun(@mean,listMFR.postInj4);
% set-up to determine by area
listMFR.area_preInj = nan(r,2);
listMFR.area_postInj1 = nan(r,2);
listMFR.area_postInj2 = nan(r,2);
listMFR.area_postInj3 = nan(r,2);
listMFR.area_postInj4 = nan(r,2);
for i = 1:r % loop for each row
    for ii = 1:5 % loop for each column
        out = ii + 10;
        idxR = contains(listBlI.animal_name,listMFR.Properties.RowNames(i));
        idxC = listBlI.exp_time == ii - 1;
        idxB = idxR & idxC;
        if sum(idxB) > 1 % isolates a single block for metadata
            idxF = find(idxB,1,'first');
            idxB = false(size(idxR));
            idxB(idxF) = 1;
        elseif sum(idxB) < 1 % skips blocks without data
            continue
        end
        fOrd = contains(listBlI.array_order{idxB}{1},listBlI.reach{idxB}); % ids the array in the injured hemisphere
        if numel(listMFR{i,ii}{1}) == 64
            if fOrd == 1
                ch{1} = 33:64;
                ch{2} = 1:32;
            else
                ch{1} = 1:32;
                ch{2} = 33:64;
            end
            for iii = 1:2
                listMFR{i,out}(iii) = mean(listMFR{i,ii}{1}(ch{iii}));
            end
        else % handles any arrays with deviations from standard 32ch
            load(fullfile(cDir,listBlI.animal_name{idxB},[listBlI.block_name{idxB} '_Block.mat']),'blockObj');
            aa = [blockObj.Channels.port_number]';
            [nChs,~] = groupcounts(aa);
            if fOrd == 1
                nch{1} = (nChs(1)+1):(nChs(1)+nChs(2));
                nch{2} = 1:nChs(1);
            else
                nch{1} = 1:nChs(1);
                nch{2} = (nChs(1)+1):(nChs(1)+nChs(2));
            end
            for iii = 1:2
                listMFR{i,out}(iii) = mean(listMFR{i,ii}{1}(nch{iii}));
            end
        end
    end
end
%% All mean firing rates by area
% listed as injured hemisphere to uninjured hemisphere, L to R
if ~(exist('listBlI','var'))
    load('block_list.mat')
    idxT = ~isnan(listBl.exp_time);
    listBlI = listBl(idxT,:);
    cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
end
r = size(listMFR,1);
c = 5;
listMFR_H = cell(2,1);
for i = 1:r % loop for each row
    for ii = 1:5 % loop for each column
        out = ii;
        idxR = contains(listBlI.animal_name,listMFR.Properties.RowNames(i));
        idxC = listBlI.exp_time == ii - 1;
        idxB = idxR & idxC;
        if sum(idxB) > 1 % isolates a single block for metadata
            idxF = find(idxB,1,'first');
            idxB = false(size(idxR));
            idxB(idxF) = 1;
        elseif sum(idxB) < 1 % skips blocks without data
            continue
        end
        fOrd = contains(listBlI.array_order{idxB}{1},listBlI.reach{idxB}); % ids the array in the injured hemisphere
        if numel(listMFR{i,ii}{1}) == 64
            if fOrd == 1
                ch{1} = 33:64;
                ch{2} = 1:32;
            else
                ch{1} = 1:32;
                ch{2} = 33:64;
            end
            for iii = 1:2
                listMFR_H{iii}{i,out} = listMFR{i,ii}{1}(ch{iii});
            end
        else % handles any arrays with deviations from standard 32ch
            load(fullfile(cDir,listBlI.animal_name{idxB},[listBlI.block_name{idxB} '_Block.mat']),'blockObj');
            aa = [blockObj.Channels.port_number]';
            [nChs,~] = groupcounts(aa);
            if fOrd == 1
                nch{1} = (nChs(1)+1):(nChs(1)+nChs(2));
                nch{2} = 1:nChs(1);
            else
                nch{1} = 1:nChs(1);
                nch{2} = (nChs(1)+1):(nChs(1)+nChs(2));
            end
            for iii = 1:2
                listMFR_H{iii}{i,out} = listMFR{i,ii}{1}(nch{iii});
            end
        end
    end
end
listMFR_H{1}{5,1} = listMFR{5,1}{1}(1:32,1);
listMFR_H{2}{5,1} = listMFR{5,1}{1}(33:64,1);
listMFR_H{1}{4,1} = listMFR{5,1}{1}(33:64,1);
listMFR_H{2}{4,1} = listMFR{5,1}{1}(1:32,1);
%% Plot figures
% plot averages as points
figure;
hold on
plot(listMFR{:,6:10}','Color',[0.7 0.7 0.7])
plot(listMFR{:,6:10}','square','Color','k','MarkerFaceColor','k')
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([0 20]);
xlim([0.5 5.5]);
yticks(0:4:20)
xticks(1:5)
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('MFR (spikes/s)')
title('Average MFR for each animal')

% boxplot of average distribution
figure;
hold on
boxchart(listMFR{:,6:10})
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylim([0 20]);
ylabel('MFR (spikes/s)')
title('Distribution of average MFRs')

% barplots of total distributions
h = [];
gr = [];
for i = 1:5
    h = [h; cell2mat(listMFR{:,i})];
    nEl = numel(cell2mat(listMFR{:,i}));
    gr = [gr; repmat(i,nEl,1)];
end
figure;
boxchart(gr,h)
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
xticks(1:5);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('MFR (spikes/s)')
title('Distribution of all MFRs')

% violin plots of average distributions
figure;
hold on
for i = 1:5
    h = cell2mat(listMFR{:,i});
    x = linspace(prctile(h,0),prctile(h,100),100);
    [f,xi] = ksdensity(h,x,'Bandwidth',0.5);
    a = i*1.5;
    patch([a-f,fliplr(a+f)],[xi,fliplr(xi)],[0.3010 0.7450 0.9330],'LineStyle','none');
    m = median(h);
    line(linspace((a-0.15),(a+0.15),10),repmat(m,1,10),'Color','black');
end
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
xticks(0.5:0.5:2.5);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('MFR (spikes/s)')
title('Distribution of all MFRs')

% scatterplot of average distribution by area
hI = [];
hU = [];
gr = [];
for i = 11:15
n = (i-10)*2;
hI = [hI; listMFR{:,i}(:,1)];
hU = [hU; listMFR{:,i}(:,2)];
nEl = numel(listMFR{:,i}(:,1));
gr = [gr; repmat(n,nEl,1)];
end
% figure;
% boxchart(gr,hI)
% figure;
% boxchart(gr,hU)
figure;
hold on
hComb = [hI; hU];
grComb = [gr; gr];
cat = [zeros(length(hI),1);ones(length(hI),1)];
b = boxchart(grComb,hComb,'GroupByColor',cat);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
xticks(2:2:10);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
legend('Injured hemisphere','Uninjured hemisphere');
legend('boxoff')
ylabel('MFR (spikes/s)')
title('Distribution of MFR')

% % scatterplot of average distribution by area
% figure;
% hold on
% hI = [listMFR{:,11}(:,1),listMFR{:,12}(:,1),listMFR{:,13}(:,1),listMFR{:,14}(:,1),listMFR{:,15}(:,1)];
% hU = [listMFR{:,11}(:,2),listMFR{:,12}(:,2),listMFR{:,13}(:,2),listMFR{:,14}(:,2),listMFR{:,15}(:,2)];
% plot(hI','o','Color','k','MarkerFaceColor','k');
% plot(hU','o','Color','k','MarkerFaceColor','b');
%% Make table with mean firing rates for uninj animals
% if not re-run, open blocklist.m for listBl variable
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
idxC = ~isnan(listBl.incl_control) & listBl.incl_control < 60;
idxE = strcmp('0-220907-175314',listBl.block_name) |  strcmp('0-220912-150559',listBl.block_name); % eliminate bad blocks
idxC = idxC & ~idxE;
listBlI = listBl(idxC,:); % new table with only unjured animals
[uniq,idxU] = unique(listBlI(:,[1,7])); % find unique blocks for each experimental timepoint
nUniq = size(uniq,1);
mfr = cell(nUniq,1); 
listMFR_ctrl = [uniq mfr];
listMFR_ctrl.Properties.VariableNames(end) = {'mfr'};
for i = 1:nUniq % create an entry in the table for every animal/date combination
    refN = idxU(i);
    check = listBlI(refN,[1,7]);
    c = ismember(listBlI(:,[1,7]),check,"rows"); % find any days with multiple blocks
    if sum(c) == 1 
        load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat'])); % load file
        nCh = numel(blockObj.Channels);
        hMFR = zeros(nCh,1);
        t = blockObj.Samples/blockObj.SampleRate; % block length, should be in sec
        for ii = 1:nCh
            sp = numel(blockObj.getSpikeTrain(ii)); % number of spikes (in samples? check in documentation)
            hMFR(ii) = sp/t; % spikes/sec
        end
        listMFR_ctrl(i,3) = {hMFR};
    else % takes into account multiple blocks for a session
        nbl = sum(c); 
        mBl{1} = load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat']));
        nCh = numel(mBl{1}.blockObj.Channels);
        hVal = zeros(nCh,nbl);
        t(1) = mBl{1}.blockObj.Samples/mBl{1}.blockObj.SampleRate;
        for ii = 1:nCh
            hVal(ii,1) = numel(mBl{1}.blockObj.getSpikeTrain(ii)); 
        end
        for cc = 2:nbl
            f = find(c);
            iC = f(cc);
            mBl{cc} = load(fullfile(cDir,listBlI.animal_name{iC},[listBlI.block_name{iC} '_Block.mat']));
            t(cc) = mBl{cc}.blockObj.Samples/mBl{cc}.blockObj.SampleRate;
            for ii = 1:nCh
                hVal(ii,cc) = numel(mBl{cc}.blockObj.getSpikeTrain(ii)); 
            end
            fOrd1 = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
            fOrd2 = contains(listBlI.array_order{iC}{1},listBlI.reach{iC});
            if ~isequal(fOrd1,fOrd2) % added to address the split block where the areas were switched
                holdVal = hVal(:,cc);
                hVal(1:32,cc) = holdVal(33:64,1);
                hVal(33:64,cc) = holdVal(1:32,1);
            end
        end
        hMFR = sum(hVal,2)./sum(t);
        listMFR_ctrl(i,3) = {hMFR};
    end
clearvars -except listBlI listMFR_ctrl tankObj cDir idxU
end
listMFR_ctrl.mean_mfr = cellfun(@mean,listMFR_ctrl.mfr);
%% Plot mean values of control/uninjured animals over time
figure;
hold on
scatter(listMFR_ctrl.incl_control,listMFR_ctrl.mean_mfr,'filled');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
xlabel('Post-implant time (days)');
ylabel('MFR (spikes/s)');
title('Intrinsic variability of MFR measured by arrays')
ylim([0 25])
%% Make a variable corresponding to MFR for every block
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
if ~exist('listMFR','var')
    load('C:\MyRepos\disstrack\BA\mfr_list.mat')
end
if ~exist('ctrl_mfr_list','var')
    load('C:\MyRepos\disstrack\BA\ctrl_mfr_list.mat')
end
nBl = size(listBl,1);
ch_mfr = cell(nBl,1);
for i = 1:nBl
    if listBl.exp_group(i) == 1 && ~isnan(listBl.exp_time(i))
        idxR = contains(listMFR.Properties.RowNames,listBl.animal_name{i});
        idxC = listBl.exp_time(i) + 1;
        ch_mfr{i} = listMFR{idxR,idxC}{1} > 1; % 1Hz threshold
        if contains(listBl.array_order{i}{1},listBl.reach{i}) % ordered for channels in inj hemisphere are first, NOT native order
            ch_mfr{i} = ch_mfr{i}([33:64,1:32],:); 
        end
    elseif isnan(listBl.exp_time(i)) && listBl.incl_control(i) < 60 && sum(contains({'R22-28','R22-29'},listBl.animal_name{i})) == 0
        idxC = contains([listMFR_ctrl.animal_name],listBl.animal_name{i}) & listMFR_ctrl.incl_control == listBl.incl_control(i);
        ch_mfr{i} = listMFR_ctrl.mfr{idxC} > 1;
        if contains(listBl.array_order{i}{1},listBl.reach{i}) % ordered for channels in inj hemisphere are first, NOT native order
            ch_mfr{i} = ch_mfr{i}([33:64,1:32],:);
        end
    else
        ch_mfr{i} = [];
    end
end
%% Statistic on the number of channels included based on 1Hz threshold
ch_mfr = ch_mfr(~cellfun(@isempty,ch_mfr));
ch_mfr(1:2) = [];
incl = sum(cellfun(@sum,ch_mfr));
tot = sum(cellfun(@numel,ch_mfr));
prop = (incl/tot)*100;
fprintf('%2.1f percent of channels are included based on 1Hz MFR threshold\n',prop);