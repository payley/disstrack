%% Epoch test
%% Fix channel id
chid = listBl.ch_id;
sz = cellfun(@(x) size(x,1),chid);
hld = cellfun(@(x) x+16,chid(sz == 48),'UniformOutput',0);
chid(sz == 48) = deal(hld);
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
listP = listP(~isnan(listBl.exp_time),:); 
idxG = findgroups(listP.animal_name,listP.exp_time);
[~,idxU] = unique(idxG);
remove = true(size(listP,1),1);
remove(idxU) = 0;
listP(logical(remove),:) = [];
E = listP(:,[1,2,4]);
E.ch = cellfun(@(x,y) x(logical(y)),listP.ch_id,listP.ch_mfr,'UniformOutput',0);
idxP = cellfun(@(x) x(x < 33),listP.ch_id,'UniformOutput',0);
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
idxI = ismember(H.ch, 1:32);
idxC = ismember(H.ch, 33:64);
H.arr = cell(size(H.ch,1),1);
H.arr(idxI) = {deal('Ipsi')};
H.arr(idxC) = {deal('Contra')};
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
ep1 = find(t < -0.2);
ep2 = find(t >= -0.2 & t <= 0.2);
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
%% Run lme
% formula = 'epoch1_mean ~ exp_time + exp_time:arr + deficit:exp_time + deficit + arr +(1|animal_name:ch)';
formula = 'epoch1_mean ~ exp_time + exp_time:arr + arr +(1|animal_name:ch)';
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

% formula = 'epoch2_mean ~ exp_time + exp_time:arr + deficit:exp_time + deficit + arr + (1|animal_name:ch)';
formula = 'epoch2_mean ~ exp_time + exp_time:arr + arr +(1|animal_name:ch)';
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

% formula = 'epoch3_mean ~ exp_time + exp_time:arr + deficit:exp_time + deficit + arr + (1|animal_name:ch)';
formula = 'epoch3_mean ~ exp_time + exp_time:arr + arr +(1|animal_name:ch)';
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
%% Run lme
% epoch 1
formula = 'epoch1_mean ~ 1 + behavior + exp_time + exp_time:behavior + exp_time:epoch1_ctrl + behavior:epoch1_ctrl + (1|epoch1_ctrl)';
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
tx = linspace(0.5,4.5,12);
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

idxC = strcmp(table2array(coeff_all(:,1)),'exp_time:behavior');
timXbeh = table2array(coeff_all(idxC,2));
figure;
for i = 1:4
    idxTP = expH.exp_time == i;
    subplot(4,1,i)
    scatter(expH.behavior(idxTP),expH.epoch1_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    plot(bx,intc + i*bx*timXbeh,'k');
end

% epoch 2
formula = 'epoch2_mean ~ 1 + behavior + exp_time + exp_time:behavior + exp_time:epoch2_ctrl + behavior:epoch2_ctrl + (1|epoch2_ctrl)';
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

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
xval = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure; 
scatter(expH.behavior,expH.epoch2_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(xval,intc + beh*xval,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 2');

idxT = strcmp(table2array(coeff_all(:,1)),'exp_time');
tim = table2array(coeff_all(idxT,2));
xval = linspace(0.5,4.5,12);
figure('Position',[0,0,250,450]);  
scatter(expH.exp_time,expH.epoch2_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
plot(xval,intc + tim*xval,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 40]);
xlim([0 5]);
xticks(1:4);
xticklabels({'Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Mean Z-score');
title('Epoch 2');

idxC = strcmp(table2array(coeff_all(:,1)),'exp_time:behavior');
timXbeh = table2array(coeff_all(idxC,2));
figure;
for i = 1:4
    idxTP = expH.exp_time == i;
    subplot(4,1,i)
    scatter(expH.behavior(idxTP),expH.epoch2_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    plot(bx,intc + i*bx*timXbeh,'k');
end

% epoch 3
formula = 'epoch3_mean ~ 1 + behavior + exp_time + exp_time:behavior + exp_time:epoch3_ctrl + behavior:epoch3_ctrl + (1|epoch3_ctrl)';
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

intc = table2array(coeff_all(1,2));
idxB = strcmp(table2array(coeff_all(:,1)),'behavior');
beh = table2array(coeff_all(idxB,2));
xval = linspace(min(expH.behavior)-5, max(expH.behavior)+5, 100);
figure; 
scatter(expH.behavior,expH.epoch3_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.2);
hold on
plot(xval,intc + beh*xval,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 50]);
ylabel('Mean Z-score');
xlabel('Normalized behavior ability');
title('Epoch 3');

idxT = strcmp(table2array(coeff_all(:,1)),'exp_time');
tim = table2array(coeff_all(idxT,2));
xval = linspace(0.5,4.5,12);
figure('Position',[0,0,250,450]); 
scatter(expH.exp_time,expH.epoch3_mean,'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
hold on
plot(xval,intc + tim*xval,'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([-10 40]);
xlim([0 5]);
xticks(1:4);
xticklabels({'Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Mean Z-score');
title('Epoch 3');

idxC = strcmp(table2array(coeff_all(:,1)),'exp_time:behavior');
timXbeh = table2array(coeff_all(idxC,2));
figure;
for i = 1:4
    idxTP = expH.exp_time == i;
    subplot(4,1,i)
    scatter(expH.behavior(idxTP),expH.epoch3_mean(idxTP),'filled','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerFaceAlpha',.1);
    hold on
    plot(bx,intc + i*bx*timXbeh,'k');
end
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