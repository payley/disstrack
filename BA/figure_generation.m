%% Make plots for experimental data
%% Load tables
if ~(exist('listBA_injH','var'))
    load('aligned_succ_injH_list.mat')
    load('aligned_succ_uninjH_list.mat')
end
if ~(exist('listUA_injH','var'))
    load('unaligned_injH_list.mat')
    load('unaligned_uninjH_list.mat')
end
if ~(exist('listBl','var'))
    load('block_list.mat')
end
%% Select blocks to assess
% selects based on channel on array starting with the injured hemisphere
% (i.e. ch 1 is channel 1 on array in the injured hemipshere)
[an,~] = listdlg('PromptString','Select animal:','ListString',convertStringsToChars(listBA_injH.Properties.RowNames),'SelectionMode','single');
[bl,~] = listdlg('PromptString','Select block:','ListString',convertStringsToChars(listBA_injH.Properties.VariableNames),'SelectionMode','single');
[ch,~] = listdlg('PromptString','Select channel:','ListString',convertStringsToChars(string(1:64)));
[ty,~] = listdlg('PromptString','Select data type:','ListString',{'aligned','unaligned'},'SelectionMode','single');
%% plot data
if numel(ch) > 1
    if numel(ch) > 16
        error('Too many channels to assess at once :(');
    end
    figure;
    for i = 1:numel(ch)
        chId = ch(i);
        idxR = contains(listBl.animal_name,listUA_injH.Properties.RowNames(an));
        idxC = listBl.exp_time == bl - 1;
        idxB = idxR & idxC;
        if sum(idxB) > 1
            ff = find(idxB,1);
            idxB(:) = 0;
            idxB(ff) = 1;
        end
        nBins = size(listBl.ifr_vals{idxB},2);
        bin_sz = 2000/nBins; % bin size in ms
        sArr1 = size(listBA_injH{an,bl}{1},1);
        sArr2 = size(listBA_uninjH{an,bl}{1},1);
        switch ty
            case 1
                if ch <= sArr1
                    selBl = listBA_injH{an,bl}{1}(chId,:);
                else
                    selBl = listBA_uninjH{an,bl}{1}(chId-sArr1,:);
                end
            case 2
                if ch <= sArr1
                    idxS = listUA_injH{an,bl}{1}.channels == chId;
                    selBl = full(listUA_injH{an,bl}{1}.spikes(idxS,:));
                    selBl = sum(selBl,1)/size(selBl,1);
                else
                    idxS = listUA_uninjH{an,bl}{1}.channels == chId-sArr1;
                    selBl = full(listUA_uninjH{an,bl}{1}.spikes(idxS,:));
                    selBl = sum(selBl,1)/size(selBl,1);
                end
        end
        chdat = bin_data(selBl,bin_sz,30000);
        chdat_adj = (chdat*1000)/bin_sz;
        subplot(4,4,i)
        b = bar(0:nBins-1,chdat_adj,'histc');
        hold on
        b.EdgeColor = 'none';
        b.FaceColor = [0.3010 0.7450 0.9330];
        if listBl.mod_99{idxB}(chId) == 1
            set(gca,'TickDir','out','FontName','NewsGoth BT','LineWidth',1);
        else
            set(gca,'TickDir','out','FontName','NewsGoth BT');
            box off
        end
        xticks(0:25:100)
        xticklabels([-1 -0.5 0 0.5 1])
        xlabel('Time (s)');
        ylabel('MFR (Hz)');
        plot((listBl.sm_rates{idxB}(chId,:)*1000)/bin_sz,'Color',[0.1010 0.5450 0.7330],'LineWidth',2);
        mn = listBl.z_mean{idxB,1}(chId);
        std = listBl.z_stdev{idxB,1}(chId);
        mn = (mn*1000)/bin_sz;
        std = (std*1000)/bin_sz;
        yline(mn,'black');
        yline(mn+(std*3.09),'--');
        yline(mn-(std*3.09),'--');
        title(chId)
        hold off
    end
else
    idxR = contains(listBl.animal_name,listUA_injH.Properties.RowNames(an));
    idxC = listBl.exp_time == bl - 1;
    idxB = idxR & idxC;
    if sum(idxB) > 1
        ff = find(idxB,1);
        idxB(:) = 0;
        idxB(ff) = 1;
    end
    nBins = size(listBl.ifr_vals{idxB},2);
    bin_sz = 2000/nBins; % bin size in ms
    sArr1 = size(listBA_injH{an,bl}{1},1);
    sArr2 = size(listBA_uninjH{an,bl}{1},1);
    switch ty
        case 1
            if ch <= sArr1
                selBl = listBA_injH{an,bl}{1}(ch,:);
            else
                selBl = listBA_uninjH{an,bl}{1}(ch-sArr1,:);
            end
        case 2
            if ch <= sArr1
                idxS = listUA_injH{an,bl}{1}.channels == ch;
                selBl = full(listUA_injH{an,bl}{1}.spikes(idxS,:));
                selBl = sum(selBl,1)/size(selBl,1);
            else
                idxS = listUA_uninjH{an,bl}{1}.channels == ch-sArr1;
                selBl = full(listUA_uninjH{an,bl}{1}.spikes(idxS,:));
                selBl = sum(selBl,1)/size(selBl,1);
            end
    end
    chdat = bin_data(selBl,bin_sz,30000);
    chdat_adj = (chdat*1000)/bin_sz;
    figure;
    b = bar(0:nBins-1,chdat_adj,'histc');
    hold on
    b.EdgeColor = 'none';
    b.FaceColor = [0.3010 0.7450 0.9330];
    set(gca,'TickDir','out','FontName','NewsGoth BT');
    box off
    xticks(0:25:100)
    xticklabels([-1 -0.5 0 0.5 1])
    xlabel('Time (s)');
    ylabel('MFR (Hz)');
    mn = listBl.z_mean{idxB,1}(ch);
    std = listBl.z_stdev{idxB,1}(ch);
    mn = (mn*1000)/bin_sz;
    std = (std*1000)/bin_sz;
    yline(mn,'black');
    yline(mn+(std*3.09),'--');
    yline(mn-(std*3.09),'--');
    if ty == 1
        plot((0.5:1:99.5),(listBl.sm_rates{idxB}(ch,:)*1000/bin_sz),'Color',[0.1010 0.5450 0.7330],'LineWidth',2);
    end
