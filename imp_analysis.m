%% Supplementary figures on impedances
%% Example of stability of arrays over time
% load('C:\MyRepos\disstrack\Impedance\R20-99 impedances.mat')
I = impT(:,[3:2:23]);
ii = [];
tt = [];
listT = [4,10,20,27,32,49,52,84,132,138,140]; % assay date after implant in days
for i = 1:11
 ii = [ii; I{:,i}];
 tt = [tt; repmat(listT(i),64,1)];
end
ii = ii/1e6; % convert to megaOhms
figure;
hold on
yline(1,'--')
boxchart(tt,ii,'MarkerStyle','none','BoxWidth',1.5,'BoxFaceColor',[0 0.4470 0.7410],'BoxLineColor','k');
ylim([0 14])
xlabel('Days after implant')
ylabel('Impedance (MOhms)')
xticks([0:25:150]);
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
title('Stability of arrays over time')
%% Channel variation by animal
cd C:\MyRepos\disstrack\Impedance
D = dir;
D = D(~ismember({D.name},{'.','..'}));
R = [];
name = [];
for i = 1:size(D,1)
load(D(i).name)
meta = strsplit(D(i).name,' ');
name = [name, {char(meta(1))}];
mimpT = table2array(impT(:,contains(impT.Properties.VariableNames,'mean')));
R = [R range(mimpT,2)];
end
R = array2table(R./1e6);
R.Properties.VariableNames = name;
figure;
hold on
boxchart(table2array(R),'MarkerStyle','none','BoxLineColor','k');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylabel('Impedance range (MOhms)')
xticklabels(name)
ylim([0 15])
title('Variability of channel impedance over time by rat')
%% Median variation by animal
cd C:\MyRepos\disstrack\Impedance
D = dir;
D = D(~ismember({D.name},{'.','..'}));
R = [];
name = [];
for i = [5,7:14]
load(D(i).name)
meta = strsplit(D(i).name,' ');
name = [name; {char(meta(1))}];
mimpT = table2array(impT(:,contains(impT.Properties.VariableNames,'mean')));
R = [R; {nanmedian(mimpT,1)./1e6}];
end
R = array2table(R);
R.Properties.RowNames = name;
%% Plot median variation
cd C:\MyRepos\disstrack\Impedance
load('C:\MyRepos\disstrack\exp_block_names.mat');
D = dir;
D = D(~ismember({D.name},{'.','..'}));
R = nan(18,5);
c = 0;
for i = [5,7:14]
c = c + 2;
load(D(i).name)
mimpT = impT(:,contains(impT.Properties.VariableNames,'mean'));
mimpT = table2array(mimpT(:,contains(mimpT.Properties.VariableNames,exp_blocks)));
if size(mimpT,2) > 5 % takes care of exception where blocks were recorded on the same day
    mimpT = mimpT(:,2:6);
end
R(c-1,:) = median(mimpT(1:32,:),1);
R(c,:) = median(mimpT(33:64,:),1);
end
R = R./1e6;
cat = repmat(["Baseline","Post-Lesion 1","Post-Lesion 2","Post-Lesion 3","Post-Lesion 4"],18,1);
cat = [cat(:,1);cat(:,2);cat(:,3);cat(:,4);cat(:,5)];
val = [R(:,1);R(:,2);R(:,3);R(:,4);R(:,5)];
swarmchart(categorical(cat),val,'filled');
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
ylabel(sprintf('Impedance (M%c)',char(937)));
title('Median impedances of arrays');