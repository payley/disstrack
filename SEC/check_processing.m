%% Check signal for artifact cleaning 
function check_processing(DataStructure,idxA,idxD,alt)
% runs through both arrays and all channels
% currently configured to work only with stim workflow
% needs to be reworked to also use with other workflows
%
% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% alt; string input for setting the case:
%   'clean', plots the average of all cleaned trials for each channel 
%   'art', plots a single artifact over the raw data for each channel
%   'single', plots the average of all cleaned trails for a single channel
%
% OUTPUT:
% only figures at this point

switch alt
    case 'clean'
        for i = idxA
            for d = idxD
                for j = 1:length(DataStructure(i).StimOn)
                    if DataStructure(i).StimOn(j) == 1
                        curFileName = [DataStructure(i).AnimalName '_' ...
                            DataStructure(i).DateStr{d} '_' ...
                            num2str(DataStructure(i).Run{d}(j))];
                        locS = (fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                            curFileName,[curFileName '_Filtered_StimSmoothed']));
                        s = dir(locS);
                        s = s(~ismember({s.name},{'.','..'}));
                        s = s(~contains({s.name},'Filtspecs'));
                        load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                            curFileName,[curFileName '_StimTimes']),'StimOnsets');
                        if exist('f1','var') % creates new figures for comparison
                            f3 = figure;
                            f4 = figure;
                        else
                            f1 = figure;
                            f2 = figure;
                        end
                        for ii = 1:size(s,1)
                            subs = [];
                            meta = split((s(ii).name),"_");
                            if strcmp(meta{7},'P1') == 1
                                c = double(string(meta{9}(2:3))) + 1;
                                load([char({s(ii).folder}) '/' char({s(ii).name})],'data','fs');
                                smooth = data;
                                ms = fs/1000; % samples per ms
                                for v = 1:numel(StimOnsets)
                                    subs = [subs; smooth(StimOnsets(v)-(10*ms):StimOnsets(v)+(10*ms))];
                                end
                                if exist('f3','var') 
                                    set(0, 'CurrentFigure', f3)
                                else
                                    set(0, 'CurrentFigure', f1)
                                end
                                mean_subs = mean(subs,1);
                                std_subs = std(subs,0,1);
                                tt = linspace(-10,10,601);
                                subplot(4,8,c);
                                fill([tt, flip(tt)], [mean_subs+std_subs, flip(mean_subs-std_subs)],'blue','FaceAlpha',0.3,'EdgeColor','none');
                                hold on
                                plot(tt,mean_subs,'black');
                                ylim([-100 100]);
                                title(c-1);
                            elseif strcmp(meta{7},'P2') == 1
                                c = double(string(meta{9}(2:3))) + 1;
                                load([char({s(ii).folder}) '/' char({s(ii).name})],'data','fs');
                                smooth = data;
                                ms = fs/1000; % samples per ms
                                for v = 1:numel(StimOnsets)
                                    subs = [subs; smooth(StimOnsets(v)-(10*ms):StimOnsets(v)+(10*ms))];
                                end
                                if exist('f4','var') 
                                    set(0, 'CurrentFigure', f4)
                                else
                                    set(0, 'CurrentFigure', f2)
                                end
                                mean_subs = mean(subs,1);
                                std_subs = std(subs,0,1);
                                tt = linspace(-10,10,601);
                                subplot(4,8,c);
                                fill([tt, flip(tt)], [mean_subs+std_subs, flip(mean_subs-std_subs)],'blue','FaceAlpha',0.3,'EdgeColor','none');
                                hold on
                                plot(tt,mean_subs,'black');
                                ylim([-100 100]);
                                title(c-1);
                            end
                        end
                        if exist('f3','var') 
                            set(f3,'Name',[curFileName ' P1 Smoothed']);
                            set(f4,'Name',[curFileName ' P2 Smoothed']);
                        else
                            set(f1,'Name',[curFileName ' P1 Smoothed']);
                            set(f2,'Name',[curFileName ' P2 Smoothed']);
                        end
                    end
                end
            end
        end
    case 'art'
        for i = idxA
            for d = idxD
                for j = 1:length(DataStructure(i).StimOn)
                    if DataStructure(i).StimOn(j) == 1
                        curFileName = [DataStructure(i).AnimalName '_' ...
                            DataStructure(i).DateStr{d} '_' ...
                            num2str(DataStructure(i).Run{d}(j))];
                        locS = (fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                            curFileName,[curFileName '_RawData_StimSmoothed']));
                        locR = (fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                            curFileName,[curFileName '_RawData']));
                        s = dir(locS);
                        r = dir(locR);
                        s = s(~ismember({s.name},{'.','..'}));
                        r = r(~ismember({r.name},{'.','..'}));
                        r = r(~contains({r.name},'RawWave'));
                        load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                            curFileName,[curFileName '_StimTimes']),'StimOnsets');
                        nStimOnsets = numel(StimOnsets);
                        idx = randperm(nStimOnsets,1);
                        idxS = StimOnsets(idx);
                        if exist('f1','var') % creates new figures for comparison
                            f3 = figure;
                            f4 = figure;
                        else
                            f1 = figure;
                            f2 = figure;
                        end
                        for ii = 1:size(s,1)
                            subs = [];
                            meta = string(split((s(ii).name),"_"));
                            meta(7) = [];
                            if strcmp(meta(7),'P1') == 1
                                c = double(string(meta{9}(2:3))) + 1;
                                meta = join(meta,"_"); 
                                load([char({s(ii).folder}) '/' char({s(ii).name})],'data','fs');
                                ms = fs/1000; % samples per ms
                                clean = data;
                                load(fullfile({r(ii).folder}, meta),'data');
                                raw = data;
                                artifact = raw - clean;
                                if exist('f3','var') 
                                    set(0, 'CurrentFigure', f3)
                                else
                                    set(0, 'CurrentFigure', f1)
                                end
                                subplot(4,8,c);
                                hold on
                                plot(linspace(-10,10,601),raw(idxS-(10*ms):idxS+(10*ms)));
                                plot(linspace(-10,10,601),artifact(idxS-(10*ms):idxS+(10*ms)));
                                title(c-1);
                            elseif strcmp(meta{7},'P2') == 1
                                c = double(string(meta{9}(2:3))) + 1;
                                meta = join(meta,"_");
                                load([char({s(ii).folder}) '/' char({s(ii).name})],'data','fs');
                                ms = fs/1000; % samples per ms
                                clean = data;
                                load(fullfile({r(ii).folder}, meta),'data');
                                raw = data;
                                artifact = raw - clean;
                                if exist('f4','var')
                                    set(0, 'CurrentFigure', f4)
                                else
                                    set(0, 'CurrentFigure', f2)
                                end
                                subplot(4,8,c);
                                hold on
                                plot(linspace(-10,10,601),raw(idx-(10*ms):idx+(10*ms)));
                                plot(linspace(-10,10,601),artifact(idx-(10*ms):idx+(10*ms)));
                                title(c-1);
                            end
                        end
                        if exist('f3','var') 
                            set(f3,'Name',[curFileName ' P1 Artifact']);
                            set(f4,'Name',[curFileName ' P2 Artifact']);
                        else
                            set(f1,'Name',[curFileName ' P1 Artifact']);
                            set(f2,'Name',[curFileName ' P2 Artifact']);
                        end
                    end
                end
            end
        end
    case 'single'
        subs = [];
        load(fullfile(DataStructure,[idxA '_StimTimes']),'StimOnsets');
        load(fullfile(DataStructure,[idxA '_Filtered_StimSmoothed'],[idxA '_Filt_' idxD]),'data','fs');
        smooth = data;
        ms = fs/1000; % samples per ms
        for v = 1:numel(StimOnsets)
            subs = [subs; smooth(StimOnsets(v)-(10*ms):StimOnsets(v)+(10*ms))];
        end
        mean_subs = mean(subs,1);
        std_subs = std(subs,0,1);
        tt = linspace(-10,10,601);
        figure;
        fill([tt, flip(tt)], [mean_subs+std_subs, flip(mean_subs-std_subs)],'blue','FaceAlpha',0.3,'EdgeColor','none');
        hold on
        plot(tt,mean_subs,'black');
        ylim([-100 100]);
        title([idxA idxD],'Interpreter','none');
end