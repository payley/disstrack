%% Analysis of behaviorally aligned data
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
listBA_injH = table(preInj,postInj1,postInj2,postInj3,postInj4); % create table to store mfr data for each channel
listBA_uninjH = table(preInj,postInj1,postInj2,postInj3,postInj4); % create table to store mfr data for each channel
listBA_injH.Properties.RowNames = unique(uniq.animal_name);
listBA_uninjH.Properties.RowNames = unique(uniq.animal_name);
%% Fill table for injured animals
for i = 1:nUniq % iterate through every animal/date combination
    refN = idxU(i); % id corresponding index for table
    check = listBlI(refN,[1,4]);
    c = ismember(listBlI(:,[1,4]),check,"rows"); % find any days with multiple blocks
    if sum(c) == 1
        load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat'])); % load file
        fOrd = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
        nCh = [blockObj.Channels.port_number]';
        succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
        fs = blockObj.SampleRate; % block length, should be in sec
        hArr = cell(2,1);
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
            hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
            for iii = 1:sCh
                chID = chan(iii);
                sp = blockObj.getSpikeTrain(chID); % spike times in samples
                hh = [];
                for iv = 1:size(succE,2)
                    ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                    idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window 1s on either side of grasp
                    winV = idxV - (ev-fs); % zeroing beginning of trial
                    hld = zeros(1,fs*2); % assigning ones to the spike sample number
                    hld(1,winV) = 1;
                    % CHECK THAT INDEXING IS CORRECT!!
                    hh = [hh; hld];
                end
                hBA(iii,:) = sum(hh,1)/size(succE,2); % summed spikes for each bin across all the trials
                % NORMALIZATION TO NUMBER OF TRIALS IN THE ABOVE
                % APPROPRIATE??
            end
            hArr{ii} = hBA;
        end
            idxR = find(contains(listBA_injH.Properties.RowNames,listBlI.animal_name{refN})); % row number based on animal name
            idxC = listBlI.exp_time(refN) + 1; % column number based on timepoint
            listBA_injH{idxR,idxC} = hArr(1);
            listBA_uninjH{idxR,idxC} = hArr(2);
    else % takes into account multiple blocks for a session
        nbl = sum(c); 
        hArr = cell(2,1);
        mBl{1} = load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat']));
        fOrd = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
        fs = mBl{1}.blockObj.SampleRate; % block length, should be in sec
        nCh = [mBl{1}.blockObj.Channels.port_number]';
        succE = mBl{1}.blockObj.Events(contains([mBl{1}.blockObj.Events.Name],'GraspStarted'));
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
            hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
            for iii = 1:sCh
                chID = chan(iii);
                sp = mBl{1}.blockObj.getSpikeTrain(chID); % spike times in samples
                hh = [];                
                for iv = 1:size(succE,2)
                    ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                    idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window
                    winV = idxV - (ev-fs); % zeroing beginning of trial
                    hld = zeros(1,fs*2); % assigning ones to the spike sample number
                    hld(1,winV) = 1;
                    hh = [hh; hld];
                end
                hBA(iii,:) = sum(hh,1)/size(hh,1); % summed spikes for each bin across all the trials
            end
            hArr{ii} = hBA;
        end
        for cc = 2:nbl
            f = find(c);
            iC = f(cc);
            mBl{cc} = load(fullfile(cDir,listBlI.animal_name{iC},[listBlI.block_name{iC} '_Block.mat']));
            fOrd = contains(listBlI.array_order{iC}{1},listBlI.reach{iC});
            nCh = [mBl{cc}.blockObj.Channels.port_number]';
            succE = mBl{cc}.blockObj.Events(contains([mBl{cc}.blockObj.Events.Name],'GraspStarted'));
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
                hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
                for iii = 1:sCh
                    chID = chan(iii);
                    sp = mBl{cc}.blockObj.getSpikeTrain(chID); % spike times in samples
                    hh = [];
                    for iv = 1:size(succE,2)
                        ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                        idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window
                        winV = idxV - (ev-fs); % zeroing beginning of trial
                        hld = zeros(1,fs*2); % assigning ones to the spike sample number
                        hld(1,winV) = 1;
                        hh = [hh; hld];
                    end
                    hBA(iii,:) = sum(hh,1)/size(hh,1); % summed spikes for each bin across all the trials
                end
                hArr{ii} = hArr{ii} + hBA; % add other summed blocks to prevous 
            end
        end
        idxR = find(contains(listBA_injH.Properties.RowNames,listBlI.animal_name{refN})); % row number based on animal name
        idxC = listBlI.exp_time(refN) + 1; % column number based on timepoint
        listBA_injH{idxR,idxC} = hArr(1);
        listBA_uninjH{idxR,idxC} = hArr(2);
    end
