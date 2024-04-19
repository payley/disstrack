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
%% Run statistical test
B(1:3,:) = [];
B = rows2vars(B);
B.Properties.VariableNames{1} = 'Animals';
B.Properties.VariableNames{2} = 'preInj';

% make plot
bb = table2array(B(:,2:end));
statsB(1:4,:) = quantile(bb,[0 0.25 0.75 1]);
statsB(5,:) = mean(bb);
x = [1 2 3 4 5 5 4 3 2 1];
y1 = [statsB(1,:), flip(statsB(4,:))];
y2 = [statsB(2,:), flip(statsB(3,:))];
figure;
patch(x,y1,[0.9 0.95 1],'EdgeColor','none');
hold on
patch(x,y2,[0.6 0.8 1],'EdgeColor','none');
plot(statsB(5,:),'k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylim([0 100]);
xticks([1 2 3 4 5]);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Percent success');

% run tests
holdB = table2array(B(:,2:end));
[p,tbl,stats] = friedman(holdB); % Friedman's test
holdB = asin(sqrt(holdB/100));
B{:,2:end} = holdB;
winvar = table((1:5)','VariableNames',{'Time'});
rm = fitrm(B, 'preInj-postInj4~1', 'WithinDesign', winvar); 
ra = ranova(rm)
mc = multcompare(rm,'Time')
holdB = reshape(holdB,[],1) ;
figure;
histogram(holdB);
[h_jb, p_jb, jb_stat] = jbtest(holdB);
figure;
qqplot(holdB);