%% MFR stats
%% Extract MFR values for all channels
% get list of all blocks
C.MFR = cell(size(C,1),5);
for i = 1:size(C,1)
    meta = split(C.Blocks{i},'_');
    idxR = contains({DataStructure.AnimalName},meta{1});
    idxD = contains(DataStructure(idxR).DateStr,join(meta(2:4),'_'));
    for ii = 1:size(DataStructure(idxR).Run{idxD},2)
        idxBl = DataStructure(idxR).Run{idxD}(ii);
        block_id = join([meta(1:4);num2str(idxBl)],'_');
        f_loc = fullfile(DataStructure(idxR).NetworkPath,DataStructure(idxR).AnimalName,block_id,join([block_id,'SD_SWTTEO'],'_'));
        cd(f_loc{1});
        D = dir;
        D(matches({D(:).name},'.')) = [];
        D(matches({D(:).name},'..')) = [];
        reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
            24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
            60 61 62 63 64 53 54 55 56 57 58 49 50 51 52];
        if numel(D) < 64
            reArr = [11 12 13 14 15 16 5 6 7 8 9 10 1 2 3 4 20 19 18 17 26 25 24 23 22 21 ...
                32 31 30 29 28 27 43 44 45 46 47 48 37 38 39 40 41 42 33 34 35 36];
        end
        hMFR = [];
        for iii = 1:numel(D) % runs for every channel
            load(D(reArr(iii)).name,'pars','peak_train');
            sp = numel(peak_train(~peak_train == 0));
            tt = size(peak_train,1)/pars.FS;
            hMFR(iii) = sp/tt;
        end
        C.MFR{i,ii} = hMFR;
    end
end
%% Process table
C.MFR = cellfun(@(x) x',C.MFR,'UniformOutput',false);
ctrl = {'R21-09','R21-10','R22-02'};
C(contains(C.Animal_Name,ctrl),:) = [];
[~,idxU] = unique(C(:,[1,10]));
C(idxU,:) = []; % removes duplicates
C.Week = zeros(size(C,1),1); % make week variable
C.Week(C.PostInj_Time > 0 & C.PostInj_Time <= 7) = 1;
C.Week(C.PostInj_Time > 7 & C.PostInj_Time <= 14) = 2;
C.Week(C.PostInj_Time > 14 & C.PostInj_Time <= 21) = 3;
C.Week(C.PostInj_Time > 21 & C.PostInj_Time <= 28) = 4;
%% Find overall MFR
figure('Position',[100 100 800 500]);
hold on
avgMFR = cell(1,5);
lbl = [];
mfr = [];
for i = 1:5
     hh = C.MFR(C.Week == i - 1);
     avgMFR{i} = cell2mat(hh);
     lbl = [lbl; repmat(i,size(avgMFR{i},1),1)];
     mfr = [mfr; avgMFR{i}];
end
boxplot(mfr,lbl);
ylim([-10 50]);
xlim([0.5 5.5]);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});

mm = [];
ss = [];
figure;
hold on
for i = 1:5
    mm = [mm; mean(avgMFR{i})];
    ss = [ss; std(avgMFR{i})];
