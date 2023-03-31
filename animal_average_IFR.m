%% make a table of channels and spikes
% create B: a cell array of blocks for analysis
clearvars -except B
tWin = 0.5; % in seconds atm
conv = 1e3; % converting samples to ms
evID = {'Name','GraspStarted'}; % find in blockObj.Events
level = [0]; % indicates flipped blocks where left is contralateral to reach
grPlot = {'lRFA','rRFA'}; % default is that left is ipsilateral to reach
orPlot = {'ipsiRFA','contraRFA'};
nAr = [0]; 
nCh = 64;
nBl = numel(B);
bl = cell(nBl,2); % store spike data for average block activity by area
for i = 1:nBl
    E = B{i}.Events;
    ChArea = {B{i}.Channels.area};
    field = evID{1};
    val = evID{2};
    idx = strcmp([E.(field)],val); % must be a cell
    evt = E(idx); % returns reduced Events structure based on evID 
    nEvt = numel(evt);
    idxAr = strcmp(ChArea,grPlot{1}); % compare assigned areas with the group plot assignment
    if level(i) == 0 % flip orientation so that contralateral RFAs are averaged/plotted together
        nAr = find(idxAr,1,'last');
    else
        nAr = find(idxAr,1,'last');
        if nAr == 32
            nAr = 64;
        else
            nAr = 32;
        end
    end
    nn = [32 32];
    spkEvt = arrayfun(@(nU) sparse(nU,(tWin*2)*conv),nn,'UniformOutput',false);
    spkEvt = repmat(spkEvt,[nEvt,1 ]); % repeats for number of events
    for iii = 1:nCh
        spT = B{i}.Channels(iii).Spikes(:,[2 4]);
        Tt = spT(:,2); % spike times in seconds
        clear spT
        evtIdx = (Tt > ([evt.Ts]-tWin)) & (Tt < [evt.Ts]+tWin); % indices for all the spikes within the designated window around the event
        if nAr == 64 % helps reorganize channels to each array (after 32ch, it switches to a new column)
            if iii <=32
                c = 2;
            else
                c = 1;
            end
        else
            if iii <=32
                c = 1;
            else
                c = 2;
            end
        end
        cc = floor(iii/33);
        % c = 1 + cc;
        chNum = iii - (32*cc);
        for iiii = 1:nEvt
            idx = ceil((Tt(evtIdx(:,iiii))' - evt(iiii).Ts + tWin)*conv); % spike times relative to window in ms (e.g. 2, 4, 14... 997 ms if the window is 1s)
            spkEvt{iiii,c}(chNum,idx) =  spkEvt{iiii,c}(chNum,idx) + 1; % should result in a nEv x 2 cell with nEv trials for 2 areas
        end
    end
    sdata = spkEvt(1,:);
    for eIdx = 2:nEvt
        for aa = 1:2 % currently set for 2 areas
            sdata{aa} = sdata{aa} + spkEvt{eIdx,aa};
        end
    end
    sdata = cellfun(@(d) (full(d)./nEvt),sdata,'UniformOutput',false); % now collapsed across trials
    for y = 1:2 % save average trial activity with channels by area
        bl{i,y} = sdata{y};
    end
    clear spkEvt sdata
end % end of block level

for z = 1:2 % create one big list of channels with average activity for each array
    stB = (bl{1,z});
    if nBl > 1
        for zz = 2:nBl
            bldat = bl{zz,z};
            stB = [stB; bldat];
        end
    end
    Bb{z} = stB; % append channels from multiple blocks to average for a condition;
end

szCh = size(Bb{1},1);
blAvg = cell(2,1);

for z = 1:2 % create one big list of channels with average activity for each array
    bbAvg{z} = (sum(Bb{z},1))./szCh;
    for zz = 1:nBl
        blAvg{zz,z} = (sum(bl{zz,z},1))./32;
    end
end

bbAvg = cellfun(@(d) smoothdata(...
    d*1000,2,...
    'gaussian',100),...
    bbAvg,'UniformOutput',false);

blAvg = cellfun(@(d) smoothdata(...
    d*1000,2,...
    'gaussian',100),...
    blAvg,'UniformOutput',false);

%% Repeat for unaligned spiking activity using 'Contact'
evID = {'Name','Contact'}; % find in blockObj.Events
for i = 1:nBl
    E = B{i}.Events;
    ChArea = {B{i}.Channels.area};
    field = evID{1};
    val = evID{2};
    idx = strcmp([E.(field)],val); % must be a cell
    evt = E(idx); % returns reduced Events structure
    nEvt = numel(evt);
    idxAr = strcmp(ChArea,grPlot{1});
    if level(i) == 0 % flip orientation so that contralateral RFAs are averaged/plotted together
        nAr = find(idxAr,1,'last');
    else
        nAr = find(idxAr,1,'last');
        if nAr == 32
            nAr = 64;
        else
            nAr = 32;
        end
    end
    nn = [32 32];
    spkEvt = arrayfun(@(nU) sparse(nU,(tWin*2)*conv),nn,'UniformOutput',false);
    spkEvt = repmat(spkEvt,[nEvt,1 ]); % repeats for number of events
    for iii = 1:nCh
        spT = B{i}.Channels(iii).Spikes(:,[2 4]);
        Tt = spT(:,2); % spike times in seconds
        clear spT
        evtIdx = (Tt > ([evt.Ts]-tWin)) & (Tt < [evt.Ts]+tWin); % indices for all the spikes within the desgnated window around the event
        if nAr == 64 % helps reorganize channels to each array (after 32ch, it switches to a new column)
            if iii <=32
                c = 2;
            else
                c = 1;
            end
        else
            if iii <=32
                c = 1;
            else
                c = 2;
            end
        end
        cc = floor(iii/33);
        % c = 1 + cc;
        chNum = iii - (32*cc);
        for iiii = 1:nEvt
            idx = ceil((Tt(evtIdx(:,iiii))' - evt(iiii).Ts + tWin)*conv); % spike times relative to window in ms (e.g. 2, 4, 14... 997 ms if the window is 1s)
            spkEvt{iiii,c}(chNum,idx) =  spkEvt{iiii,c}(chNum,idx) + 1; % should result in a nEv x 2 cell with nEv trials for 2 areas
        end
    end
    sdata = spkEvt(1,:);
    for eIdx = 2:nEvt
        for aa = 1:2 % currently set for 2 areas
            sdata{aa} = sdata{aa} + spkEvt{eIdx,aa};
        end
    end
    sdata = cellfun(@(d) (full(d)./nEvt),sdata,'UniformOutput',false); % now collapsed across trials
    for y = 1:2 % save average trial activity with channels by area
        blC{i,y} = sdata{y};
    end
    clear spkEvt sdata
end % end of block level

for z = 1:2 % create one big list of channels with average activity for each array
    stB = (blC{1,z});
    if nBl > 1
        for zz = 2:nBl
            bldat = blC{zz,z};
            stB = [stB; bldat];
        end
    end
    BbC{z} = stB; % append channels from multiple blocks to average for a condition;
end

szCh = size(BbC{1},1);
blAvgC = cell(2,1);

for z = 1:2 % create one big list of channels with average activity for each array
    bbAvgC{z} = (sum(BbC{z},1))./szCh;
    for zz = 1:nBl
        blAvgC{zz,z} = (sum(blC{zz,z},1))./32;
    end
end

bbAvgC = cellfun(@(d) smoothdata(...
    d*1000,2,...
    'gaussian',100),...
    bbAvgC,'UniformOutput',false);

blAvgC = cellfun(@(d) smoothdata(...
    d*1000,2,...
    'gaussian',100),...
    blAvgC,'UniformOutput',false);
%% Plot figures
x = (1:1000); % with 1s windows
for z = 1:2 % create one big list of channels with average activity for each array
    figure;
    hold on
    mn = mean(bbAvgC{z});
    stdv = std(bbAvgC{z})*3;
    patch([x fliplr(x)], [repmat(mn-stdv,1,1000)  repmat(fliplr(mn+stdv),1,1000)], [0.6  0.7  0.8],'EdgeColor','none','FaceAlpha',.75);
    yline(mn,'k');
    plot(bbAvg{z});
    name = 'Block Average; Area %s';
    g = orPlot{z};
    str = sprintf(name,g);
    title(str);
    hold off
    for zz = 1:nBl
        figure;
        hold on
        mn = mean(blAvgC{zz,z});
        stdv = std(blAvgC{zz,z})*3;
        patch([x fliplr(x)], [repmat(mn-stdv,1,1000)  repmat(fliplr(mn+stdv),1,1000)], [0.6  0.7  0.8],'EdgeColor','none','FaceAlpha',.75);
        yline(mn,'k');
        plot(blAvg{zz,z});
        name = 'Block %d Average; Area %s';
        g = orPlot{z};
        str = sprintf(name,zz,g);
        title(str);
        hold off
    end
end
