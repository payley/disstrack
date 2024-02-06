%% Determine presence of modulation in activity around behavior
%% Count number of success and put into a variable
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
n_succ = zeros(size(listBl,1),1);
idxU = zeros(size(listBl,1),1);
[~,idxU1] = unique(listBl(:,[1,4])); % find unique blocks for each experimental timepoint
[~,idxU2] = unique(listBl(:,[1,7])); % find unique blocks for each experimental timepoint
idxU1(isnan(listBl.exp_time(idxU1))) = [];
idxU2(isnan(listBl.incl_control(idxU2))) = [];
idxU(idxU1) = 1;
idxU(idxU2) = 1;
nUniq = sum(idxU);
fU = find(idxU);
for i = 1:nUniq
    refN = fU(i); % id corresponding index for table
    check1 = listBl(refN,[1,4]);
    c1 = ismember(listBl(:,[1,4]),check1,"rows");
    check2 = listBl(refN,[1,7]);
    c2 = ismember(listBl(:,[1,7]),check2,"rows");
    if sum(c1) > 1
        c = c1;
        nC = sum(c1);
    elseif sum(c2) > 1
        c = c2;
        nC = sum(c2);
    else
        nC = 1;
    end
    if nC == 1
        load(fullfile(cDir,listBl.animal_name{refN},[listBl.block_name{refN} '_Block.mat']));
        if ~isempty(blockObj.Events)
            n_succ(refN) = sum(contains([blockObj.Events.Name],'GraspStarted'));
        end
    else
        nn = zeros(nC,1);
        for ii = 1:nC
            f = find(c);
            iC = f(ii);
            load(fullfile(cDir,listBl.animal_name{iC},[listBl.block_name{iC} '_Block.mat']));
            if ~isempty(blockObj.Events)
                nn(ii) = sum(contains([blockObj.Events.Name],'GraspStarted'));
            end
        end
        n_succ(c) = sum(nn);
    end
end
%% Test if each channel is modulated
% crit_val = 1.96; % two tailed for p val of 0.05
crit_val = 2.57; % two tailed for p val of 0.01
bin_sz = 20;
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
if ~(exist('listBA_injH','var'))
    load('aligned_succ_injH_list.mat')
    load('aligned_succ_uninjH_list.mat')
end
aArrs = {listBA_injH,listBA_uninjH};
nBl = size(listBl,1);
mod_95 = cell(nBl,1);
idxExcl = cell(nBl,1);
ifr_vals = cell(nBl,1);
sm_rates = cell(nBl,1);
% gaussian filter
sigma = 2;
gaussian_range = -3*sigma:3*sigma;
gaussian_kernel = normpdf(gaussian_range,0,sigma);
gaussian_kernel = gaussian_kernel/sum(gaussian_kernel);
% butterworth filter
fs = 1/(bin_sz/1000);
[b,a] = butter(4, 5/(fs/2), 'low');
for i = 1:nBl
    if listBl.exp_group(i) == 1 && ~isnan(listBl.exp_time(i))
        idxR = contains(aArrs{1}.Properties.RowNames,listBl.animal_name{i});
        idxC = listBl.exp_time(i) + 1;
        all = [aArrs{1}{idxR,idxC}{1}; aArrs{2}{idxR,idxC}{1}]; % ordered injured hemisphere first and NOT native array order
        all = bin_data(all,bin_sz,30000);
        for ii = 1:size(all,1)
%            tAll = conv(all(ii,:),gaussian_kernel,'same'); % gaussian
%            tAll = smooth(all(ii,:),25,'sgolay',3); % savitsky-golay
            tAll = filtfilt(b,a,all(ii,:)); % butterworth
            all(ii,:) = tAll;
        end
        sm_rates{i} = all;
        zm = listBl.z_mean{i};
        zs = listBl.z_stdev{i};
        nn = listBl.n_succ(i);
