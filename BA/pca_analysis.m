%% Choose indices for analysis
idxD = 90:94;
%% Organize data table for individual  animal
win_start = -250; % window start time in ms
win_end = 250; % window end time in ms
t = linspace(-1000,1000,100);
idxT = t >= win_start & t <= win_end;
rates = cell2mat(listBl.ifr_vals(idxD));
rates = rates(:,idxT);
%% Organize data table for individual animal and timepoints
win_start = -500; % window start time in ms
win_end = 0; % window end time in ms
t = linspace(-1000,1000,100);
idxT = t >= win_start & t <= win_end;
rates = [];
array = [];
time = [];
for i = idxD
    rr = cell2mat(listBl.ifr_vals(i));
    idxR = logical(listBl.ch_mfr{i}) & logical(listBl.mod_99{i});
    rr = rr(idxR,:);
    rates = [rates; rr];
    aa = cell2mat(listBl.arr_id{i});
    aa = aa(idxR);
    array = [array; aa];
    t = repmat(listBl.exp_time(i),size(aa,1),1);
    time = [time; t];
end
rates = rates(:,idxT);
array = cellstr(array);
D = table(array,time,rates);
%% Run PCA
idx = ones(size(D,1));
time = 0;
array = [];
if ~isempty(time)
    idx = (D.time == time);
end
if ~isempty(array)
    idx = contains(D.array,array);
end
[coeff,score,latent,~,expl,m] = pca(rates(idx,:));
%% Run PCA on secondary data
nscore = cell(4,1);
for i = 1:4
    nscore{i} = (rates((D.time == i),:)- m) * coeff;
end
nscore = cell2mat(nscore);
D.score = [score; nscore];
% how do I backcalculate variance?
%% Plot percent explained
figure;
bar(expl(1:10));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
xlabel('PCs');
ylim([0 100]);
ylabel('Percent Explained');
title('Percent Explained by PCs in R23-06');
%% Plot components
figure;
hold on
plot(coeff(:,1:4));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
% nsamp = size(rates,2);
% xticks(linspace(1,nsamp,5));
% xticklabels(linspace(win_start,win_end,5));
% xlabel('Time (ms)');
% ylabel('Coeffecient');
%% Plot scores across component combinations
figure;
scatter(score(:,1),score(:,2));  
xlabel('PC1');
ylabel('PC2');
title('Injured Hemisphere')
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off

figure;
hold on
for i = 1:2:9
    ie = 32*i;
    is = ie - 31;
    scatter(score(is:ie,2),score(is:ie,3));  
end
xlabel('PC2');
ylabel('PC3');
title('Injured Hemisphere')
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off

figure;
hold on
for i = 2:2:10
    ie = 32*i;
    is = ie - 31;
    scatter(score(is:ie,1),score(is:ie,2));  
end
xlabel('PC1');
ylabel('PC2');
title('Uninjured Hemisphere')
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off

figure;
hold on
for i = 2:2:10
    ie = 32*i;
    is = ie - 31;
    scatter(score(is:ie,2),score(is:ie,3));  
end
xlabel('PC2');
ylabel('PC3');
title('Unnjured Hemisphere')
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
%% Secondary stats
for i = 1:4
    figure('Position',[0,0,700,800]);
    numv = zeros(size(D.array,1),1);
    numv(contains(D.array,'A')) = 0;
    numv(contains(D.array,'B')) = 1;
    b = boxchart(numv*1.5,D.score(:,i),'GroupByColor',D.time);
    xlim([-0.75 2.25]);
    xticks([0 1.5]);
    xticklabels({'Injured Hemisphere','Uninjured Hemisphere'});
    l = legend('Box','off');
    title(l,'Timepoints');
    ylabel(sprintf('PC%d',i));
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    box off
end
%% Reconstruct data
pc = 4;
Xt = D.score((D.time == 1),1:pc) * coeff(:,1:pc)' + m;
figure; hold on
rr = D.rates(D.time == 1,:);
plot(rr(20,:));
plot(Xt(20,:));