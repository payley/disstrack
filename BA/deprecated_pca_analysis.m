%% Deprecated pca analysis methods
%% Split by array
win_start = -100; % window start time in ms
win_end = 100; % window end time in ms
t = linspace(-1000,1000,100);
idxT = t >= win_start & t <= win_end;
arr = [zeros(32,1); ones(32,1)];
idxA = logical([arr; arr; arr; arr; arr]);
rates = cell2mat(listBl.ifr_vals(90:94));
ratesIH = rates(~idxA,idxT);
ratesUH = rates(idxA,idxT);
%% Run PCA on IH
[coeff,score,~,~,expl,~] = pca(ratesIH);

figure;
bar(expl(1:10));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
xlabel('PCs');
ylim([0 100]);
ylabel('Percent Explained');
title('Percent Explained by PCs in R23-06');

figure;
hold on
plot(coeff(:,1:3));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
nsamp = size(ratesIH,2);
xticks(linspace(1,nsamp,5));
xticklabels(linspace(win_start,win_end,5));
xlabel('Time (ms)');
ylabel('Coeffecient');

for i = 1:3
    date = zeros(32,1);
    date_full = [date; date + 1; date + 2; date + 3; date + 4];
    T = table(score(:,i), date_full, 'VariableNames',{'data','date'});
    figure('Position',[0,0,700,800]);
    b = boxchart(T.date,T.data);
    xlim([-0.5 4.5]);
    xticks(0:4);
    ylabel(sprintf('PC%d',i));
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    box off
end
%% Run PCA on UH
[coeff,score,~,~,expl,~] = pca(ratesUH);

figure;
bar(expl(1:10));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
xlabel('PCs');
ylim([0 100]);
ylabel('Percent Explained');
title('Percent Explained by PCs in R23-06');

figure;
hold on
plot(coeff(:,1:3));
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
nsamp = size(ratesIH,2);
xticks(linspace(1,nsamp,5));
xticklabels(linspace(win_start,win_end,5));
xlabel('Time (ms)');
ylabel('Coeffecient');

for i = 1:3
    date = zeros(32,1);
    date_full = [date; date + 1; date + 2; date + 3; date + 4];
    T = table(score(:,i), date_full, 'VariableNames',{'data','date'});
    figure('Position',[0,0,700,800]);
    b = boxchart(T.date,T.data);
    xlim([-0.5 4.5]);
    xticks(0:4);
    ylabel(sprintf('PC%d',i));
    set(gca,'TickDir','out','FontName', 'NewsGoth BT');
    box off
end