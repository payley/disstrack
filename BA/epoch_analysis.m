%% Epoch test
%% Fix channel id
chid = listBl.ch_id;
sz = cellfun(@(x) size(x,1),chid);
hld = cellfun(@(x) x+16,chid(sz == 48),'UniformOutput',0);
chid(sz == 48) = deal(hld);
idxF = cellfun(@isempty,listBl.arr_id,'UniformOutput',1);
arrid = cell(size(listBl,1),1);
fill = [repmat("Ipsi",32,1); repmat("Contra",32,1)];
arrid(~idxF) = {deal(fill)};
fill = [repmat("Ipsi",16,1); repmat("Contra",32,1)];
arrid([54,55]) = {deal(fill)};
%% Make table for experimental group
% load normalized behavior
load('behavioral_results_inj.mat');
holdB = table2array(B(4:8,:));
holdB(2:5,:) = (holdB(2:5,:)./holdB(1,:))*100;
holdB(1,:) = 100;
clear B
% create table for every block
H = [];
listP = listBl;
listP.ch_id = chid;
listP.arr_id = arrid;
listP = listP(~isnan(listBl.exp_time),:); 
idxG = findgroups(listP.animal_name,listP.exp_time);
[~,idxU] = unique(idxG);
remove = true(size(listP,1),1);
remove(idxU) = 0;
listP(logical(remove),:) = [];
E = listP(:,[1,2,4]);
E.ch = cellfun(@(x,y) x(logical(y)),listP.ch_id,listP.ch_mfr,'UniformOutput',0);
E.arr = cellfun(@(x,y) x(logical(y)),listP.arr_id,listP.ch_mfr,'UniformOutput',0);
E.vals = cellfun(@(x,y) x(logical(y),:),listP.ifr_vals,listP.ch_mfr,'UniformOutput',0);
c = 1;
fill = 1;
for i = 1:9
    for ii = 1:5
        if sum(ismember([16,21],c)) > 0
            c = c + 1;
            continue
        end
        E.behavior(fill) = {holdB(ii,i)};
        E.deficit(fill) = {min(holdB(:,i))};
        c = c + 1;
        fill = fill + 1;
    end
end
% break out table for every channel
an = cellfun(@(x,y) repelem(string(y),size(x,1),1),E.vals,E.animal_name,'UniformOutput',0);
bl = cellfun(@(x,y) repelem(string(y),size(x,1),1),E.vals,E.block_name,'UniformOutput',0);
exp = cellfun(@(x,y) repelem(y,size(x,1),1),E.vals,num2cell(E.exp_time),'UniformOutput',0);
beh = cellfun(@(x,y) repelem(y,size(x,1),1),E.vals,E.behavior,'UniformOutput',0);
def = cellfun(@(x,y) repelem(y,size(x,1),1),E.vals,E.deficit,'UniformOutput',0);
H.animal_name = vertcat(an{:});
H.block_name = vertcat(bl{:});
H.exp_time = cell2mat(exp);
H.ch = cell2mat(E.ch);
H.arr = vertcat(E.arr{:});
H.behavior = vertcat(beh{:});
H.deficit = vertcat(def{:});
H.vals = num2cell(cell2mat(E.vals),2);
H = struct2table(H);
[pt, pk] = cellfun(@(x) findpeaks(x,'MinPeakHeight',3.09,'MinPeakDistance',15,'MinPeakProminence',0.1,'NPeaks',3),H.vals,'UniformOutput',0);
[rt, tr] = cellfun(@(x) findpeaks(-x,'MinPeakHeight',3.09,'MinPeakDistance',15,'MinPeakProminence',0.1,'NPeaks',3),H.vals,'UniformOutput',0);
time = linspace(-1,1,100);
H.pk_time = cellfun(@(x) time(x),pk,'UniformOutput',0);
H.tr_time = cellfun(@(x) time(x),tr,'UniformOutput',0);
H.pk_height = pt;
H.tr_depth = rt;
H.ch = string(H.ch);
%% Divide into epochs 
t = linspace(-1,1,100);
ep1 = find(t < -0.3);
ep2 = find(t >= -0.3 & t <= 0.2);
ep3 = find(t > 0.2);
H.epoch1_max = cellfun(@(x) max(x(ep1)),H.vals,'UniformOutput',1);
H.epoch1_min = cellfun(@(x) min(x(ep1)),H.vals,'UniformOutput',1);
H.epoch1_mean = cellfun(@(x) mean(x(ep1)),H.vals,'UniformOutput',1);
H.epoch2_max = cellfun(@(x) max(x(ep2)),H.vals,'UniformOutput',1);
H.epoch2_min = cellfun(@(x) min(x(ep2)),H.vals,'UniformOutput',1);
H.epoch2_mean = cellfun(@(x) mean(x(ep2)),H.vals,'UniformOutput',1);
H.epoch3_max = cellfun(@(x) max(x(ep3)),H.vals,'UniformOutput',1);
H.epoch3_min = cellfun(@(x) min(x(ep3)),H.vals,'UniformOutput',1);
H.epoch3_mean = cellfun(@(x) mean(x(ep3)),H.vals,'UniformOutput',1);
%% New model with controls as a variable
expH = H;
subH = H(H.exp_time == 0,:); 
expH(expH.exp_time == 0,:) = [];
subH.ch = str2double(subH.ch);
[~,gr] = findgroups(subH(:,[1,4]));
expH.epoch1_ctrl = nan(size(expH,1),1);
expH.epoch2_ctrl = nan(size(expH,1),1);
expH.epoch3_ctrl = nan(size(expH,1),1);
gr = table2array(gr);
for i = 1:size(gr,1)
   idxG = contains(expH{:,1},gr(i,1)) & str2double(expH{:,4}) == str2double(gr(i,2));
   expH.epoch1_ctrl(idxG) = subH.epoch1_mean(i);
   expH.epoch2_ctrl(idxG) = subH.epoch2_mean(i);
   expH.epoch3_ctrl(idxG) = subH.epoch3_mean(i);