%        zz = (all - zm)./(zs/sqrt(nn));
        zz = (all - zm)./(zs); % necessary to include n?
        zz(isnan(zz)) = 0;
        zz(isinf(zz)) = 0;
        ifr_vals{i} = zz;
        idxCh = zz >= crit_val | zz <= -crit_val;
        check = sum(idxCh,2);
        check(check >= 1) = 1;
        check(~listBl.ch_mfr{i}) = 0; % removes channels with low firing rate from consideration
        mod_95{i} = check;
        fprintf('%s Exp Timepoint %d\n',aArrs{1}.Properties.RowNames{idxR},listBl.exp_time(i));
        fprintf('%d channels with modulation\n',sum(check));
    elseif isnan(listBl.exp_time(i)) && listBl.incl_control(i) < 60 && sum(contains({'R22-28','R22-29'},listBl.animal_name{i})) == 0
        idxU = contains(listBl_ctrl.animal_name,listBl.animal_name{i}) & listBl_ctrl.exp_time == listBl.incl_control(i);
        if isempty(listBl_ctrl.injH_align{idxU})
            continue
        end
        all = [listBl_ctrl.injH_align{idxU}; listBl_ctrl.uninjH_align{idxU}]; % ordered injured hemisphere first and NOT native array order
        fs = size(all,2)/2;
        all = bin_data(all,bin_sz,fs);
        for ii = 1:size(all,1)
%            tAll = conv(all(ii,:),gaussian_kernel,'same'); % gaussian
%            tAll = smooth(all(ii,:),25,'sgolay',3); % savitsky-golay
            tAll = filtfilt(b,a,all(ii,:)); % butterworth
            all(ii,:) = tAll;
        end
        sm_rates{i} = all;
        zm = listBl.z_mean{i};
        zs = listBl.z_stdev{i};
        nn = listBl.n_succ(i);
%        zz = (all - zm)./(zs/sqrt(nn));
        zz = (all - zm)./(zs); % necessary to include n?
        zz(isnan(zz)) = 0;
        zz(isinf(zz)) = 0;
        ifr_vals{i} = zz;
        idxCh = zz >= crit_val | zz <= -crit_val;
        check = sum(idxCh,2);
        check(check >= 1) = 1;
        check(~listBl.ch_mfr{i}) = 0; % removes channels with low firing rate from consideration
        mod_95{i} = check;
        fprintf('%s_%s\n',listBl.animal_name{i},listBl.block_name{i});
        fprintf('%d channels with modulation\n',sum(check));
    end
end

clearvars -except listBl listBA_injH listBA_uninjH listUA_injH listUA_uninjH ch_mfr2 mod_95 bin_vals ifr_vals sm_rates
%% Calculate modulation out of total channels
nBl = size(listBl,1);
sum_mod = cell(1,5);
sum_ch = cell(1,5);
for i = 1:5
    idxT = listBl.exp_time == i-1;
    if size(unique(listBl.animal_name(idxT)),1) < size(listBl.animal_name(idxT),1)
        [~,a,~] = unique(listBl.animal_name(idxT));
        check = find(idxT);
        check = check(a);
        idxT(:) = 0;
        idxT(check) = 1;
    end
    sum_mod{i} = cellfun(@sum,listBl.mod_95(idxT));
    sum_ch{i} = cellfun(@sum,listBl.ch_mfr(idxT)); % should channels included by fr be the denominator or channel total?
end
prop_all = cellfun(@(x,y) x./y,sum_mod,sum_ch,'UniformOutput',false);
prop_cat = [repmat(1,size(prop_all{1},1),1); repmat(2,size(prop_all{2},1),1); repmat(3,size(prop_all{3},1),1);...
    repmat(4,size(prop_all{4},1),1); repmat(5,size(prop_all{5},1),1)];
prop_all = [prop_all{1}; prop_all{2}; prop_all{3}; prop_all{4}; prop_all{5}];
boxplot(prop_all*100,prop_cat,'BoxStyle','filled','Symbol','*','Colors','k');
set(gca,'TickDir','out','FontName','NewsGoth BT');
box off
ylim([50 100]);
xticklabels({'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'});
ylabel('Percent modulated channels');