clearvars -except listBl listBlI listBA_injH listBA_uninjH nUniq idxU tankObj cDir
end
%% Bin data for all injured animals and plot with only modulated channels
% reduce to only channels considered modulated
nlistBA_injH = listBA_injH;
nlistBA_uninjH = listBA_uninjH;
for i = 1:9
    for ii = 1:5 % loop for each column
        idxR = contains(listBl.animal_name,listBA_injH.Properties.RowNames(i));
        idxC = listBl.exp_time == ii - 1;
        idxB = idxR & idxC;
        if sum(idxB) > 1
            idx1 = find(idxB,1);
            idxB(:) = 0;
            idxB(idx1) = 1;
        end
        if isempty(listBA_injH{i,ii}{1})
            continue
        else
            hh = listBl.ifr_vals{idxB};
            ref = listBl.mod_95{idxB}; 
            ref1 = ref; 
            ref2 = ref; 
            s1 = size(listBA_injH{i,ii}{1},1);
            s2 = s1 + size(listBA_uninjH{i,ii}{1},1);
            ref1(s1+1:s2) = 0;
            ref2(1:s1) = 0;
            nlistBA_injH(i,ii) = {hh(logical(ref1),:)};
            nlistBA_uninjH(i,ii) = {hh(logical(ref2),:)};
        end
    end
end

% average by timepoint
avg_act = cell(2,5);

% for injured hemisphere
for i = 1:5 % repeats for each timepoint
    allch = cell2mat(nlistBA_injH{:,i});
    m = sum(allch,1)./size(allch,1); % divides by number of channels, APPROPRIATE NORMALIZATION STEP???
    avg_act{1,i} = m;
end

% for uninjured hemisphere
for i = 1:5 % repeats for each timepoint
    allch = cell2mat(nlistBA_uninjH{:,i});
    m = sum(allch,1)./size(allch,1); % divides by number of channels, APPROPRIATE NORMALIZATION STEP???
    avg_act{2,i} = m;
end

hemi = {'Ipsilesional','Contralesional'};
dates = {'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'};
for i = 1:2
    figure('Position', [0 0 1900 250]);
    for ii = 1:5
        subplot(1,5,ii);
        patch([0 0 99 99],[2.57 0 0 2.57],[0.9 0.9 0.9],'EdgeColor','none');
        hold on
        plot(0:99,avg_act{i,ii});
        g = gca;
        set(g,'TickDir','out','FontName', 'NewsGoth BT');
        box off
        ylabel('Z-Score');
        xlabel('Time (s)');
        xlim([0 99]);
        xticks(linspace(0,99,5));
        xticklabels(linspace(-1,1,5));
        ylim([0 9]);
        yticks(0:3:9);
%         gy = ceil(g.YLim(2));
%         g.YLim = ([0 gy]);
        title(dates{ii});
    end
    sgtitle(hemi{i});
end
%% Bin data for each injured animal and plot with only modulated channels
% uses tables from code above
sz_injH = cell2mat(cellfun(@(x) size(x,1),table2array(nlistBA_injH),'UniformOutput',false));
sz_uninjH = cell2mat(cellfun(@(x) size(x,1),table2array(nlistBA_uninjH),'UniformOutput',false));
an_act_injH = cellfun(@mean,table2array(nlistBA_injH),'UniformOutput',false);
an_act_uninjH = cellfun(@mean,table2array(nlistBA_uninjH),'UniformOutput',false);

figure;
c = 0;
hemi = {'Ipsilesional','Contralesional'};
dates = {'Baseline','Post-Lesion 1','Post-Lesion 2','Post-Lesion 3','Post-Lesion 4'};
for i = 1:2
    if i == 1
        T = an_act_injH;
        c = 1:2:9;
    else
        T = an_act_uninjH;
        c = 2:2:10;
    end
    for ii = 1:5
        idxC = c(ii);
        subplot(5,2,idxC);
        hold on
        for iii = 1:size(T,1)
            plot(T{iii,ii});
        end
        set(gca,'TickDir','out','FontName', 'NewsGoth BT');
        box off
        ylabel('Z-Score');
        xlabel('Time (s)');
        xlim([1 100]);
        xticks(linspace(0,100,5));
        xticklabels(linspace(-1,1,5));
        title(dates{ii})
    end
end
sgtitle('Ipsilesional Contralesional');