end
expH(isnan(expH.epoch1_ctrl),:) = [];
H.exp_time = categorical(H.exp_time);
expH.exp_time = categorical(expH.exp_time);
%% Run lme
formula = 'epoch1_mean ~ exp_time*arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 1</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)

formula = 'epoch2_mean ~ exp_time*arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 2</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)

formula = 'epoch3_mean ~ exp_time*arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 3</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)
%% Make corresponding figures
figure('Position',[400,150,950,400]);
x = linspace(-1,1,100);
plot(x,H.vals{2037});
e1 = x < -0.3;
mE1 = mean(H.vals{2037}(e1));
e2 = x >= -0.3 & x <= 0.3;
mE2 = mean(H.vals{2037}(e2));
e3 = x > 0.3;
mE3 = mean(H.vals{2037}(e3));
hold on
scatter([-0.65,0,0.6],[mE1,mE2,mE3]);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
ylabel('Mean Z-score');
xticks(-1:0.1:1)
xlabel('Time (s)');

% bar plot
iE = cell(3,1);
cE = cell(3,1);
area = {'Ipsi','Contra'};
figure('Position',[850,450,800,400]);
hold on
for i = 1:5
    iE{1} = [iE{1}; mean(H.epoch1_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Ipsi')))];
    cE{1} = [cE{1}; mean(H.epoch1_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Contra')))];
end
subplot(1,3,1);
bar([iE{1} cE{1}]);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
title('Epoch 1');
xticklabels({'Baseline', 'Post-Lesion 1', 'Post-Lesion 2', 'Post-Lesion 3', 'Post-Lesion 4'});
ylabel('Mean Z-Score');
ylim([0 6]);

for i = 1:5
    iE{2} = [iE{2}; mean(H.epoch2_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Ipsi')))];
    cE{2} = [cE{2}; mean(H.epoch2_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Contra')))];
end
subplot(1,3,2);
bar([iE{2} cE{2}]);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
title('Epoch 2');
xticklabels({'Baseline', 'Post-Lesion 1', 'Post-Lesion 2', 'Post-Lesion 3', 'Post-Lesion 4'});
ylim([0 6]);

for i = 1:5
    iE{3} = [iE{3}; mean(H.epoch3_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Ipsi')))];
    cE{3} = [cE{3}; mean(H.epoch3_mean(H.exp_time == categorical(i-1) & contains(H.arr,'Contra')))];
end
subplot(1,3,3);
bar([iE{3} cE{3}]);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
title('Epoch 3');
xticklabels({'Baseline', 'Post-Lesion 1', 'Post-Lesion 2', 'Post-Lesion 3', 'Post-Lesion 4'});
ylim([0 6]);
%% Run lme
% epoch 1
formula = 'epoch1_mean ~ 1 + behavior + behavior:arr + exp_time:behavior + epoch1_ctrl + epoch1_ctrl:arr + exp_time:epoch1_ctrl + behavior:epoch1_ctrl + (1|animal_name:ch)';
mixed_model = fitglme(expH, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));

pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 1</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
bx = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure('Position',[600,200,350,300]); 
scatter(expH.behavior,expH.epoch1_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(bx,intc + beh*bx,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 1');

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:behavior');
arrbeh = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,300]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.behavior(idxA{i}),expH.epoch1_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(bx,intc + beh*bx + arrbeh*bx*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Normalized behavior ability');
end
sgtitle('Epoch 1');

figure('Position',[600,200,350,450]);
for i = 1:4
    idxD = expH.exp_time == categorical(i);
    subplot(2,2,i);
    scatter(expH.behavior(idxD),expH.epoch1_mean(idxD),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    fill = sprintf('exp_time_%d:behavior',i);
    idxT = strcmp(table2array(coeff_all(:,1)),fill);
    timbeh = table2array(coeff_all(idxT,2));
    if isempty(timbeh)
        plot(bx,intc + beh*bx,'k');
    else
        plot(bx,intc + beh*bx + timbeh*bx*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 50]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Normalized behavior ability');
    end
    title(sprintf('Week %d',i));
end
sgtitle('Epoch 1');

figure('Position',[850,550,350,175]);
scatter(expH.epoch1_ctrl,expH.epoch1_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
idxE = strcmp(table2array(coeff_all(:,1)),'epoch1_ctrl');
ep = table2array(coeff_all(idxE,2));
epc = linspace(-5, 55, 100)';
plot(epc,intc + epc*ep,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 60]);
xlim([-10 60]);
ylabel('Mean Z-score');
xlabel('Baseline Z-score');
title('Epoch 1');

figure('Position',[850,450,350,300]);
sgtitle('Epoch 1');
for i = 1:4
    idxTP = expH.exp_time == categorical(i);
    subplot(2,2,i)
    scatter(expH.epoch1_ctrl(idxTP),expH.epoch1_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    fill = sprintf('exp_time_%d:epoch1_ctrl',i);
    idxF = strcmp(table2array(coeff_all(:,1)),fill);
    timep = table2array(coeff_all(idxF,2));
    idxE = strcmp(table2array(coeff_all(:,1)),'behavior:epoch1_ctrl');
    beep = table2array(coeff_all(idxE,2));
    if isempty(timep)
        plot(epc,intc + epc*ep,'k');
    else
        plot(epc,intc + epc*ep + timep*epc*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 60]);
    xlim([-10 60]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Baseline Z-score');
    end
    title(sprintf('Week %d',i));
end

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:epoch1_ctrl');
arrep = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,200]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.epoch1_ctrl(idxA{i}),expH.epoch1_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(epc,intc + epc*ep + arrep*epc*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    xlim([-10 60]);
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Baseline Z-score');
end
sgtitle('Epoch 1');

figure('Position',[850,150,350,250]);
hilo{1} = min(expH.epoch1_ctrl);
hilo{2} = max(expH.epoch1_ctrl);
scatter(expH.behavior,expH.epoch1_mean,[],expH.epoch1_ctrl,'filled','MarkerFaceAlpha',.7);
colormap(cool);
hold on
plot(bx,intc + hilo{1}*ep + hilo{1}*bx'*beep,'k','LineStyle','-');
plot(bx,intc + hilo{2}*ep + hilo{2}*bx'*beep,'k','LineStyle','--');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 1');

% epoch 2
formula = 'epoch2_mean ~ 1 + behavior + behavior:arr + exp_time:behavior + epoch2_ctrl + epoch2_ctrl:arr + exp_time:epoch2_ctrl + behavior:epoch2_ctrl + (1|animal_name:ch)';
mixed_model = fitglme(expH, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 2</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
bx = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure('Position',[600,200,350,300]); 
scatter(expH.behavior,expH.epoch2_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(bx,intc + beh*bx,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 2');

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:behavior');
arrbeh = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,300]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.behavior(idxA{i}),expH.epoch2_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(bx,intc + beh*bx + arrbeh*bx*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Normalized behavior ability');
end
sgtitle('Epoch 2');

figure('Position',[600,200,350,450]);
for i = 1:4
    idxD = expH.exp_time == categorical(i);
    subplot(2,2,i);
    scatter(expH.behavior(idxD),expH.epoch2_mean(idxD),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    fill = sprintf('exp_time_%d:behavior',i);
    idxT = strcmp(table2array(coeff_all(:,1)),fill);
    timbeh = table2array(coeff_all(idxT,2));
    if isempty(timbeh)
        plot(bx,intc + beh*bx,'k');
    else
        plot(bx,intc + beh*bx + timbeh*bx*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 50]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Normalized behavior ability');
    end
    title(sprintf('Week %d',i));
end
sgtitle('Epoch 2');

figure('Position',[850,550,350,175]);
scatter(expH.epoch2_ctrl,expH.epoch2_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
idxE = strcmp(table2array(coeff_all(:,1)),'epoch2_ctrl');
ep = table2array(coeff_all(idxE,2));
epc = linspace(-5, 55, 100)';
plot(epc,intc + epc*ep,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 60]);
xlim([-10 60]);
ylabel('Mean Z-score');
xlabel('Baseline Z-score');
title('Epoch 2');

figure('Position',[850,450,350,300]);
sgtitle('Epoch 2');
for i = 1:4
    idxTP = expH.exp_time == categorical(i);
    subplot(2,2,i)
    scatter(expH.epoch2_ctrl(idxTP),expH.epoch2_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    fill = sprintf('exp_time_%d:epoch2_ctrl',i);
    idxF = strcmp(table2array(coeff_all(:,1)),fill);
    timep = table2array(coeff_all(idxF,2));
    idxE = strcmp(table2array(coeff_all(:,1)),'behavior:epoch2_ctrl');
    beep = table2array(coeff_all(idxE,2));
    if isempty(timep)
        plot(epc,intc + epc*ep,'k');
    else
        plot(epc,intc + epc*ep + timep*epc*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 60]);
    xlim([-10 60]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Baseline Z-score');
    end
    title(sprintf('Week %d',i));
end

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:epoch2_ctrl');
arrep = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,200]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.epoch2_ctrl(idxA{i}),expH.epoch2_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(epc,intc + epc*ep + arrep*epc*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    xlim([-10 60]);
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Baseline Z-score');
end
sgtitle('Epoch 2');

figure('Position',[850,150,350,250]);
hilo{1} = min(expH.epoch2_ctrl);
hilo{2} = max(expH.epoch2_ctrl);
scatter(expH.behavior,expH.epoch2_mean,[],expH.epoch2_ctrl,'filled','MarkerFaceAlpha',.7);
colormap(cool);
hold on
plot(bx,intc + hilo{1}*ep + hilo{1}*bx'*beep,'k','LineStyle','-');
plot(bx,intc + hilo{2}*ep + hilo{2}*bx'*beep,'k','LineStyle','--');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 2');

% epoch 3
formula = 'epoch3_mean ~ 1 + behavior + behavior:arr + exp_time:behavior + epoch3_ctrl + epoch3_ctrl:arr + exp_time:epoch3_ctrl + behavior:epoch3_ctrl + (1|animal_name:ch)';
mixed_model = fitglme(expH, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 3</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
anova(mixed_model)

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
bx = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure('Position',[600,200,350,300]); 
scatter(expH.behavior,expH.epoch3_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(bx,intc + beh*bx,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 3');

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:behavior');
arrbeh = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,300]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.behavior(idxA{i}),expH.epoch3_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(bx,intc + beh*bx + arrbeh*bx*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Normalized behavior ability');
end
sgtitle('Epoch 3');

figure('Position',[600,200,350,450]);
for i = 1:4
    idxD = expH.exp_time == categorical(i);
    subplot(2,2,i);
    scatter(expH.behavior(idxD),expH.epoch3_mean(idxD),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    fill = sprintf('exp_time_%d:behavior',i);
    idxT = strcmp(table2array(coeff_all(:,1)),fill);
    timbeh = table2array(coeff_all(idxT,2));
    if isempty(timbeh)
        plot(bx,intc + beh*bx,'k');
    else
        plot(bx,intc + beh*bx + timbeh*bx*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 50]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Normalized behavior ability');
    end
    title(sprintf('Week %d',i));
end
sgtitle('Epoch 3');

figure('Position',[850,550,350,175]);
scatter(expH.epoch3_ctrl,expH.epoch3_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
idxE = strcmp(table2array(coeff_all(:,1)),'epoch3_ctrl');
ep = table2array(coeff_all(idxE,2));
epc = linspace(-5, 55, 100)';
plot(epc,intc + epc*ep,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 60]);
xlim([-10 60]);
ylabel('Mean Z-score');
xlabel('Baseline Z-score');
title('Epoch 3');

figure('Position',[850,450,350,300]);
sgtitle('Epoch 3');
for i = 1:4
    idxTP = expH.exp_time == categorical(i);
    subplot(2,2,i)
    scatter(expH.epoch3_ctrl(idxTP),expH.epoch3_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    fill = sprintf('exp_time_%d:epoch3_ctrl',i);
    idxF = strcmp(table2array(coeff_all(:,1)),fill);
    timep = table2array(coeff_all(idxF,2));
    idxE = strcmp(table2array(coeff_all(:,1)),'behavior:epoch3_ctrl');
    beep = table2array(coeff_all(idxE,2));
    if isempty(timep)
        plot(epc,intc + epc*ep,'k');
    else
        plot(epc,intc + epc*ep + timep*epc*(i-1),'k');
    end
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    ylim([-10 60]);
    xlim([-10 60]);
    if i == 1 || i == 3
        ylabel('Mean Z-score');
    end
    if i == 3 || i == 4
        xlabel('Baseline Z-score');
    end
    title(sprintf('Week %d',i));
end

idxA = cell(2,1);
idxA{1} = contains(expH.arr,'Ipsi');
idxA{2} = contains(expH.arr,'Contra');
idxR = strcmp(table2array(coeff_all(:,1)),'arr_Contra:epoch3_ctrl');
arrep = table2array(coeff_all(idxR,2));
figure('Position',[600,200,350,200]);
alt = {'Ipsi','Contra'};
for i = 1:2
    subplot(1,2,i);
    scatter(expH.epoch3_ctrl(idxA{i}),expH.epoch3_mean(idxA{i}),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
    hold on
    plot(epc,intc + epc*ep + arrep*epc*(i-1),'k');
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    title(alt{i});
    xlim([-10 60]);
    ylim([-10 50]);
    if i == 1
        ylabel('Mean Z-score');
    end
    xlabel('Baseline Z-score');
end
sgtitle('Epoch 3');

figure('Position',[850,150,350,250]);
hilo{1} = min(expH.epoch3_ctrl);
hilo{2} = max(expH.epoch3_ctrl);
scatter(expH.behavior,expH.epoch3_mean,[],expH.epoch3_ctrl,'filled','MarkerFaceAlpha',.7);
colormap(cool);
hold on
plot(bx,intc + hilo{1}*ep + hilo{1}*bx'*beep,'k','LineStyle','-');
plot(bx,intc + hilo{2}*ep + hilo{2}*bx'*beep,'k','LineStyle','--');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 3');

%% Deprecated glme methods
% idxT = strcmp(table2array(coeff_all(:,1)),'exp_time');
% tim = table2array(coeff_all(idxT,2));
% tx = linspace(0.5,4.5,20);
% figure('Position',[0,0,250,450]);
% scatter(expH.exp_time,expH.epoch1_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
% for 1 = 1:4
% plot(tx,intc + tim*tx,'k');
% set(gca,'TickDir','out','FontName', 'NewsGoth BT');
% ylim([-10 40]);
% xlim([0 5]);
% xticks(1:4);
% xticklabels({'Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
% ylabel('Mean Z-score');
% title('Epoch 1');
% 
% figure('Position',[100,100,200,750]);
% set(gca,'TickDir','out','FontName', 'NewsGoth BT');
% sgtitle('Epoch 1');
% for i = 1:4
%     idxTP = expH.exp_time == i;
%     exp_time = repmat(i,100,1);
%     behavior = bx';
%     epoch1_ctrl = zeros(100,1);
%     T = table(behavior,epoch1_ctrl,exp_time);
%     subplot(4,1,i)
%     scatter(expH.behavior(idxTP),expH.epoch1_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
%     hold on
%     pv = predict(mixed_model,T);
%     plot(bx,pv,'k');
%     ylim([-10 50]);
%     yticks(linspace(-10,50,7));
%     ylabel('Mean Z-score');
% end
% xlabel('Normalized behavior ability');
% 
% figure('Position',[325,100,250,750]);
% set(gca,'TickDir','out','FontName', 'NewsGoth BT');
% sgtitle('Epoch 1');
% for i = 1:4
%     idxTP = expH.exp_time == i;
%     exp_time = repmat(i,100,1);
%     behavior = zeros(100,1);
%     epoch1_ctrl = linspace(min(expH.epoch1_ctrl)-1, max(expH.epoch1_ctrl)+1, 100)';
%     T = table(behavior,epoch1_ctrl,exp_time);
%     subplot(4,1,i)
%     scatter(expH.epoch1_ctrl(idxTP),expH.epoch1_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
%     hold on
%     pv = predict(mixed_model,T);
%     plot(epoch1_ctrl,pv,'k');
%     ylim([-10 50]);
%     xlim([-10 30]);
%     yticks(linspace(-10,50,7));
%     ylabel('Mean Z-score');
% end
% xlabel('Mean baseline z-score');
% 
% figure('Position',[680,150,350,300]);
% set(gca,'TickDir','out','FontName', 'NewsGoth BT');
% exp_time = zeros(100,1);
% behavior = bx';
% epoch1_ctrl = repmat(min(expH.epoch1_ctrl),100,1);
% lT = table(behavior,epoch1_ctrl,exp_time);
% epoch1_ctrl = repmat(max(expH.epoch1_ctrl),100,1);
% hT = table(behavior,epoch1_ctrl,exp_time);
% scatter(expH.behavior,expH.epoch1_mean,[],expH.epoch1_ctrl,'filled','MarkerFaceAlpha',.7);
% colormap(cool);
% hold on
% pv = predict(mixed_model,lT);
% plot(bx,pv,'k','LineStyle','-');
% pv = predict(mixed_model,hT);
% plot(bx,pv,'k','LineStyle','--');
% ylabel('Mean Z-score');
% xlabel('Normalized behavior ability');
% title('Epoch 1');
%% Run lme for max/min
% epoch 1
formula = 'epoch1_max ~ 1 + behavior + exp_time + exp_time:arr + exp_time:behavior + behavior:arr + (1|epoch1_ctrl)';
mixed_model = fitglme(expH, formula,'Distribution','Normal');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 1</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
bx = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure; 
scatter(expH.behavior,expH.epoch1_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(bx,intc + beh*bx,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 1');

idxT = strcmp(table2array(coeff_all(:,1)),'exp_time');
tim = table2array(coeff_all(idxT,2));
tx = linspace(0.5,4.5,20);
figure('Position',[0,0,250,450]); 
scatter(expH.exp_time,expH.epoch1_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
plot(tx,intc + tim*tx,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 40]);
xlim([0 5]);
xticks(1:4);
xticklabels({'Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Mean Z-score');
title('Epoch 1');

%% Divide into epochs
H.epoch1_pk = cellfun(@(x) x < -0.2,H.pk_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch1_pk,'UniformOutput',1);
H.epoch1_pk(idxH) = {1};
H.epoch1_pk(~idxH) = {0};
H.epoch1_pk = cell2mat(H.epoch1_pk);

H.epoch2_pk = cellfun(@(x) x >= -0.2 & x <= 0.2,H.pk_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch2_pk,'UniformOutput',1);
H.epoch2_pk(idxH) = {1};
H.epoch2_pk(~idxH) = {0};
H.epoch2_pk = cell2mat(H.epoch2_pk);

H.epoch3_pk = cellfun(@(x) x > 0.2,H.pk_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch3_pk,'UniformOutput',1);
H.epoch3_pk(idxH) = {1};
H.epoch3_pk(~idxH) = {0};
H.epoch3_pk = cell2mat(H.epoch3_pk);

H.epoch1_tr = cellfun(@(x) x < -0.2,H.tr_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch1_tr,'UniformOutput',1);
H.epoch1_tr(idxH) = {1};
H.epoch1_tr(~idxH) = {0};
H.epoch1_tr = cell2mat(H.epoch1_tr);

H.epoch2_tr = cellfun(@(x) x >= -0.2 & x <= 0.2,H.pk_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch2_tr,'UniformOutput',1);
H.epoch2_tr(idxH) = {1};
H.epoch2_tr(~idxH) = {0};
H.epoch2_tr = cell2mat(H.epoch2_tr);

H.epoch3_tr = cellfun(@(x) x > 0.2,H.tr_time,'UniformOutput',0);
idxH = cellfun(@(x) sum(x) >= 1,H.epoch3_tr,'UniformOutput',1);
H.epoch3_tr(idxH) = {1};
H.epoch3_tr(~idxH) = {0};
H.epoch3_tr = cell2mat(H.epoch3_tr);
%% Run glme
formula = 'epoch1_pk ~ exp_time:deficit + exp_time:arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 1</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

formula = 'epoch2_pk ~ exp_time:deficit  + exp_time:arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 2</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

formula = 'epoch3_pk ~ exp_time:deficit + exp_time:arr + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 3</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

formula = 'epoch1_tr ~ arr:deficit:exp_time + deficit + deficit:exp_time + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 1</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

formula = 'epoch2_tr ~ arr:deficit:exp_time + deficit + deficit:exp_time + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 2</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);

formula = 'epoch3_tr ~ arr:deficit:exp_time + deficit + deficit:exp_time + (1|animal_name:ch)';
mixed_model = fitglme(H, formula,'Distribution','Binomial');
coeff_all = dataset2table(mixed_model.Coefficients);
coeff = coeff_all{:,6};
idxC = coeff < 0.05;
nm = string(table2array(coeff_all(idxC,1)));
pv = table2array(coeff_all(idxC,6));
disp('<strong>Epoch 3</strong>');
for i = 1:size(pv,1)
fprintf('%s p = %0.03f\n',nm(i),pv(i));
end
fprintf('R^2 = %0.03f\n',mixed_model.Rsquared.Ordinary);
%% Peak/trough method 2
E1 = cell(5,1);
for i = 0:4
    idxJ = H.exp_time == i;
    jH = H(idxJ,:);
    [idxG,gr] = findgroups(jH(:,[1,5]));
    for ii = 1:size(gr,1)
        sub = idxG == ii;
        E1{i+1} = [E1{i+1}; sum(jH.epoch1_pk(sub))];
    end
end
dates = num2cell(0:4');
G = cellfun(@(x,y) repmat(y,size(x),1),E1,dates,'UniformOutput',1);
G = [G, cell2array(E1)];
%% Other code
% gaussian filter
sigma = 2;
gaussian_range = -3*sigma:3*sigma;
gaussian_kernel = normpdf(gaussian_range,0,sigma);
gaussian_kernel = gaussian_kernel/sum(gaussian_kernel);

% set-up
names = unique(H.animal_name);
N = cell(1,9);
S = cell(1,9);
M = cell(1,9);
for i = 1:9
    figure;
    hold on
    for ii = 0:4
        fill = H.pk_time(H.exp_time == ii & H.ch <= 32 & H.animal_name == names(i));
        sz = size(fill,1);
        fill = cellfun(@(x) x',fill,'UniformOutput',0);
        fill = cell2mat(fill);
        fill = fill(fill < -0.2);
        tot = size(fill,1);
        x = linspace(-1.01,-0.19,42);
        [n,~] = histcounts(fill,x);
        n = conv(n,gaussian_kernel,'same');
        n = n./sz;
        mn = median(n);
        xi = linspace(-1,-0.2,41);
        subplot(5,1,ii+1)
        patch([xi,fliplr(xi)],[n,zeros(1,size(n,2))],[0.1 0.2 0.8],'LineStyle','none');
        N{i} = [N{i}; n];
        S{i} = [S{i}; (tot./sz)];
        M{i} = [M{i}; mn];
        ylim([0 0.1])
    end
    sgtitle(names(i))
end
%% plot peaks
N = [];
for i = 0:4
fill = H.pk_time(H.exp_time == i & H.ch <= 32);
sz = size(fill,1);
fill = cellfun(@(x) x',fill,'UniformOutput',0);
fill = cell2mat(fill);
% figure;
% histogram(fill,'NumBins',20);
[n,~] = histcounts(fill,linspace(-1,1,21));
N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Injured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));

N = [];
for i = 0:4
fill = H.pk_time(H.exp_time == i & H.ch > 32);
sz = size(fill,1);
fill = cellfun(@(x) x',fill,'UniformOutput',0);
fill = cell2mat(fill);
% figure;
% histogram(fill,'NumBins',20);
[n,~] = histcounts(fill,linspace(-1,1,21));
N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Uninjured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));
%% plot troughs
N = [];
for i = 0:4
fill = H.tr(H.exp_time == i & H.ch <= 32);
sz = size(fill,1);
fill = cellfun(@(x) x',fill,'UniformOutput',0);
fill = cell2mat(fill);
% figure;
% histogram(fill,'NumBins',20);
[n,~] = histcounts(fill,linspace(-1,1,21));
N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Injured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));

N = [];
for i = 0:4
fill = H.tr(H.exp_time == i & H.ch > 32);
sz = size(fill,1);
fill = cellfun(@(x) x',fill,'UniformOutput',0);
fill = cell2mat(fill);
% figure;
% histogram(fill,'NumBins',20);
[n,~] = histcounts(fill,linspace(-1,1,21));
N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Uninjured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));
%% Make table for controls
listP = listBl;
listP.ch_id = chid;
listP(contains(listP.animal_name,'R20-99'),:) = [];
listP = listP(~isnan(listP.incl_control),:); 
idxP = cellfun(@isempty,listP.mod_99,'UniformOutput',1);
listP = listP(~idxP,:); 
idxG = findgroups(listP.animal_name,listP.incl_control);
[~,idxU] = unique(idxG);
remove = true(size(listP,1),1);
remove(idxU) = 0;
listP(logical(remove),:) = [];
% listP.incl_control = round(listP.incl_control./7).*7;
E = listP(:,[1,2,7]);
E.ch = cellfun(@(x,y) x(logical(y)),listP.ch_id,listP.mod_99,'UniformOutput',0);
E.vals = cellfun(@(x,y) x(logical(y),:),listP.ifr_vals,listP.mod_99,'UniformOutput',0);
an = cellfun(@(x,y) repelem(string(y),size(x,1),1),E.vals,E.animal_name,'UniformOutput',0);
bl = cellfun(@(x,y) repelem(string(y),size(x,1),1),E.vals,E.block_name,'UniformOutput',0);
exp = cellfun(@(x,y) repelem(y,size(x,1),1),E.vals,num2cell(E.incl_control),'UniformOutput',0);
J.animal_name = vertcat(an{:});
J.block_name = vertcat(bl{:});
J.exp_time = cell2mat(exp);
J.ch = cell2mat(E.ch);
J.vals = num2cell(cell2mat(E.vals),2);
J = struct2table(J);
[~, pk] = cellfun(@(x) findpeaks(x,'MinPeakHeight',3.09,'MinPeakDistance',15,'MinPeakProminence',0.1,'NPeaks',3),J.vals,'UniformOutput',0);
[~, tr] = cellfun(@(x) findpeaks(-x,'MinPeakHeight',3.09,'MinPeakDistance',15,'MinPeakProminence',0.1,'NPeaks',3),J.vals,'UniformOutput',0);
time = linspace(-1,1,100);
J.pk_time = cellfun(@(x) time(x),pk,'UniformOutput',0);
J.tr_time = cellfun(@(x) time(x),tr,'UniformOutput',0);
%% Divide into epochs

% gaussian filter
sigma = 2;
gaussian_range = -3*sigma:3*sigma;
gaussian_kernel = normpdf(gaussian_range,0,sigma);
gaussian_kernel = gaussian_kernel/sum(gaussian_kernel);

% set-up

nu = numel(names);
N = cell(1,1);
S = cell(1,1);
M = cell(1,1);
pJ = J(J.ch <= 32 & J.animal_name == 'R21-09',:);
dates = unique(pJ.exp_time);
for i = dates'
    fill = pJ.pk_time(pJ.exp_time == i);
    sz = size(fill,1);
    fill = cellfun(@(x) x',fill,'UniformOutput',0);
    fill = cell2mat(fill);
    fill = fill(fill < -0.2);
    tot = size(fill,1);
    x = linspace(-1.01,-0.19,42);
    [n,~] = histcounts(fill,x);
    n = conv(n,gaussian_kernel,'same');
    n = n./sz;
    mn = median(n);
    xi = linspace(-1,-0.2,41);
    N{1} = [N{1}; n];
    S{1} = [S{1}; (tot./sz)];
    M{1} = [M{1}; mn];
end
%% plot peaks
N = [];
for i = 1:7
    w = i*7;
    fill = J.pk_time(J.exp_time == w & J.ch <= 32);
    sz = size(fill,1);
    fill = cellfun(@(x) x',fill,'UniformOutput',0);
    fill = cell2mat(fill);
    % figure;
    % histogram(fill,'NumBins',20);
    [n,~] = histcounts(fill,linspace(-1,1,21));
    N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Injured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));

N = [];
for i = 1:7
    w = i*7;
    fill = J.pk_time(J.exp_time == w & J.ch > 32);
    sz = size(fill,1);
    fill = cellfun(@(x) x',fill,'UniformOutput',0);
    fill = cell2mat(fill);
    % figure;
    % histogram(fill,'NumBins',20);
    [n,~] = histcounts(fill,linspace(-1,1,21));
    N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Uninjured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));
%% plot troughs
N = [];
for i = 1:7
    w = i*7;
    fill = J.tr_time(J.exp_time == w & J.ch <= 32);
    sz = size(fill,1);
    fill = cellfun(@(x) x',fill,'UniformOutput',0);
    fill = cell2mat(fill);
    % figure;
    % histogram(fill,'NumBins',20);
    [n,~] = histcounts(fill,linspace(-1,1,21));
    N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Injured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));

N = [];
for i = 1:7
    w = i*7;
    fill = J.tr_time(J.exp_time == w & J.ch > 32);
    sz = size(fill,1);
    fill = cellfun(@(x) x',fill,'UniformOutput',0);
    fill = cell2mat(fill);
    % figure;
    % histogram(fill,'NumBins',20);
    [n,~] = histcounts(fill,linspace(-1,1,21));
    N = [N; (smoothdata(n./sz))];
end
figure;
plot(N')
title('Uninjured Hemisphere')
xlim([1 20]);
xticks(linspace(1,20,11));
xticklabels(linspace(-1,1,11));