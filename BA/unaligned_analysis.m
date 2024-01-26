%% Analysis of data unaligned to behavior
%% Find and pull blocks for injured animals only
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
idxT = ~isnan(listBl.exp_time);
listBlI = listBl(idxT,:); % new table with only injured animals
[uniq,idxU] = unique(listBlI(:,[1,4])); % find unique blocks for each experimental timepoint
nUniq = numel(idxU);
nAn = numel(unique(uniq.animal_name));
preInj = cell(nAn,1);
postInj1 = cell(nAn,1);
postInj2 = cell(nAn,1);
postInj3 = cell(nAn,1);
postInj4 = cell(nAn,1);
listUA_injH = table(preInj,postInj1,postInj2,postInj3,postInj4); % create table to store mfr data for each channel
listUA_uninjH = table(preInj,postInj1,postInj2,postInj3,postInj4); % create table to store mfr data for each channel
listUA_injH.Properties.RowNames = unique(uniq.animal_name);
listUA_uninjH.Properties.RowNames = unique(uniq.animal_name);
%% Fill tables
for i = 1:nUniq % iterate through every animal/date combination
    refN = idxU(i); % id corresponding index for table
    check = listBlI(refN,[1,4]);
    c = ismember(listBlI(:,[1,4]),check,"rows"); % find any days with multiple blocks
    if sum(c) == 1
        load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat'])); % load file
        fOrd = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
        nCh = [blockObj.Channels.port_number]';
        fs = blockObj.SampleRate; % block length, should be in sec
        succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
        randE = blockObj.Events(contains([blockObj.Events.Name],'Contact'));
        hArr = cell(2,1);
        if size(randE,2) >= (size(succE,2)*3)
            fprintf('%2d reaches\n',size(succE,2));
            fprintf('%2d unaligned points\n',size(randE,2));
        elseif size(randE,2) >= size(succE,2) && size(randE,2) < (size(succE,2)*3) 
            for a = 1:size(randE,2)
                add1 = randE(a);
                add2 = randE(a);
                add1.Ts = add1.Ts + 1;
                add2.Ts = add2.Ts + 2;
                blockObj.addEvent(add1);
                blockObj.addEvent(add2);
            end
            blockObj.save
            randE = blockObj.Events(contains([blockObj.Events.Name],'Contact'));
            fprintf('%2d reaches\n',size(succE,2));
            fprintf('%2d unaligned points\n',size(randE,2));
        elseif size(randE,2) < size(succE,2)
            error('Need to place more contact points!')
        end
        for ii = 1:2 % repeats for each array
            if fOrd == 1 % switches based on the array opposite the reaching limb (i.e. injured hemisphere first)
                flip = [2,1];
                chan = find(nCh == (flip(ii)));
                sCh = size(chan,1);
                fprintf('%s_%s Array %d\n',listBlI.animal_name{refN},listBlI.block_name{refN},flip(ii));
            else
                chan = find(nCh == ii);
                sCh = size(chan,1);
                fprintf('%s_%s Array %d\n',listBlI.animal_name{refN},listBlI.block_name{refN},ii);
            end
            hh = [];
            nn = [];
            for iii = 1:sCh
                chID = chan(iii);
                sp = blockObj.getSpikeTrain(chID); % spike times in samples
                for iv = 1:size(randE,2)
                    ev = round(randE(iv).Ts*fs); % events in seconds and converted to samples
                    idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window 1s on either side of grasp
                    winV = idxV - (ev-fs); % zeroing beginning of trial
                    hld = zeros(1,fs*2); % assigning ones to the spike sample number
                    hld(1,winV) = 1;
                    hld = sparse(hld);
                    if size(hld,2) ~= 60000
                        check;
                    end
                    hh = [hh; hld];
                    nn = [nn; iii];
                end
            end
            hArr{ii} = table(nn,hh,'VariableNames',{'channels','spikes'});
        end
        idxR = find(contains(listUA_injH.Properties.RowNames,listBlI.animal_name{refN})); % row number based on animal name
        idxC = listBlI.exp_time(refN) + 1; % column number based on timepoint
        listUA_injH{idxR,idxC} = hArr(1);
        listUA_uninjH{idxR,idxC} = hArr(2);
    else % takes into account multiple blocks for a session
        nbl = sum(c);
        hArr = cell(2,1);
        mBl = cell(nbl,1);
        hh = cell(2,1);
        nn = cell(2,1);
        for cc = 1:nbl % for each additional block
            f = find(c);
            iC = f(cc);
            mBl{cc} = load(fullfile(cDir,listBlI.animal_name{iC},[listBlI.block_name{iC} '_Block.mat']));
            fOrd = contains(listBlI.array_order{iC}{1},listBlI.reach{iC});
            nCh = [mBl{cc}.blockObj.Channels.port_number]';
            fs = mBl{cc}.blockObj.SampleRate; % block length, should be in sec
            succE = mBl{cc}.blockObj.Events(contains([mBl{cc}.blockObj.Events.Name],'GraspStarted'));
            randE = mBl{cc}.blockObj.Events(contains([mBl{cc}.blockObj.Events.Name],'Contact'));
            if size(randE,2) >= (size(succE,2)*3) % checks for 3x unaligned events
                fprintf('%2d reaches\n',size(succE,2));
                fprintf('%2d unaligned points\n',size(randE,2));
            elseif size(randE,2) >= size(succE,2) && size(randE,2) < (size(succE,2)*3)
                for a = 1:size(randE,2)
                    add1 = randE(a);
                    add2 = randE(a);
                    add1.Ts = add1.Ts + 1;
                    add2.Ts = add2.Ts + 2;
                    mBl{cc}.blockObj.addEvent(add1);
                    mBl{cc}.blockObj.addEvent(add2);
                end
                mBl{cc}.blockObj.save
                randE = mBl{cc}.blockObj.Events(contains([mBl{cc}.blockObj.Events.Name],'Contact'));
                fprintf('%2d reaches\n',size(succE,2));
                fprintf('%2d unaligned points\n',size(randE,2));
            elseif size(randE,2) < size(succE,2)
                error('Need to place more contact points!')
            end
            for ii = 1:2 % repeats for each array
                if fOrd == 1 % switches based on the array opposite the reaching limb (i.e. injured hemisphere first)
                    flip = [2,1];
                    chan = find(nCh == (flip(ii)));
                    sCh = size(chan,1);
                    fprintf('%s_%s Array %d\n',listBlI.animal_name{iC},listBlI.block_name{iC},flip(ii));
                else
                    chan = find(nCh == ii);
                    sCh = size(chan,1);
                    fprintf('%s_%s Array %d\n',listBlI.animal_name{iC},listBlI.block_name{iC},ii);
                end
                for iii = 1:sCh % repeats for each 
                    chID = chan(iii);
                    sp = mBl{cc}.blockObj.getSpikeTrain(chID); % spike times in samples
                    for iv = 1:size(randE,2)
                        ev = round(randE(iv).Ts*fs); % events in seconds and converted to samples
                        idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window
                        winV = idxV - (ev-fs); % zeroing beginning of trial
                        hld = zeros(1,fs*2); % assigning ones to the spike sample number
                        hld(1,winV) = 1;
                        hld = sparse(hld);
                        hh{ii} = [hh{ii}; hld];
                        nn{ii} = [nn{ii}; iii];
                    end
                end
            end
        end
        hArr{1} = table(nn{1},hh{1},'VariableNames',{'channels','spikes'});
        hArr{2} = table(nn{2},hh{2},'VariableNames',{'channels','spikes'});
        idxR = find(contains(listUA_injH.Properties.RowNames,listBlI.animal_name{refN})); % row number based on animal name
        idxC = listBlI.exp_time(refN) + 1; % column number based on timepoint
        listUA_injH{idxR,idxC} = hArr(1);
        listUA_uninjH{idxR,idxC} = hArr(2);
    end