% plot exemplar animal as well
figure;
for i = 1:2
    if i == 1
        T = an_act_injH;
        c = 1:2:9;
    else
        T = an_act_uninjH;
        c = 2:2:10;
    end
    for ii = 1:5
        idxC = c(ii);
        subplot(5,2,idxC);
        hold on
        for iii = 1:size(T,1)
            plot(T{7,ii});
        end
        set(gca,'TickDir','out','FontName', 'NewsGoth BT');
        box off
        ylabel('Z-Score');
        xlabel('Time (s)');
        xlim([1 100]);
        xticks(linspace(0,100,5));
        xticklabels(linspace(-1,1,5));
        title(dates{ii})
    end
end

%% Fill table for uninjured animals
if ~exist('listBl','var')
    load('C:\MyRepos\disstrack\BA\block_list.mat')
end
cDir = 'P:\Extracted_Data_To_Move\Rat\Intan\phProject\phProject';
listBlI = listBl(~isnan(listBl.incl_control),:); % new table with only injured animals
[~,idxU] = unique(listBlI(:,[1 7])); % find unique blocks for each experimental timepoint
nUniq = numel(idxU);
animal_name = cell(nUniq,1);
exp_time = zeros(nUniq,1);
injH_align = cell(nUniq,1);
uninjH_align = cell(nUniq,1);
listBl_ctrl = table(animal_name,exp_time,injH_align,uninjH_align);
for i = 1:nUniq % iterate through every animal/date combination
    refN = idxU(i); % id corresponding index for table
    check = listBlI(refN,[1 7]);
    c = ismember(listBlI(:,[1,7]),check,"rows"); % find any days with multiple blocks
    if sum(c) == 1
        load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat'])); % load file
        fOrd = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
        nCh = [blockObj.Channels.port_number]';
        if size(unique(nCh),1) == 1 && numel(nCh) == 64 % addresses blocks where both headstages were plugged into the same port
            nCh = [repmat(1,32,1); repmat(2,32,1)];
        end
        if sum(nCh > 2) > 0 % addresses blocks where port assignment was different
            nCh(nCh == 3) = 1;
            nCh(nCh == 4) = 2;
        end
        if isempty(blockObj.Events) % addresses any blocks where there was no behavior
            listBl_ctrl.animal_name(i) = listBlI.animal_name(refN);
            listBl_ctrl.exp_time(i) = listBlI.incl_control(refN);
            continue
        end
        succE = blockObj.Events(contains([blockObj.Events.Name],'GraspStarted'));
        if size(succE,2) == 0 % addresses any blocks where there was no behavior
            listBl_ctrl.animal_name(i) = listBlI.animal_name(refN);
            listBl_ctrl.exp_time(i) = listBlI.incl_control(refN);
            continue
        end
        fs = blockObj.SampleRate; % block length, should be in sec
        hArr = cell(2,1);
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
            hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
            for iii = 1:sCh
                chID = chan(iii);
                sp = blockObj.getSpikeTrain(chID); % spike times in samples
                hh = [];
                for iv = 1:size(succE,2)
                    ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                    idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window 1s on either side of grasp
                    winV = idxV - (ev-fs); % zeroing beginning of trial
                    hld = zeros(1,fs*2); % assigning ones to the spike sample number
                    hld(1,winV) = 1;
                    % CHECK THAT INDEXING IS CORRECT!!
                    hh = [hh; hld];
                end
                hBA(iii,:) = sum(hh,1)/size(succE,2); % summed spikes for each bin across all the trials
                % NORMALIZATION TO NUMBER OF TRIALS IN THE ABOVE
                % APPROPRIATE??
            end
            hArr{ii} = hBA;
        end
            listBl_ctrl.injH_align(i) = hArr(1);
            listBl_ctrl.uninjH_align(i) = hArr(2);
            listBl_ctrl.animal_name(i) = listBlI.animal_name(refN);
            listBl_ctrl.exp_time(i) = listBlI.incl_control(refN);
    else % takes into account multiple blocks for a session
        nbl = sum(c); 
        hArr = cell(2,1);
        mBl{1} = load(fullfile(cDir,listBlI.animal_name{refN},[listBlI.block_name{refN} '_Block.mat']));
        fOrd = contains(listBlI.array_order{refN}{1},listBlI.reach{refN});
        fs = mBl{1}.blockObj.SampleRate; % block length, should be in sec
        nCh = [mBl{1}.blockObj.Channels.port_number]';
        if size(unique(nCh),1) == 1 && numel(nCh) == 64
            nCh = [repmat(1,32,1); repmat(2,32,1)];
        end
        succE = mBl{1}.blockObj.Events(contains([mBl{1}.blockObj.Events.Name],'GraspStarted'));
        for ii = 1:2 % repeats for each array
            if size(succE,2) == 0
                continue;
            end
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
            hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
            for iii = 1:sCh
                chID = chan(iii);
                sp = mBl{1}.blockObj.getSpikeTrain(chID); % spike times in samples
                hh = [];                
                for iv = 1:size(succE,2)
                    ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                    idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window
                    winV = idxV - (ev-fs); % zeroing beginning of trial
                    hld = zeros(1,fs*2); % assigning ones to the spike sample number
                    hld(1,winV) = 1;
                    hh = [hh; hld];
                end
                hBA(iii,:) = sum(hh,1)/size(hh,1); % summed spikes for each bin across all the trials
            end
            hArr{ii} = hBA;
        end
        for cc = 2:nbl
            f = find(c);
            iC = f(cc);
            mBl{cc} = load(fullfile(cDir,listBlI.animal_name{iC},[listBlI.block_name{iC} '_Block.mat']));
            fOrd = contains(listBlI.array_order{iC}{1},listBlI.reach{iC});
            nCh = [mBl{cc}.blockObj.Channels.port_number]';
            if size(unique(nCh),1) == 1 && numel(nCh) == 64
                nCh = [repmat(1,32,1); repmat(2,32,1)];
            end
            if isempty(mBl{cc}.blockObj.Events) % fix R21-09 7/11 and remove later!!!!!!
                continue
            end
            succE = mBl{cc}.blockObj.Events(contains([mBl{cc}.blockObj.Events.Name],'GraspStarted'));
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
                hBA = zeros(sCh,fs*2); % 1 sec window on either side of grasp
                for iii = 1:sCh
                    chID = chan(iii);
                    sp = mBl{cc}.blockObj.getSpikeTrain(chID); % spike times in samples
                    hh = [];
                    for iv = 1:size(succE,2)
                        ev = round(succE(iv).Ts*fs); % events in seconds and converted to samples
                        idxV = sp(sp>(ev-fs) & sp<=(ev+fs)); % index of spike times that fall in the window
                        winV = idxV - (ev-fs); % zeroing beginning of trial
                        hld = zeros(1,fs*2); % assigning ones to the spike sample number
                        hld(1,winV) = 1;
                        hh = [hh; hld];
                    end
                    hBA(iii,:) = sum(hh,1)/size(hh,1); % summed spikes for each bin across all the trials
                end
                hArr{ii} = hArr{ii} + hBA; % add other summed blocks to previous
            end
        end
        if isempty(mBl{cc}.blockObj.Events) % fix R21-09 7/11 and remove later!!!!!!
            listBl_ctrl.animal_name(i) = listBlI.animal_name(refN);
            listBl_ctrl.exp_time(i) = listBlI.incl_control(refN);
            continue
        end
        listBl_ctrl.injH_align(i) = hArr(1);
        listBl_ctrl.uninjH_align(i) = hArr(2);
        listBl_ctrl.animal_name(i) = listBlI.animal_name(iC);
        listBl_ctrl.exp_time(i) = listBlI.incl_control(iC);
    end