end
%% Repeat for uninjured animals and select blocks
% selects based on channel on array starting with the injured hemisphere
% (i.e. ch 1 is channel 1 on array in the injured hemipshere)
uAn = unique(listBl_ctrl.animal_name);
[an,~] = listdlg('PromptString','Select animal:','ListString',convertStringsToChars(uAn),'SelectionMode','single');
iA = uAn(an);
idxA = contains(listBl_ctrl.animal_name,iA);
uBl = listBl_ctrl.exp_time(idxA);
[bl,~] = listdlg('PromptString','Select date:','ListString',num2str(uBl),'SelectionMode','single');
iB = uBl(bl);
idxB = listBl_ctrl.exp_time == iB;
[ch,~] = listdlg('PromptString','Select channel:','ListString',convertStringsToChars(string(1:64)));
[ty,~] = listdlg('PromptString','Select data type:','ListString',{'aligned','unaligned'},'SelectionMode','single');
%% And plot 
idxM = contains(listBl.animal_name,iA) & listBl.incl_control == iB;
if sum(idxM) > 1
    ff = find(idxM,1);
    idxM(:) = 0;
    idxM(ff) = 1;
end
if numel(ch) > 1
    figure;
    for i = 1:numel(ch)
        chId = ch(i);
        idxC = idxA & idxB;
        nBins = size(listBl_ctrl.injH_align{idxC},2);
        bin_sz = 20; % bin size in ms
        sArr1 = size(listBl_ctrl.injH_align{idxC},1);
        switch ty
            case 1
                if ch <= sArr1
                    selBl = listBl_ctrl.injH_align{idxC}(chId,:);
                else
                    selBl = listBl_ctrl.uninjH_align{idxC}(chId-sArr1,:);
                end
            case 2
                if ch <= sArr1
                    selBl = listBl_ctrl.injH_unalign{idxC}(chId,:);
                else
                    selBl = listBl_ctrl.uninjH_unalign{idxC}(chId-sArr1,:);
                end
        end
        chdat = bin_data(selBl,bin_sz,nBins/2);
        chdat_adj = (chdat*1000)/bin_sz;
        subplot(4,4,i)
        b = bar(0:99,chdat_adj,'histc');
        hold on
        b.EdgeColor = 'none';
        b.FaceColor = [0.3010 0.7450 0.9330];
        if listBl.mod_99{idxM}(chId) == 1
            set(gca,'TickDir','out','FontName','NewsGoth BT','LineWidth',1);
        else
            set(gca,'TickDir','out','FontName','NewsGoth BT');
            box off
        end
        xticks(0:25:100)
        xticklabels([-1 -0.5 0 0.5 1])
        xlabel('Time (s)');
        ylabel('MFR (Hz)');
        plot((listBl.sm_rates{idxM}(chId,:)*1000)/bin_sz,'Color',[0.1010 0.5450 0.7330],'LineWidth',2);
        mn = listBl.z_mean{idxM,1}(chId);
        std = listBl.z_stdev{idxM,1}(chId);
        mn = (mn*1000)/bin_sz;
        std = (std*1000)/bin_sz;
        yline(mn,'black');
        yline(mn+(std*3.09),'--');
        yline(mn-(std*3.09),'--');
        title(chId)
        hold off
    end
else
    idxC = idxA & idxB;
    nBins = size(listBl_ctrl.injH_align{idxC},2);
    bin_sz = 2000/nBins; % bin size in ms
    sArr1 = size(listBA_injH{an,bl}{1},1);
        switch ty
            case 1
                if ch <= sArr1
                    selBl = listBl_ctrl.injH_align{idxC}(ch,:);
                else
                    selBl = listBl_ctrl.uninjH_align{idxC}(ch-sArr1,:);
                end
            case 2
                if ch <= sArr1
                    selBl = listBl_ctrl.injH_unalign{idxC}(ch,:);
                else
                    selBl = listBl_ctrl.uninjH_unalign{idxC}(ch-sArr1,:);
                end
        end
    chdat = bin_data(selBl,bin_sz,nBins/2);
    chdat_adj = (chdat*1000)/bin_sz;
    figure;
    b = bar(0:nBins-1,chdat_adj,'histc');
    hold on
    b.EdgeColor = 'none';
    b.FaceColor = [0.3010 0.7450 0.9330];
    set(gca,'TickDir','out','FontName','NewsGoth BT');
    box off
    xticks(0:25:100)
    xticklabels([-1 -0.5 0 0.5 1])
    xlabel('Time (s)');
    ylabel('MFR (Hz)');
    mn = listBl.z_mean{idxM,1}(ch);
    std = listBl.z_stdev{idxM,1}(ch);
    mn = (mn*1000)/bin_sz;
    std = (std*1000)/bin_sz;
    yline(mn,'black');
    yline(mn+(std*3.09),'--');
    yline(mn-(std*3.09),'--');
    if ty == 1
        plot((0.5:1:99.5),(listBl.sm_rates{idxM}(ch,:)*1000/bin_sz),'Color',[0.1010 0.5450 0.7330],'LineWidth',2);
    end
end