%% k-s test for stability
% basic design
%load block
t = -0.99:0.02:0.99;
sp = blockObj.getSpikeTimes(1);
succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
hh = [];
for iv = 1:size(succE,2)
    ev = succE(iv).Ts; % events in seconds and converted to samples
    idxV = sp(sp>(ev-1) & sp<=(ev+1)); % index of spike times that fall in the window 1s on either side of grasp
    winV = idxV - ev; % zeroing beginning of trial
    hh = [hh; winV];
end
figure;
histogram(hh);
hold on
d = fitdist(hh, 'Kernel');
pp = pdf(d,t);
plot(pp);
cc = cdf(d,t);
figure;
plot(cc);
%% ks test
% [ks,~] = (max(abs(cdfE - cdfS)));
% n1 = size(cdfE,2);
% n2 = size(cdfS,2);
n = n1 * n2 /(n1 + n2);
lambda = max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * ks, 0);
j = (1:100)';
pValue = 2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
p = min(max(pValue, 0), 1);
%% Test by animal
clearvars -except listBl
nm = 'R22-01';
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
t = -0.99:0.02:0.99;
aList = listBl(contains(listBl.animal_name,nm),:);
d = split(aList.block_name,'-');
dates = d(:,2);
[~,idxU] = unique(dates);
for i = idxU'
    if size(aList.arr_id{i},1) < 48
        continue
    end
    load(fullfile(cDir,nm,[aList.block_name{i} '_Block.mat']))
    C{i} = [];
    K{i} = [];
    ch = cell(size(aList.ch_id{i},1),1);
    chL = aList.ch_id{i}';
    for ii = 1:size(chL,2)
        chID = chL(ii);
        sp = blockObj.getSpikeTimes(chID);
        succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
        for iv = 1:size(succE,2)
            ev = succE(iv).Ts; % events in seconds and converted to samples
            idxV = sp(sp>(ev-1) & sp<=(ev+1)); % index of spike times that fall in the window 1s on either side of grasp
            winV = idxV - ev; % zeroing beginning of trial
            ch{ii} = [ch{ii}; winV];
        end
        fprintf('Ch %d\n',chID)
    end
    check = find(contains(dates,dates{i}));
    if numel(check) > 1
        load(fullfile(cDir,nm,[aList.block_name{check(2)} '_Block.mat']))
        chL = aList.ch_id{check(2)}';
        for ii = 1:size(chL,2)
            chID = chL(ii);
            sp = blockObj.getSpikeTimes(chID);
            succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
            for iv = 1:size(succE,2)
                ev = succE(iv).Ts; % events in seconds and converted to samples
                idxV = sp(sp>(ev-1) & sp<=(ev+1)); % index of spike times that fall in the window 1s on either side of grasp
                winV = idxV - ev; % zeroing beginning of trial
                ch{ii} = [ch{ii}; winV];
            end
            fprintf('Ch %d\n',chID)
        end
    end
    C{i} = ch;
    idxD = cellfun(@isempty,ch);
    d = cell(64,1);
    dd = cellfun(@(x) fitdist(x,'Kernel','Bandwidth',0.1),ch(~idxD),'UniformOutput',0);
    d(~idxD) = dd;
    if size(dd,1) < 64
        d = [d(49:64); d(1:48)];
    end
    for k = 1:size(d,1)
        distr = d{k};
        if isempty(distr)
            K{i} = [K{i}; nan(1,100)];
            continue
        end
        K{i} = [K{i}; cdf(distr,t)];
    end
end
idxC = cell2mat(aList.mod_99');
%% Test step 2
channel = struct;
for i = 1:64
    cdfAll = cellfun(@(x) x(i,:),K,'UniformOutput',false);
    channel(i).cdf = cdfAll;
    cdfR = [cdfAll; cdfAll; cdfAll; cdfAll; cdfAll];
    cdfC = [cdfAll', cdfAll', cdfAll', cdfAll', cdfAll'];
    cov = cellfun(@(x,y) x - y,cdfR,cdfC,'UniformOutput',false);
    channel(i).cov = cellfun(@(x) max(abs(x)),cov);
    channel(i).idx = idxC(i,2:end);
    channel(i).ks = channel(i).cov(2:end,1);
    channel(i).sig = channel(i).ks > 0.187; % corresponds to p = 0.05
%     channel(i).sig = channel(i).ks' > 0.24; % corresponds to p = 0.005
%     channel(i).combined = channel(i).ks' > 0.187 & channel(i).idx;
end
%% Make plots of the ks-test results
c_all = cell2mat({channel.combined}');
c_IH = sum(c_all(1:32,:),1);
c_UH = sum(c_all(33:64,:),1);
i_all = cell2mat({channel.idx}');
i_IH = sum(i_all(1:32,:),1);
i_UH = sum(i_all(33:64,:),1);
change_IH = c_IH./i_IH;
change_UH = c_UH./i_UH;
change = [change_IH; change_UH]';
figure;
plot(change);
ylim([0 1]);