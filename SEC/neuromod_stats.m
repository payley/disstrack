%% Neuromodulatory indices for first 5 ms
% set variables for statistical tests
time_win = [0 5]; % timing of interest in ms
bin_sz = 0.2; % rebinned data
ns_bins = 30000 * (bin_sz/1000); % samples assigned to each bin
samp = 200/bin_sz + 1; % downsampled number

% create variables for table
animal_name = {};
block = {};
array = [];
ch = {};
stim_ch = [];
stim_probe = [];
inj_array = [];
postinj_t = [];
zval = [];
zmax = [];
N = table(animal_name,block,array,ch,stim_ch,stim_probe,inj_array,postinj_t,zval,zmax);
N = table2struct(N);
pl = 1;

% locate chPlot file
for bb = 1:size(C,1)
    root = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
    meta = split(C.Blocks{bb},'_');
    f_loc = fullfile(root,meta{1},C.Blocks{bb});
    cd(f_loc)
    load([C.Blocks{bb} '_stats_swtteo.mat']);
    fprintf('%s\n',C.Blocks{bb})
    if  sum(strcmp(chPlot.Properties.VariableNames,'baseline')) < 1
        meta = split(C.Blocks{bb},'_');
        idxR = contains({DataStructure.AnimalName},meta{1});
        idxD = contains(DataStructure(idxR).DateStr,join(meta(2:4),'_'));
        idxBl = DataStructure(idxR).Run{idxD}(1);
        block_id = join([meta(1:4);num2str(idxBl)],'_');
        f_loc = fullfile(DataStructure(idxR).NetworkPath,DataStructure(idxR).AnimalName,block_id,join([block_id,'SD_SWTTEO'],'_'));
        chPlot = base_spiking(chPlot,'catch',bin_sz,50,f_loc,size(chPlot.evoked_trials{1},1));
        save(fullfile(C.Dir{bb},C.Blocks{bb},[C.Blocks{bb} '_stats_swtteo.mat']),'chPlot');
    end
    % calculate z-scores
    for i = 1:size(chPlot,1)
        [bSp,edge] = histcounts(chPlot.all_evoked_spikes{i},linspace(0,200,samp)); % bin 200ms post-stim period
        tr = size(chPlot.evoked_trials{i},1);
        bSp = bSp(1:(time_win(2)/bin_sz));
        bSp = (bSp./tr);
        iSp = smoothdata(bSp,2,'gaussian',5);
        zm = chPlot.z_mean{i};
        zs = chPlot.z_std{i};
        zz = (iSp - zm)./(zs);
%         zz(isnan(zz)) = 0;
        zz(isinf(zz)) = 0;
        % add values and associated variables to structure
        N(pl).animal_name = C.Animal_Name(bb);
        N(pl).block = C.Blocks(bb);
        N(pl).array = str2double(chPlot.arr{i}(2));
        N(pl).ch = chPlot.ch{i};
        N(pl).stim_ch = C.Stim_Ch(bb);
        N(pl).stim_probe = C.Stim_Probe(bb) == N(pl).array;
%         if contains(N(pl).animal_name,{'R21-09','R21-10','R21-02'})
%             N(pl).inj_array = 0;
%         else
            N(pl).inj_array = C.Inj_Array(bb) == N(pl).array;
%         end
        N(pl).postinj_t = C.PostInj_Time(bb);
        N(pl).postimpl_t = C.PostImpl_Time(bb);
        N(pl).zval = zz;
        N(pl).zmax = max(zz);
        pl = pl + 1;
    end
end
%% Finish table
N = struct2table(N); % convert to table
% ctrl = {'R21-09','R21-10','R22-02'}; 
% N(contains(N.animal_name,ctrl),:) = []; % removes control animals
N(N.stim_probe == 0,:) = []; % only consider stim array
N(contains(N.block,"R23-10_2023_01_29_4"),:) = []; % bad stim day with double stim
N.week = zeros(size(N,1),1); % make week variable
N.week(N.postinj_t > 0 & N.postinj_t < 7) = 1;
N.week(N.postinj_t > 7 & N.postinj_t < 14) = 2;
N.week(N.postinj_t > 14 & N.postinj_t < 21) = 3;
N.week(N.postinj_t > 21 & N.postinj_t < 28) = 4;
N.week = categorical(N.week);
N.stim_ch = categorical(N.stim_ch);
%% Run stats
formula = 'zmax ~ inj_array*week + (1|animal_name:ch:stim_ch)';
mixed_model = fitglme(N, formula,'Distribution','Normal')
anova(mixed_model)

