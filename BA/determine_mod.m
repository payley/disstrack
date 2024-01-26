%% Determine presence of modulation in activity around behavior
%% Test if each channel is modulated
% crit_val = 1.96; % two tailed for p val of 0.05
crit_val = 2.57; % two tailed for p val of 0.01
bin_sz = 20;
meth = 'ifr'; % select either 'bin' or 'ifr' for the method for determining modulation
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
switch meth
    case 'bin'
        bin_vals = cell(nBl,1);
        for i = 1:nBl
            if listBl.exp_group(i) == 1 && ~isnan(listBl.exp_time(i))
                idxR = contains(aArrs{1}.Properties.RowNames,listBl.animal_name{i});
                idxC = listBl.exp_time(i) + 1;
                all = [aArrs{1}{idxR,idxC}{1}; aArrs{2}{idxR,idxC}{1}]; % ordered injured hemisphere first and NOT native array order
                all = bin_data(all,bin_sz,30000);
                zm = listBl.z_mean{i};
                zs = listBl.z_stdev{i};
                nn = listBl.n_succ(i);
%                 zz = (all - zm)./(zs/sqrt(nn));
                zz = (all - zm)./(zs); % necessary to include n?
                zz(isnan(zz)) = 0;
                bin_vals{i} = zz;
                idxCh = zz >= crit_val | zz <= -crit_val;
                check = sum(idxCh,2);
                check(check >= 1) = 1;
                % additional removal of channels with <1Hz baseline mfr
                if sum(zm < bin_sz/1000) > 0
                    idxExcl{i} = zm < bin_sz/1000;
                    check(zm < bin_sz/1000) = 0;
                end
                mod_95{i} = check;
                fprintf('%s Exp Timepoint %d\n',aArrs{1}.Properties.RowNames{idxR},listBl.exp_time(i));
                fprintf('%d channels with modulation\n',sum(check));
            else
                continue
            end
        end
    case 'ifr'
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
%                     tAll = conv(all(ii,:),gaussian_kernel,'same'); % gaussian
                    tAll = filtfilt(b,a,all(ii,:)); % butterworth
%                     tAll = smooth(all(ii,:),25,'sgolay',3); % savitsky-golay
                    all(ii,:) = tAll;
                end
                sm_rates{i} = all;
                zm = listBl.z_mean{i};
                zs = listBl.z_stdev{i};
                nn = listBl.n_succ(i);
%                 zz = (all - zm)./(zs/sqrt(nn));
                zz = (all - zm)./(zs); % necessary to include n?
                zz(isnan(zz)) = 0;
                ifr_vals{i} = zz;
                idxCh = zz >= crit_val | zz <= -crit_val;
                check = sum(idxCh,2);
                check(check >= 1) = 1;
                % additional removal of channels with <1Hz baseline mfr
%                 if sum(zm < bin_sz/1000) > 0
%                     idxExcl{i} = zm < bin_sz/1000;
%                     check(zm < bin_sz/1000) = 0;
%                 end
                check(~listBl.ch_mfr{i}) = 0; % removes channels with low firing rate from consideration
                mod_95{i} = check;
                fprintf('%s Exp Timepoint %d\n',aArrs{1}.Properties.RowNames{idxR},listBl.exp_time(i));
                fprintf('%d channels with modulation\n',sum(check));
            else
                continue
            end
        end
end

% check on excluded channels may comment out later
% ch_mfr = listBl.ch_mfr(~cellfun(@isempty,idxExcl));
% idxExcl = idxExcl(~cellfun(@isempty,idxExcl));
% incl = sum(cellfun(@sum,ch_mfr));
% tot = sum(cellfun(@numel,ch_mfr));
% idxM = cellfun(@(x,y) xor(x,~y),idxExcl,ch_mfr,'UniformOutput',false);
% ch_mfr2 = cellfun(@(x,y) x&y,idxExcl,idxM,'UniformOutput',false);
% add = sum(cellfun(@sum,ch_mfr2));
% new = sum(cellfun(@(x,y) sum(~x|y),idxExcl,ch_mfr));
% fprintf('%2.1f percent of channels are included based on 1Hz MFR threshold\n',(new/tot)*100);
% fprintf('%2d channels excluded in first step\n',tot-incl);
% fprintf('%2d channels excluded in second step\n',add);

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