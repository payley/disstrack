%% Load behavioral results 
load("behavioral_results_inj.mat")
%% Plot behavioral results
holdB = table2array(B(4:8,:));
figure;
hold on
plot(holdB,'black');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([0 100]);
xticks([1 2 3 4 5]);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Percent success');
xline(1.5,'red');
%% Plot normalized behavioral results
holdB = table2array(B(4:8,:));
holdB(2:5,:) = (holdB(2:5,:)./holdB(1,:))*100;
holdB(1,:) = 100;
figure;
hold on
plot(holdB,'black');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([0 120]);
xticks([1 2 3 4 5]);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Percent success relative to baseline');
xline(1.5,'red');
%% Plot first success behavioral results
load("behavioral_results_inj_firstsuccess.mat")
holdB = table2array(B(4:8,:));
figure;
hold on
plot(holdB,'black');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([0 100]);
xticks([1 2 3 4 5]);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Percent success');
xline(1.5,'red');