% Mann-Whitney test for differences by hemisphere at each timepoint
[gr,~,idxG] = findgroups(N.inj_array,N.week);
for i = 1:5
    idxW = find(str2num(char(idxG)) == i - 1);
    x = N.zmax(gr == idxW(1));
    y = N.zmax(gr == idxW(2));
    p = ranksum(x,y);
    fprintf('p = %0.03f for Week %d\n',p,i-1);
end
%% Make figures
% effect of timepoint
figure('Position',[100 150 525 675]);
boxplot(N.zmax,N.week,'DataLim',[-8 8],'Jitter',0.5);
ylim([-4 8.5]);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
ylabel('Z-score');

% effect of area
figure('Position',[100 150 350 675]);
boxplot(N.zmax,N.inj_array,'DataLim',[-8 8],'Jitter',0.5);
ylim([-4 8.5]);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticklabels({'Intact','Injured'});
xlabel('Hemisphere');
ylabel('Z-score');

% combined effect of time and area
figure('Position',[100 150 875 675]);
hold on
for i = 0:1
    for ii = 0:4
        dd = N.zmax(N.inj_array == i & N.week == num2str(ii));
        mm = nanmedian(dd);
        pp = prctile(dd,[0 100],"all");
        [v,xi] = ksdensity(dd,pp(1):0.1:pp(2),'Bandwidth',0.25);
        add = ii*2;
        if i == 0
            patch(add + [-v,zeros(1,size(v,2)),0],[xi,fliplr(xi),xi(1)],[0 0.4470 0.7410],'LineStyle','none');
            plot([add - 0.75,add],[mm, mm],'k');
        else
            patch(add + [zeros(1,size(v,2)),fliplr(v),0],[xi,fliplr(xi),xi(1)],[0.8500 0.3250 0.0980],'LineStyle','none');
            plot([add, add + 0.75],[mm, mm],'k');
        end
    end
end
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticks(0:2:8);
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
ylim([-4 4]);
ylabel('Z-score');
legend({'Intact','','','','','','','','','','Injured'},'Box','off')
%% Break out just the significantly modulated data
% adds control animals to consideration for results 
load('nmod_results.mat');
N = struct2table(N);
N(N.stim_probe == 0,:) = []; % only consider stim array
N(contains(N.block,"R23-10_2023_01_29_4"),:) = []; % bad stim day with double stim
N.week = zeros(size(N,1),1); % make week variable
N.week(N.postinj_t > 0 & N.postinj_t < 7) = 1;
N.week(N.postinj_t > 7 & N.postinj_t < 14) = 2;
N.week(N.postinj_t > 14 & N.postinj_t < 21) = 3;
N.week(N.postinj_t > 21 & N.postinj_t < 28) = 4;
N.week = categorical(N.week);
N.stim_ch = categorical(N.stim_ch);
subN = N(N.zmax > 3.09,:);

% plots proportion of channels with stimulated increases
[gr,~,idxG] = findgroups(subN.week,subN.inj_array);
numer = splitapply(@numel,subN.zmax,gr);
[gr,~,idxG] = findgroups(N.week,N.inj_array);
denom = splitapply(@numel,N.zmax,gr);
for i = 1:2
    c_num(:,i) = numer(idxG == i - 1);
    c_den(:,i) = denom(idxG == i - 1);
end
fract = c_num./c_den;
figure('Position',[100 100 350 420]);
bar(1:5,fract);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
ylabel('Proportion of channels with increased activity');
ylim([0 0.2]);
legend({'Intact Hemisphere','Injured Hemisphere'});

% plots channels with significantly increased activity
figure('Position',[100 100 500 420]);
hold on
boxchart(str2num(char(subN.week))*1.5,subN.zmax,'GroupByColor',subN.inj_array);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticks(0:1.5:6);
xticklabels({'Pre-Lesion','Post-Lesion Week 1','Post-Lesion Week 2','Post-Lesion Week 3','Post-Lesion Week 4'});
ylabel('Max Z-score');
ylim([0 80]);
legend({'Intact Hemisphere','Injured Hemisphere'});