end
clearvars -except listBl listBA_injH listBA_uninjH listUA_injH listUA_uninjH 
%% Make normalized distributions for every bin around unaligned points 
lvl = 'bin'; % case for running z-distributions at the trial level (i.e. for all trials at each bin) or at the bin level (i.e. for all bins)
bin_sz = 20;

load('aligned_succ_injH_list.mat')
load('aligned_succ_uninjH_list.mat')
if ~(exist('listUA_injH','var'))
    load('unaligned_injH_list.mat')
    load('unaligned_uninjH_list.mat')
end
uArrs = {listUA_injH,listUA_uninjH};
aArrs = {listBA_injH,listBA_uninjH};
if ~(exist('listBl','var'))
    load('block_list.mat')
    cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
end
nBl = size(listBl,1);
z_mean = cell(nBl,1);
z_stdev = cell(nBl,1);
for i = 1:9 % loop for each row
    for ii = 1:5 % loop for each column
        idxR = contains(listBl.animal_name,uArrs{1}.Properties.RowNames(i));
        idxC = listBl.exp_time == ii - 1;
        idxB = idxR & idxC;
        if idxB == 0 % skips empty blocks
            continue
        end
        % make z-score distributions
        totCh = size(aArrs{1}{i,ii}{1},1) + size(aArrs{2}{i,ii}{1},1);
        switch lvl 
            case 'trial'
                z_m = zeros(totCh,100);
                z_s = zeros(totCh,100);
            case 'bin'
                z_m = zeros(totCh,1);
                z_s = zeros(totCh,1);
        end
        ch = 0;
        for iii = 1:2 % loop for both arrays
            blVal = uArrs{iii}{i,ii}{1}; % ordered injured hemisphere first and NOT native array order
            chan = unique(blVal.channels);
            for iv = 1:numel(chan)
                ch = ch + 1;
                chVal = blVal.spikes(blVal.channels == chan(iv),:);
                chVal = full(chVal);
                binSp = bin_data(chVal,bin_sz,30000); 
                switch lvl
                    case 'trial'
                        [~,zm,zs] = zscore(binSp,[],1);
                    case 'bin'
                        binSp = sum(binSp,1)/size(binSp,1); % sum and divide by trials
                        [~,zm,zs] = zscore(binSp,[],2);
                end
                z_m(ch,:) = zm;
                z_s(ch,:) = zs;
            end
        end
        z_mean(idxB) = {z_m};
        z_stdev(idxB) = {z_s};
        fprintf('%s Exp Timepoint %d\n',uArrs{1}.Properties.RowNames{i},ii-1);
    end
end
clearvars -except listBl listBA_injH listBA_uninjH listUA_injH listUA_uninjH z_mean z_stdev
%% Run for control/baseline recordings