clearvars -except listBl listBlI listBl_ctrl idxU nUniq cDir
end
%% Bin data for all control/uninjured timepoints with only modulated channels
% reduce to only channels considered modulated
wk = round(listBl.incl_control./7).*7;
wk(wk > 49) = nan;
D = cell(7,2);
for i = 1:7
    idxR = sum(contains({'R22-28','R22-29'},listBl.animal_name{i})) == 0;
    idxW = wk == (7*i);
    idxB = idxR & idxW;
    idxE = zeros(size(idxB,1),1);
    [~,ee] = unique(listBl(:,[1,7])); % removes multiple blocks for one recording day
    idxE(ee) = 1; 
    idxB(~idxE) = 0;
    idxF = find(idxB);
    ipsiD = cell(sum(idxB),1);
    contraD = cell(sum(idxB),1);
    for ii = 1:sum(idxB)
        idxH = idxF(ii);
        idxU = contains(listBl_ctrl.animal_name,listBl.animal_name{idxH}) & listBl_ctrl.exp_time == listBl.incl_control(idxH);
        nIpsi = size(listBl_ctrl.injH_align{idxU},1);
        nContra = size(listBl_ctrl.uninjH_align{idxU},1);
        if isempty(listBl.z_mean(idxH))
            continue
        else
            hh = listBl.ifr_vals{idxH};
            ref = logical(listBl.mod_95{idxH});
            mid = nIpsi+1;
            onlyMod_ipsi = logical([ref(1:nIpsi); zeros(nContra,1)]);
            onlyMod_contra = logical([zeros(nIpsi,1); ref(mid:nIpsi+nContra)]);
            ipsiD{ii} = hh(onlyMod_ipsi,:);
            contraD{ii} = hh(onlyMod_contra,:);
        end
    end
    D{i,1} = ipsiD;
    D{i,2} = contraD;
    D{i,3} = idxF;