% run stats
formula = 'zmax ~ inj_array*week + (1|animal_name:ch)';
mixed_model = fitglme(subN, formula,'Distribution','Normal')
anova(mixed_model)
%% Restructure table for control data
% reload N table
N = struct2table(N); % convert to table
N(N.stim_probe == 0,:) = []; % only consider stim array
N(contains(N.block,"R23-10_2023_01_29_4"),:) = []; % bad stim day with double stim
N.posttime = zeros(size(N,1),1); % make week variable
N.posttime(N.postimpl_t > 0 & N.postimpl_t <= 7) = 1;
N.posttime(N.postimpl_t > 7 & N.postimpl_t <= 14) = 2;
N.posttime(N.postimpl_t > 14 & N.postimpl_t <= 21) = 3;
N.posttime(N.postimpl_t > 21 & N.postimpl_t <= 28) = 4;
N.posttime(N.postimpl_t > 28 & N.postimpl_t <= 35) = 5;
N.posttime(N.postimpl_t > 35 & N.postimpl_t <= 42) = 6;
N.posttime(N.postimpl_t > 42 & N.postimpl_t <= 49) = 7;
N.posttime(N.postimpl_t > 49 & N.postimpl_t <= 56) = 8;
% N.posttime = categorical(N.posttime);
N(N.postinj_t > 0,:) = [];
N.stim_ch = categorical(N.stim_ch);
%% Run stats for control data
formula = 'zmax ~ inj_array*postimpl_t + (1|animal_name:ch)';
mixed_model = fitglme(N, formula,'Distribution','Normal')
anova(mixed_model)
%% Make figures for control data
% effect of timepoint
% figure('Position',[100 150 525 350]);
% hold on
% for i = 0:1
%     idxY = N.inj_array == i & ~isnan(N.zmax);
%     y = N.zmax(idxY);
%     x = N.postimpl_t(idxY);
%     coeff = polyfit(x,y,1);
%     xdim = linspace(min(x), max(x), 100);
%     ydim = polyval(coeff,xdim);
%     plot(xdim,ydim,'LineWidth',1);
% end
% scatter(N.postimpl_t,N.zmax,'filled','MarkerFaceAlpha',.2);
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% xlabel('Days Post-Implant');
% ylabel('Z-score');

[gr,~,idxG] = findgroups(N.postimpl_t,N.inj_array);
mm = splitapply(@nanmean,N.zmax,gr);
ss = splitapply(@nanstd,N.zmax,gr);
figure;
hold on
cc = [0 0.4470 0.7410; 0.8500 0.3250 0.0980];
tt = unique(N.postimpl_t);
for i = 1:2
    subs = idxG == (i-1);
    patch([tt; flip(tt)],[mm(subs) + ss(subs); flip(mm(subs) - ss(subs))],[0.6 0.9370 0.9910],'EdgeColor',cc(i,:),'FaceAlpha',.2);
    plot(tt,mm(subs))
end
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylabel('Max Z-score');
xlabel('Days Post-Implant');
xlim([2 50]);
xticks(10:10:40);

% effect of area
figure('Position',[100 150 350 350]);
boxplot(N.zmax,N.inj_array,'DataLim',[-8 8],'Jitter',0.5);
ylim([-4 8.5]);
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
xticklabels({'Intact','Injured'});
xlabel('Hemisphere');
ylabel('Z-score');

