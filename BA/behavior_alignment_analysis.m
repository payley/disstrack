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
%% Fill tables
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
                    hold = zeros(1,fs*2); % assigning ones to the spike sample number
                    hold(1,winV) = 1;
                    if size(hold,2) ~= 60000
                        check;
                    end
                    % CHECK THAT INDEXING IS CORRECT!!
                    hh = [hh; hold];
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
                    hold = zeros(1,fs*2); % assigning ones to the spike sample number
                    hold(1,winV) = 1;
                    hh = [hh; hold];
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
                        hold = zeros(1,fs*2); % assigning ones to the spike sample number
                        hold(1,winV) = 1;
                        hh = [hh; hold];
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
%% Turn into pseudo-histograms
% bin_size = 100; % in ms
% nBins = 60000/(bin_size*30);
% bin_edges = [0 linspace((bin_size*30),60000,nBins)];
% nM = zeros(1,nBins);
% for i = 1:nBins
%     deb = bin_edges(i) + 1;
%     fin = bin_edges(i+1);
%     nM(i) = sum(m(deb:fin));
% end