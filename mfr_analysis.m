%% Set-up
currLoc = pwd;
nArr = {'rRFA','lRFA'}; % set array designations
level_list = dirr(currLoc); % directory at level
ndir = 0;
for i = 1:numel(level_list)
    if isfolder(level_list(i).name) % checks for folders in directory
        ndir = 1+ndir;
        block_list(ndir) = level_list(i); % folders are designated as blocks
    end
end
nBlocks = length(block_list);
%% Mean firing rate by block
for i = 1:nBlocks
    root = fullfile(currLoc, block_list(i).name,'Analysis');
    load(fullfile(currLoc,[block_list(i).name,'_Block.mat']))
    mfr_loc = fullfile(root,'MFR'); % define name/location of folder
    if exist(mfr_loc,'dir')==0
        mkdir(mfr_loc)
    end
    fs = blockObj.SampleRate;
    samples = blockObj.Samples;
    ss = 1:samples;
    per = samples/10; % dividing block into 10 periods
    ref = ss(1:per:end);
    refE = (fs * 60) - 1; % samples in 1 minute
    for ii = 1:2 % number of arrays
        arr{ii} = fullfile(root,nArr(ii));
        for iii = 1:32 % number of channels
            % load(fullfile(arr{ii},block_list(i).name,'_ptrain_Ch_',num2string(iii)))
% the below is adapted for the AA_analysis
            nArr2 = {'RFA','S1'};
            fill = ('%s_ptrain_Sorted_Ch_%02d_1.mat');
            fill2 = ('%s_Sorted_NOT_splitted');
            f = sprintf (fill,block_list(i).name,iii);
            ff = sprintf (fill2,block_list(i).name);
            load(fullfile(currLoc,block_list(i).name,ff,nArr2{ii},f))
            % load(fullfile(currLoc,block_list(i).name,ff,nArr{ii},f))
            mfr_main(iii,1) = mean(peak_train)*fs; % mean firing rate based on logical array
            for p = 1:10 % find mean of minute samples
                if i == 3 % used for assays with a time rollover block
                    break
                end
                s = peak_train(ref(p):(ref(p)+refE));
                mfr_sub(iii,p) = mean(s)*30000;
            end
            if exist ('mfr_sub','var')
                mfr_main(iii,2) = std(mfr_sub(iii,:));
            else
                mfr_main(iii,2) = 0;
            end
        end
        ch = table([1:32]','VariableNames',{'Channels'});
        mfr_main = array2table(mfr_main,'VariableNames',{'Mean','SD_proxy'}); % convert main array to table
        mfr_main = [ch,mfr_main];
        save([mfr_loc,'/','MFR_',nArr{ii}],'mfr_main'); % save table in Analysis
        d = ('%s_MFR_%s complete');
        done = sprintf (d,block_list(i).name,nArr{ii});
        disp(done)
        clearvars mfr_main mfr_sub
    end
end
clearvars -except block_list nBlocks nArr
%% Grouped mean firing rate by array
currLoc = pwd; % move current folder to animal container folder
group = fullfile(currLoc,'Group_Analysis');
if exist(group,'dir')==0
    mkdir(group)
end
for i = 1:2 % number of arrays
    mfr_all = table((1:32)','VariableNames',{'Channels'});
    for ii = 1:nBlocks % number of blocks
        root = fullfile(currLoc, block_list(ii).name,'Analysis');
        mfr_loc = fullfile(root,'MFR'); % define name/location of folder
        g = ('MFR_%s');
        gg = sprintf(g,nArr{i});
        load(fullfile(mfr_loc,gg))
        set1 = strcat('Mean_',block_list(ii).name);
        set2 = strcat('SD_proxy_',block_list(ii).name);
        mfr_main.Properties.VariableNames = {'Channels',set1,set2};
        mean = mfr_main(:,2);
        std = mfr_main(:,3);
        mfr_all = [mfr_all mean std]; % move block data to one table
        clearvars mfr_main
    end
    save([group,'/','MFR_',nArr{i}],'mfr_all','nBlocks'); % save table by array
    clearvars mfr_all
end
clear 
%% More plots based on increased/decreased mfr
currLoc = pwd; % move current folder to group_analysis folder
nArr = {'rRFA','lRFA'};
for i = 1:numel(nArr)
    load([currLoc,'/','MFR_',nArr{i}])
    MFR_array{i} = mfr_all;
    means = contains(mfr_all.Properties.VariableNames,'Mean');
    err = contains(mfr_all.Properties.VariableNames,'SD');
    mfr_all = table2array(mfr_all);
    for ii = 1:32
        figure;
        fig = errorbar((1:nBlocks),mfr_all(ii,means),mfr_all(ii,err));
    end
end