% combined effect of time and area
% deprecated for now
% figure('Position',[100 150 875 500]);
% hold on
% for i = 0:1
%     for ii = 1:7
%         dd = N.zmax(N.inj_array == i & N.posttime == ii);
%         mm = nanmedian(dd);
%         pp = prctile(dd,[0 90],"all");
%         [v,xi] = ksdensity(dd,pp(1):0.1:pp(2),'Bandwidth',0.25);
%         add = ii*2;
%         if i == 0
%             patch(add + [-v,zeros(1,size(v,2)),0],[xi,fliplr(xi),xi(1)],[0 0.4470 0.7410],'LineStyle','none');
%             plot([add - 0.75,add],[mm, mm],'k');
%         else
%             patch(add + [zeros(1,size(v,2)),fliplr(v),0],[xi,fliplr(xi),xi(1)],[0.8500 0.3250 0.0980],'LineStyle','none');
%             plot([add, add + 0.75],[mm, mm],'k');
%         end
%     end
% end
% set(gca,'TickDir','out','FontName','NewsGoth BT');
% box off
% xticks(2:2:14);
% xticklabels({'Week 1','Week 2','Week 3','Week 4','Week 5', ...
%     'Week 6','Week 7'});
% xlabel('Post-Implant Time');
% ylabel('Z-score');
% legend({'Intact','','','','','','','','','','','','','','','','Injured'},'Box','off')
%% Deprecated neuromodulatory indices for next 5 ms
% set variables for statistical tests
time_win = [5 10]; % timing of interest in ms
bin_sz = 0.2; % rebinned data
ns_bins = 30000 * (bin_sz/1000); % samples assigned to each bin
samp = 200/bin_sz + 1; % downsampled number

% create variables for table
animal_name = {};
block = {};
array = [];
ch = {};
stim_ch = [];
stim_probe = [];
inj_array = [];
postinj_t = [];
zval = [];
zmax = [];
N = table(animal_name,block,array,ch,stim_ch,stim_probe,inj_array,postinj_t,zval,zmax);
N = table2struct(N);
pl = 1;

% locate chPlot file
for bb = 1:size(C,1)
    root = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
    meta = split(C.Blocks{bb},'_');
    f_loc = fullfile(root,meta{1},C.Blocks{bb});
    cd(f_loc)
    load([C.Blocks{bb} '_stats_swtteo.mat']);
    fprintf('%s\n',C.Blocks{bb})
    if  sum(strcmp(chPlot.Properties.VariableNames,'baseline')) < 1
        meta = split(C.Blocks{bb},'_');
        idxR = contains({DataStructure.AnimalName},meta{1});
        idxD = contains(DataStructure(idxR).DateStr,join(meta(2:4),'_'));
        idxBl = DataStructure(idxR).Run{idxD}(1);
        block_id = join([meta(1:4);num2str(idxBl)],'_');
        f_loc = fullfile(DataStructure(idxR).NetworkPath,DataStructure(idxR).AnimalName,block_id,join([block_id,'SD_SWTTEO'],'_'));
        chPlot = base_spiking(chPlot,'catch',bin_sz,50,f_loc,size(chPlot.evoked_trials{1},1));
        save(fullfile(C.Dir{bb},C.Blocks{bb},[C.Blocks{bb} '_stats_swtteo.mat']),'chPlot');
    end
    % calculate z-scores
    for i = 1:size(chPlot,1)
        [bSp,edge] = histcounts(chPlot.all_evoked_spikes{i},linspace(0,200,samp)); % bin 200ms post-stim period
        tr = size(chPlot.evoked_trials{i},1);
        bSp = bSp((time_win(1)/bin_sz) + 1:(time_win(2)/bin_sz));
        bSp = (bSp./tr);
        iSp = smoothdata(bSp,2,'gaussian',5);
        zm = chPlot.z_mean{i};
        zs = chPlot.z_std{i};
        zz = (iSp - zm)./(zs);
%         zz(isnan(zz)) = 0;
        zz(isinf(zz)) = 0;
        % add values and associated variables to structure
        N(pl).animal_name = C.Animal_Name(bb);
        N(pl).block = C.Blocks(bb);
        N(pl).array = str2double(chPlot.arr{i}(2));
        N(pl).ch = chPlot.ch{i};
        N(pl).stim_ch = C.Stim_Ch(bb);
        N(pl).stim_probe = C.Stim_Probe(bb) == N(pl).array;
%         if contains(N(pl).animal_name,{'R21-09','R21-10','R21-02'})
%             N(pl).inj_array = 0;
%         else
            N(pl).inj_array = C.Inj_Array(bb) == N(pl).array;
%         end
        N(pl).postinj_t = C.PostInj_Time(bb);
        N(pl).zval = zz;
        N(pl).zmax = max(zz);
        pl = pl + 1;
    end
end