end
bar([1:5]',mm);
errorbar([1:5]',mm,ss,'LineStyle','none');
xlim([0.5 5.5]);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
xticks(1:5);
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
%% Divide by array
times = [];
for i = 1:size(C,1)
    if isempty(C.MFR{i,5})
        C.MFRinj{i} = cell(1,4);
        for ii = 1:4
            if C.Inj_Array(i) == 1
                C.MFRinj{i,1}{ii} = C.MFR{i,ii}(1:32);
                C.MFRint{i,1}{ii} = C.MFR{i,ii}(33:64);
            else
                C.MFRinj{i,1}{ii} = C.MFR{i,ii}(33:64);
                C.MFRint{i,1}{ii} = C.MFR{i,ii}(1:32);
            end
        end
    else
        if C.Inj_Array(i) == 1
            if size(C.MFR{i,1},1) == 64
                C.MFRinj{i} = cellfun(@(x) x(1:32),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(33:64),C.MFR(i,:),'UniformOutput',false);
            else
                C.MFRinj{i} = cellfun(@(x) x(1:16),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(17:48),C.MFR(i,:),'UniformOutput',false);
            end
        else
            if size(C.MFR{i,1},1) == 64
                C.MFRinj{i} = cellfun(@(x) x(33:64),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(1:32),C.MFR(i,:),'UniformOutput',false);
            else
                C.MFRinj{i} = cellfun(@(x) x(17:48),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(1:16),C.MFR(i,:),'UniformOutput',false);
            end
        end
    end
end
%% Compare different blocks across time with stimulation
% separate into four conditions
int_stim = [];
inj_stim = [];
int_nostim = [];
inj_nostim = [];
for i = 1:size(C,1)
    if size(C.MFRint{i},2) > 4
        if C.Stim_Probe(i) == C.Inj_Array(i)
            int_stim = [int_stim; C.MFRint{i}(1:3)];
            inj_stim = [inj_stim; C.MFRinj{i}(3:5)];
            int_nostim = [int_nostim; C.MFRint{i}(3:5)];
            inj_nostim = [inj_nostim; C.MFRinj{i}(1:3)];
        else
            int_stim = [int_stim; C.MFRint{i}(3:5)];
            inj_stim = [inj_stim; C.MFRinj{i}(1:3)];
            int_nostim = [int_nostim; C.MFRint{i}(1:3)];
            inj_nostim = [inj_nostim; C.MFRinj{i}(3:5)];
        end
    else
        if C.Stim_Probe(i) == C.Inj_Array(i)
            int_stim = [int_stim; C.MFRint{i}(1:3)];
            inj_stim = [inj_stim; [C.MFRinj{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            int_nostim = [int_nostim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            inj_nostim = [inj_nostim; C.MFRinj{i}(1:3)];
        else
            int_stim = [int_stim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            inj_stim = [inj_stim; C.MFRinj{i}(1:3)];
            int_nostim = [int_nostim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            inj_nostim = [inj_nostim; [C.MFRinj{i}(1:3)]];
        end
    end
end

% add to table 
C.int_stim = int_stim;
C.int_nostim = int_nostim;
C.inj_stim = inj_stim;
C.inj_nostim = inj_nostim;
%% Make a complete table for GLME analysis
% set up variables
an = cell(3,1);
tp = cell(3,1);
inj = cell(3,1);
stim = cell(3,1);
mfr = cell(3,1);

% make table
for i = 1:size(C,1)
    for ii = 1:3 % for each model
        an{ii} = [an{ii}; repmat(C.Animal_Name(i),size(C.int_stim{i,1},1),1); repmat(C.Animal_Name(i),size(C.int_nostim{i,1},1),1);...
            repmat(C.Animal_Name(i),size(C.inj_stim{i,1},1),1); repmat(C.Animal_Name(i),size(C.inj_nostim{i,1},1),1)];
        tp{ii} = [tp{ii}; repmat(C.Week(i),size(C.int_stim{i,1},1),1); repmat(C.Week(i),size(C.int_nostim{i,1},1),1);...
            repmat(C.Week(i),size(C.inj_stim{i,1},1),1); repmat(C.Week(i),size(C.inj_nostim{i,1},1),1)];
        inj{ii} = [inj{ii}; zeros(size(C.int_stim{i,1},1),1); zeros(size(C.int_nostim{i,1},1),1);...
            ones(size(C.inj_stim{i,1},1),1); ones(size(C.inj_nostim{i,1},1),1)];
        stim{ii} = [stim{ii}; ones(size(C.int_stim{i,1},1),1); zeros(size(C.int_nostim{i,1},1),1);...
            ones(size(C.inj_stim{i,1},1),1); zeros(size(C.inj_nostim{i,1},1),1)];
        mfr{ii} = [mfr{ii}; C.int_stim{i,ii}; C.int_nostim{i,ii};...
            C.inj_stim{i,ii}; C.inj_nostim{i,ii}];
    end
end
preT = table(an{1},categorical(tp{1}),inj{1},stim{1},mfr{1},'VariableNames',{'Animal','Timepoint','Inj','Stim','MFR'});
stimT = table(an{2},categorical(tp{2}),inj{2},stim{2},mfr{2},'VariableNames',{'Animal','Timepoint','Inj','Stim','MFR'});
postT = table(an{3},categorical(tp{3}),inj{3},stim{3},mfr{3},'VariableNames',{'Animal','Timepoint','Inj','Stim','MFR'});
%% Run GLME
G = [preT; stimT; postT];
G.Block = [repmat(1,size(preT,1),1); repmat(2,size(preT,1),1); repmat(3,size(preT,1),1)];
G.Block = categorical(G.Block);
formula = 'MFR ~ Inj*Timepoint*Block*Stim + (1|Animal)';
mixed_model = fitglme(G, formula,'Distribution','Normal')
anova(mixed_model)

% formula = 'MFR ~ Inj*Timepoint*Stim + (1|Animal)';
% mixed_model = fitglme(preT, formula,'Distribution','Normal')
% anova(mixed_model)

formula = 'MFR ~ Inj*Timepoint + (1|Animal)';
mixed_model = fitglme(stimT, formula,'Distribution','Normal')
anova(mixed_model)

% formula = 'MFR ~ Inj*Timepoint*Stim + (1|Animal)';
% mixed_model = fitglme(postT, formula,'Distribution','Normal')
% anova(mixed_model)
%% Make corresponding plots
% make plot on the effect of stimulation
figure('Position',[800 50 950 400]);
subplot(1,2,1);
hold on
sc = C.int_nostim;
ns = C.inj_nostim;
sc = cell2mat(sc);
ns = cell2mat(ns);
m_sc = nanmean(sc);
m_ns = nanmean(ns);
std_sc = nanstd(sc);
std_ns = nanstd(ns);
bar([1;2],[m_sc(2); m_ns(2)]);
errorbar([1; 2],[m_sc(2); m_ns(2)],[std_sc(2); std_ns(2)],'LineStyle','none','Color','k');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
ylim([0 30]);
xlim([0 3]);
xticks([1 2]);
xticklabels({'Intact Hemisphere','Injured Hemisphere'});
title('Unstimulated Hemipshere');

subplot(1,2,2);
hold on
sc = C.int_stim;
ns = C.inj_stim;
sc = cell2mat(sc);
ns = cell2mat(ns);
m_sc = nanmean(sc);
m_ns = nanmean(ns);
std_sc = nanstd(sc);
std_ns = nanstd(ns);
bar([1;2],[m_sc(2); m_ns(2)]);
errorbar([1; 2],[m_sc(2); m_ns(2)],[std_sc(2); std_ns(2)],'LineStyle','none','Color','k');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
ylim([0 30]);
xlim([0 3]);
xticks([1 2]);
xticklabels({'Intact Hemisphere','Injured Hemisphere'});
title('Stimulated Hemipshere');

% % make figure for the effect of time
% gr = findgroups(G.Timepoint);
% mm = splitapply(@nanmean,G.MFR,gr)';
% ss = splitapply(@nanstd,G.MFR,gr)';
% figure;
% patch([1:5, flip(1:5)],[mm + ss, flip(mm - ss)],[0.6 0.9370 0.9910],'EdgeColor','none');
% hold on
% plot(1:5,mm,'k')
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% ylabel('MFR (Hz)');
% xticks(1:1:5);
% xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});

% make figure for the effect of time by block
[gr,~,idxG] = findgroups(G.Timepoint,G.Block);
mm = splitapply(@nanmean,G.MFR,gr)';
ss = splitapply(@nanstd,G.MFR,gr)';
figure;
hold on
cc = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
for i = 1:3
    subs = idxG == string(i);
    patch([1:5, flip(1:5)],[mm(subs) + ss(subs), flip(mm(subs) - ss(subs))],[0.6 0.9370 0.9910],'EdgeColor',cc(i,:),'FaceAlpha',.2);
    plot(1:5,mm(subs))
end
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
xticks(1:1:5);
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});

% make figure for the effect of time by injured hemisphere
subG = G(contains(string(G.Block),'2'),:); % select only the stim block
[gr,~,idxG] = findgroups(subG.Timepoint,subG.Inj);
mm = splitapply(@nanmean,subG.MFR,gr)';
ss = splitapply(@nanstd,subG.MFR,gr)';
figure('Position',[100 100 1000 525]);
hold on
for i = 0:1
    subs = idxG == i;
    mm_spl(:,i+1) = mm(subs);
    ss_spl(:,i+1) = ss(subs);
end
bar(1:5,mm_spl);
errorbar([(1:5)-0.15;(1:5)+0.15]',mm_spl,ss_spl,'LineStyle','none','Color','k');
legend({'Intact Hemisphere','Injured Hemisphere'},'Box','off');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');

xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
%% Make control panel
% reload table
C.MFR = cellfun(@(x) x',C.MFR,'UniformOutput',false);
C((C.PostInj_Time > 0),:) = [];
[~,idxU] = unique(C(:,[1,10]));
C(idxU,:) = []; % removes duplicates

% divide by array
times = [];
for i = 1:size(C,1)
    if isempty(C.MFR{i,5})
        C.MFRinj{i} = cell(1,4);
        for ii = 1:4
            if C.Inj_Array(i) == 1
                C.MFRinj{i,1}{ii} = C.MFR{i,ii}(1:32);
                C.MFRint{i,1}{ii} = C.MFR{i,ii}(33:64);
            else
                C.MFRinj{i,1}{ii} = C.MFR{i,ii}(33:64);
                C.MFRint{i,1}{ii} = C.MFR{i,ii}(1:32);
            end
        end
    else
        if C.Inj_Array(i) == 1
            if size(C.MFR{i,1},1) == 64
                C.MFRinj{i} = cellfun(@(x) x(1:32),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(33:64),C.MFR(i,:),'UniformOutput',false);
            else
                C.MFRinj{i} = cellfun(@(x) x(1:16),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(17:48),C.MFR(i,:),'UniformOutput',false);
            end
        else
            if size(C.MFR{i,1},1) == 64
                C.MFRinj{i} = cellfun(@(x) x(33:64),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(1:32),C.MFR(i,:),'UniformOutput',false);
            else
                C.MFRinj{i} = cellfun(@(x) x(17:48),C.MFR(i,:),'UniformOutput',false);
                C.MFRint{i} = cellfun(@(x) x(1:16),C.MFR(i,:),'UniformOutput',false);
            end
        end
    end
end

% separate into four conditions
ipsi_stim = [];
contra_stim = [];
ipsi_nostim = [];
contra_nostim = [];
for i = 1:size(C,1)
    if size(C.MFRint{i},2) > 4
        if C.Stim_Probe(i) == C.Inj_Array(i)
            ipsi_stim = [ipsi_stim; C.MFRint{i}(1:3)];
            contra_stim = [contra_stim; C.MFRinj{i}(3:5)];
            ipsi_nostim = [ipsi_nostim; C.MFRint{i}(3:5)];
            contra_nostim = [contra_nostim; C.MFRinj{i}(1:3)];
        else
            ipsi_stim = [ipsi_stim; C.MFRint{i}(3:5)];
            contra_stim = [contra_stim; C.MFRinj{i}(1:3)];
            ipsi_nostim = [ipsi_nostim; C.MFRint{i}(1:3)];
            contra_nostim = [contra_nostim; C.MFRinj{i}(3:5)];
        end
    else
        if C.Stim_Probe(i) == C.Inj_Array(i)
            ipsi_stim = [ipsi_stim; C.MFRint{i}(1:3)];
            contra_stim = [contra_stim; [C.MFRinj{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            ipsi_nostim = [ipsi_nostim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            contra_nostim = [contra_nostim; C.MFRinj{i}(1:3)];
        else
            ipsi_stim = [ipsi_stim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            contra_stim = [contra_stim; C.MFRinj{i}(1:3)];
            ipsi_nostim = [ipsi_nostim; [C.MFRint{i}(3:4), {nan(size(C.MFRinj{i,1}{1},1),1)}]];
            contra_nostim = [contra_nostim; [C.MFRinj{i}(1:3)]];
        end
    end
end
C.ipsi_stim = ipsi_stim;
C.ipsi_nostim = ipsi_nostim;
C.contra_stim = contra_stim;
C.contra_nostim = contra_nostim;

% set up variables
an = cell(3,1);
tp = cell(3,1);
hemi = cell(3,1);
stim = cell(3,1);
mfr = cell(3,1);

% make table
for i = 1:size(C,1)
    for ii = 1:3 % for each model
        an{ii} = [an{ii}; repmat(C.Animal_Name(i),size(C.ipsi_stim{i,1},1),1); repmat(C.Animal_Name(i),size(C.ipsi_nostim{i,1},1),1);...
            repmat(C.Animal_Name(i),size(C.contra_stim{i,1},1),1); repmat(C.Animal_Name(i),size(C.contra_nostim{i,1},1),1)];
        tp{ii} = [tp{ii}; repmat(C.PostImpl_Time(i),size(C.ipsi_stim{i,1},1),1); repmat(C.PostImpl_Time(i),size(C.ipsi_nostim{i,1},1),1);...
            repmat(C.PostImpl_Time(i),size(C.contra_stim{i,1},1),1); repmat(C.PostImpl_Time(i),size(C.contra_nostim{i,1},1),1)];
        hemi{ii} = [hemi{ii}; zeros(size(C.ipsi_stim{i,1},1),1); zeros(size(C.ipsi_nostim{i,1},1),1);...
            ones(size(C.contra_stim{i,1},1),1); ones(size(C.contra_nostim{i,1},1),1)];
        stim{ii} = [stim{ii}; ones(size(C.ipsi_stim{i,1},1),1); zeros(size(C.ipsi_nostim{i,1},1),1);...
            ones(size(C.contra_stim{i,1},1),1); zeros(size(C.contra_nostim{i,1},1),1)];
        mfr{ii} = [mfr{ii}; C.ipsi_stim{i,ii}; C.ipsi_nostim{i,ii};...
            C.contra_stim{i,ii}; C.contra_nostim{i,ii}];
    end
end
preT = table(an{1},tp{1},hemi{1},stim{1},mfr{1},'VariableNames',{'Animal','Timepoint','Hemi','Stim','MFR'});
stimT = table(an{2},tp{2},hemi{2},stim{2},mfr{2},'VariableNames',{'Animal','Timepoint','Hemi','Stim','MFR'});
postT = table(an{3},tp{3},hemi{3},stim{3},mfr{3},'VariableNames',{'Animal','Timepoint','Hemi','Stim','MFR'});

% combine tables
G = [preT; stimT; postT];
G.Block = [repmat(1,size(preT,1),1); repmat(2,size(preT,1),1); repmat(3,size(preT,1),1)];
G.Block = categorical(G.Block);
formula = 'MFR ~ Timepoint*Stim*Block*Hemi + (1|Animal)';
mixed_model = fitglme(G, formula,'Distribution','Normal')
anova(mixed_model)
[p,F,~] = coefTest(mixed_model,[0 0 0 0 -1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]) % contrast testing for Block_2 and Block_3

% make plot of mfr over time
figure;
hold on
cc = [0 0.4470 0.7410; 0.8500 0.3250 0.0980];
for i = 0:1
    idxY = G.Hemi == i;
    y = G.MFR(idxY);
    x = G.Timepoint(idxY);
    coeff = polyfit(x,y,1);
    xdim = linspace(min(x), max(x), 100);
    ydim = polyval(coeff,xdim);
    plot(xdim,ydim,'color',cc(i+1,:),'LineWidth',1);
    end
scatter(G,'Timepoint','MFR','filled','MarkerFaceAlpha',.2,'ColorVariable','Hemi');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
xlabel('Days Post-Implant');
xlim([0 50]);

% make plot of mfr by blocks
mm = [];
ss = [];
for i = 1:3
    mm = [mm, nanmean(G.MFR(contains(string(G.Block),string(i))))];
    ss = [ss, nanstd(G.MFR(contains(string(G.Block),string(i))))];
end
figure('Position',[50 50 300 420]);
hold on
bar(mm);
errorbar([1 2 3],mm,ss,'LineStyle','none','Color','k');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
ylim([0 30]);
xticks([1,2,3])
xticklabels({'Pre-stim','Stim','Post-Stim'})

% make plot of each animal
figure;
hold on
[gr,hh,tt,aa] = findgroups(G.Hemi,G.Timepoint,G.Animal);
vals = splitapply(@mean,G.MFR,gr);
[~,~,uni] = unique(aa);
for i = 1:max(uni)
    [~,~,idxA] = unique(aa);
    x = unique(tt(idxA == i));
    y1 = vals(idxA == i & hh == 0);
    y2 = vals(idxA == i & hh == 1);
    plot(x,y1,'-o','Color',[0 0.4470 0.7410]);
    plot(x,y2,'-o','Color',[0.8500 0.3250 0.0980]);
end
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('MFR (Hz)');
xlabel('Days Post-Implant');
%% Deprecated plots
% % for the injured hemisphere
% preinj = cellfun(@(x) x{1},C.MFRinj,'UniformOutput',false);
% preinj = cell2mat(preinj);
% timeinj = cellfun(@(x,y) repmat(y,size(x{1},1),1),C.MFRinj,num2cell(C.Week),'UniformOutput',false);
% timeinj = cell2mat(timeinj);
% 
% % for the intact hemisphere
% preint = cellfun(@(x) x{1},C.MFRint,'UniformOutput',false);
% preint = cell2mat(preint);
% timeint = cellfun(@(x,y) repmat(y,size(x{1},1),1),C.MFRint,num2cell(C.Week),'UniformOutput',false);
% timeint = cell2mat(timeint);

% % make a table
% B = table([timeint; timeinj],[ones(size(preint,1),1); zeros(size(preinj,1),1)],[preint; preinj],'VariableNames',{'Time','Inj','Vals'});

% % plot
% figure('Position',[100 100 800 500]);
% boxchart(B.Time*2,B.Vals,'GroupByColor',B.Inj);
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% ylabel('MFR (Hz)');
% xticks(0:2:8);
% xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
% xlim([-1 9]);
% legend({'Intact','Injured'});

% % plot a second way
% bb = zeros(2,5);
% ss = zeros(2,5);
% for i = 1:2
%     for ii = 1:5
%         bb(i,ii) = nanmean(B.Vals(B.Time == ii-1 & B.Inj == i-1));
%         ss(i,ii) = nanstd(B.Vals(B.Time == ii-1 & B.Inj == i-1));
%     end
% end
% figure('Position',[100 100 875 500]);
% bar([1:5]',bb');
% hold on
% errorbar(((1:5) - 0.15)',bb(1,:)',ss(1,:)','LineStyle','none','Color','k');
% errorbar(((1:5) + 0.15)',bb(2,:)',ss(2,:)','LineStyle','none','Color','k');
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% ylabel('MFR (Hz)');
% xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
% legend({'Intact','Injured'});

% figure('Position',[800 575 950 400]);
% hold on
% [gr,ss,tt] = findgroups(G.Stim,G.Timepoint);
% m_vals = splitapply(@nanmean,G.MFR,gr);
% s_vals = splitapply(@nanstd,G.MFR,gr);
% plot(0:4,m_vals(1:5),'r');
% plot(0:4,m_vals(6:10),'k');
% plot(0:4,m_vals(1:5) + s_vals(1:5),'--r');
% plot(0:4,m_vals(1:5) - s_vals(1:5),'--r');
% plot(0:4,m_vals(6:10) + s_vals(6:10),'--k');
% plot(0:4,m_vals(6:10) - s_vals(6:10),'--k');
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% ylabel('MFR (Hz)');
% ylabel('MFR (Hz)');
% xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
% legend({'Stimulation','No Stimulation'});

% deprecated bar plot broken out be time/hemisphere/block
% figure('Position',[800 50 950 400]);
% for i = 1:5
%     subplot(1,5,i);
%     hold on
%     sc = C.inj_stim(C.Week == i - 1,:);
%     ns = C.inj_nostim(C.Week == i - 1,:);
%     sc = cell2mat(sc);
%     ns = cell2mat(ns);
%     m_sc = nanmean(sc);
%     m_ns = nanmean(ns);
%     std_sc = nanstd(sc);
%     std_ns = nanstd(ns);
%     bar([1;2],[m_sc; m_ns]);
%     errorbar([0.775 1 1.225;1.775 2 2.225],[m_sc; m_ns],[std_sc; std_ns],'LineStyle','none','Color','k');
%     set(gca,'TickDir','out','FontName','NewsGoth BT');
%     box off
%     ylabel('MFR (Hz)');
%     ylim([0 35]);
%     xticks([1 2]);
%     xticklabels({'Stimulation','No Stimulation'});
%     title(sprintf('Week %d',i-1));
% end