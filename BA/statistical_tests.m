%% Statistical tests
%% Friedman's test for average MFR
mfr = table2array(listMFR(:,6:10));
[p,tbl,stats] = friedman(mfr,1,'off'); % Friedman's test
fprintf('p = %0.3f that MFR is unchanged between timepoints\n',p);
posthoc = multcompare(stats);
T = array2table(posthoc,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])
%% Friedman's test for split MFR
mfr = table2array(listMFR(:,11:15));
[p,tbl,stats] = friedman(mfr(:,1:2:9),1,'off'); % Friedman's test for IH
fprintf('p = %0.3f that MFR is unchanged between timepoints in injured hemisphere\n',p);
[p,tbl,stats] = friedman(mfr(:,2:2:10),1,'off'); % Friedman's test for UH
fprintf('p = %0.3f that MFR is unchanged between timepoints in uninjured hemisphere\n',p);
posthoc = multcompare(stats);
T = array2table(posthoc,"VariableNames", ...
    ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"])

ipsi = cellfun(@(x) x(1:32,1),listMFR{:,1:4},'UniformOutput',false);
contra = cellfun(@(x) x(33:64,1),listMFR{:,1:4},'UniformOutput',false);
ipsi(2:end,5) = cellfun(@(x) x(1:32,1),listMFR{2:9,5},'UniformOutput',false);
contra(2:end,5) = cellfun(@(x) x(33:64,1),listMFR{2:9,5},'UniformOutput',false);
ipsi{1,5} = listMFR{1,5}{1}(1:16,:);
contra{1,5} = listMFR{1,5}{1}(17:48,1);
for i = 1:5
    fill = ranksum(cell2mat(ipsi(:,i)),cell2mat(contra(:,i)));
    fprintf('p = %0.3f that there is no difference between MFR in hemispheres at timepoint %d\n',fill,i);
end
%% Chi-square comparing two proportions method 1
% run determine_mod.m to get sum_ch sum_mod variables
sum_unmod = cellfun(@(x,y) x-y,sum_ch,sum_mod,'UniformOutput',0);
n_mod = cellfun(@sum,sum_mod);
n_unmod = cellfun(@sum,sum_unmod);
base_mod = cell(2,1);
base_unmod = cell(2,1);
nbase = cell(2,1);
base_mod{1} = ones(n_mod(1,1),1);
base_unmod{1} = zeros(n_unmod(1,1),1);
base_mod{2} = ones(n_mod(2,1),1);
base_unmod{2} = zeros(n_unmod(2,1),1);
nbase{1} = sum(sum_ch{1,1});
nbase{2} = sum(sum_ch{2,1});
list = {'ipsilesional RFA','contralesional RFA'};
nprop = cell(2,5);
nprop{1,1} =  n_mod(1,1)/nbase{1};
nprop{2,1} =  n_mod(2,1)/nbase{2};
for i = 1:2
    for ii = 1:4
        test_mod = ones(n_mod(i,ii+1),1);
        test_unmod = zeros(n_unmod(i,ii+1),1);
        ntest = sum(sum_ch{i,ii+1});
        vals  = [base_mod{i}; base_unmod{i}; test_mod; test_unmod];
        cats = [zeros(nbase{i},1); ones(ntest,1)];
        [tbl,chi2stat,pval] = crosstab(cats,vals);
        fprintf('p = %1.5f for %s at week %d compared to baseline\n',pval,list{i},ii);
        nprop{i,ii+1} =  n_mod(i,ii+1)/ntest;
    end
end
figure;
plot(cell2mat(nprop(1,:)));
hold on
plot(cell2mat(nprop(2,:)));
%% Chi-square comparing two proportions method 2
% run determine_mod.m to get sum_ch sum_mod variables
sum_unmod = cellfun(@(x,y) x-y,sum_ch,sum_mod,'UniformOutput',0);
n_mod = cellfun(@sum,sum_mod);
n_unmod = cellfun(@sum,sum_unmod);
base_mod = cell(2,1);
base_unmod = cell(2,1);
nbase = cell(2,1);
nbase{1} = sum(sum_ch{1,1});
nbase{2} = sum(sum_ch{2,1});
list = {'ipsilesional RFA','contralesional RFA'};
nprop = cell(2,5);
nprop{1,1} =  n_mod(1,1)/nbase{1};
nprop{2,1} =  n_mod(2,1)/nbase{2};
for i = 1:2
    for ii = 1:4
        ntest = sum(sum_ch{i,ii+1});
        observed = [n_mod(i,ii) n_unmod(i,ii)];
        bprop = round(ntest*nprop{i,1});
        expected = [bprop ntest-bprop];
        chi2stat = sum((observed-expected).^2 ./ expected);
        chi2stat = chi2stat - 0.5; % Yates correction
        pval = 1 - chi2cdf(chi2stat,1);
        fprintf('p = %1.5f for %s at week %d compared to baseline\n',pval,list{i},ii);
        nprop{i,ii+1} =  n_mod(i,ii+1)/ntest;
    end
end
figure;
plot(cell2mat(nprop(1,:)));
hold on
plot(cell2mat(nprop(2,:)));
%% Wilcoxon sign rank
% removed animals with missing data
fdr = 0.20; % set false discovery rate
idx = [1:3 6:9]';
list = {'ipsilesional RFA','contralesional RFA'};
P = cell(2,1);
for i = 1:2
    for ii = 1:4
        pval = signrank(prop_all{i,1},prop_all{i,ii+1}(idx));
        P{i} = [P{i}; pval];
    end
    nP{i} = sort(P{i},'ascend');
    tot = size(P{i},1);
    for c = 1:tot
        thresh = (c/tot)*fdr;
        pval = P{i}(c);
        wk = find(P{i} == nP{i}(c));
        if pval < thresh
            fprintf('*p = %1.3f* for %s at week %d compared to baseline\n',pval,list{i},wk);
        else
            fprintf('p = %1.3f for %s at week %d compared to baseline\n',pval,list{i},wk);
        end
    end
end
%% Mann-Whitney rank sum equiv. for differences in KS summary
if size(unique(cdfAll.ch),1) > 2
    cdfAll.ch(cdfAll.ch < 33) = 0;
    cdfAll.ch(cdfAll.ch > 32) = 1;
end
[G, l] = findgroups(cdfAll.cat);
[p, ~, stats] = ranksum(cdfAll.cdf(G == 1),cdfAll.cdf(G == 2)) % not a significant difference if you remove R20-99
[G, l] = findgroups(cdfAll.cat,cdfAll.ch);
[p, ~, stats] = ranksum(cdfAll.cdf(G == 1),cdfAll.cdf(G == 3)) % significant
[p, ~, stats] = ranksum(cdfAll.cdf(G == 2),cdfAll.cdf(G == 4)) % not significant
%% glm
T.prop_all = prop_all/100;
T.prop_arr = prop_arr/1.5;
mdl = fitglm(T,T.prop_all,'linear','CategoricalVars',"prop_arr");