end

hemi = {'Contralateral Hemisphere','Ipsilateral Hemisphere'};
for i = 1:2
    figure;
    hold on
    for ii = 1:3
        plot(0:99,mean(cell2mat(D{ii,i})),'LineWidth',1.5)
    end
    g = gca;
    set(g,'TickDir','out','FontName', 'NewsGoth BT');
    box off
    ylabel('Z-Score');
    xlabel('Time (s)');
    xlim([0 99]);
    xticks(linspace(0,99,5));
    xticklabels(linspace(-1,1,5));
    title(hemi{i});
    ylim([-0.5 5])
    legend({'Week 1','Week 2','Week 3'},'Location','northeast');
    legend('boxoff');
end

% grContra = cellfun(@cell2mat,D(:,1),'UniformOutput',false);
% grIpsi = cellfun(@cell2mat,D(:,2),'UniformOutput',false);
% grContra = cell2mat(grContra);
% grIpsi = cell2mat(grIpsi);
% avContra = mean(grContra);
% avIpsi = mean(grIpsi);

clearvars -except listBl listBl_ctrl D
%% Bin data for all control/uninjured timepoints with only modulated channels
% reduce to only channels considered modulated
an = 'R22-02';
idxL = contains(listBl.animal_name,an) & ~isnan(listBl.incl_control);
idxE = zeros(size(idxL,1),1);
[~,ee] = unique(listBl(:,[1,7])); % removes multiple blocks for one recording day
idxE(ee) = 1;
idxL(~idxE) = 0;
idxF = find(idxL);
ipsiD = cell(sum(idxL),1);
contraD = cell(sum(idxL),1);
for ii = 1:sum(idxL)
    idxH = idxF(ii);
    idxU = contains(listBl_ctrl.animal_name,listBl.animal_name{idxH}) & listBl_ctrl.exp_time == listBl.incl_control(idxH);
    nIpsi = size(listBl_ctrl.injH_align{idxU},1);
    nContra = size(listBl_ctrl.uninjH_align{idxU},1);
    if isempty(listBl.z_mean(idxH))
        continue
    else
        hh = listBl.ifr_vals{idxH};
        ref = logical(listBl.mod_95{idxH});
        mid = nIpsi+1;
        onlyMod_ipsi = logical([ref(1:nIpsi); zeros(nContra,1)]);
        onlyMod_contra = logical([zeros(nIpsi,1); ref(mid:nIpsi+nContra)]);
        ipsiD{ii} = hh(onlyMod_ipsi,:);
        contraD{ii} = hh(onlyMod_contra,:);
    end
end

D = [ipsiD contraD];
hemi = {'Contralateral Hemisphere','Ipsilateral Hemisphere'};
for i = 1:2
    figure;
    hold on
    for ii = 1:size(D,1)
        plot(0:99,mean(D{ii,i}),'LineWidth',1.5)
    end
    g = gca;
    set(g,'TickDir','out','FontName', 'NewsGoth BT');
    box off
    ylabel('Z-Score');
    xlabel('Time (s)');
    xlim([0 99]);
    xticks(linspace(0,99,5));
    xticklabels(linspace(-1,1,5));
    title(hemi{i});
end
%% Plots on channel stability
an = 'R22-02';
ch = 52;
figure;
hold on
idxA = contains(listBl.animal_name,an);
idxE = cellfun(@isempty,listBl.z_mean);
idxA = idxA & ~isnan(listBl.incl_control) & ~idxE;
dates = listBl.incl_control(idxA);
ff = find(idxA);
patch([0 0 99 99],[2.57 -2.57 -2.57 2.57],[0.9 0.9 0.9],'EdgeColor','none');
for i = 1:numel(ff)
plot(0:99,listBl.ifr_vals{ff(i),1}(ch,:),'LineWidth',1.5);
end
set(gca,'TickDir','out','FontName', 'NewsGoth BT');
box off
ylabel('Z-Score');
xlabel('Time (s)');
xlim([0 99]);
xticks(linspace(0,99,5));
xticklabels(linspace(-1,1,5));
title(sprintf('%s Channel %d',an,ch));