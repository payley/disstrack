%% Check signal for artifact cleaning 
function check_processing(DataStructure,idxA,idxD)
% runs through both arrays and all channels
% currently configured to work only with stim workflow
% needs to be reworked to also use with other workflows
%
% INPUT: 
% plot; a string input for setting the case: 
% 'lat' for plotting latency using a multicolored patch plot
% 'amp' for plotting amplitude of the response using the same plot type
% 'both' for plotting latency and amplitude of response
% 'map' for plotting map data related to SEC assays
% C; a table of blocks selected and their respective stimulation array/channel
% nI; an optional table of ICMS-evoked movements reorganized by plotting order
% nm; an optional string for the corresponding map dates
%
%
% OUTPUT:
% only figures at this point

for i = idxA 
    for d = idxD 
        for j = 1:length(DataStructure(i).StimOn)
            if DataStructure(i).StimOn(j) == 1
                curFileName = [DataStructure(i).AnimalName '_' ...
                    DataStructure(i).DateStr{d} '_' ...
                    num2str(DataStructure(i).Run{d}(j))];
                loc = (fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                    curFileName,[curFileName '_RawData_StimSmoothed']));
                d = dir(loc);
                d = d(~ismember({d.name},{'.','..'}));
                load(fullfile(DataStructure(i).NetworkPath,DataStructure(i).AnimalName,...
                    curFileName,[curFileName '_StimTimes']));
                f1 = figure;
                f2 = figure;
                for ii = 1:size(d,1)
                    idx = randperm(StimOnsets,1);
                    meta = split((d(ii).name),"_");
                    meta(7) = [];
                    if meta{7} == 'P1'
                        r = join(ans,"_");
                        load(r(ii).name);
                        raw = output;
                        load(d(ii).name);
                        data = output;
                        art = raw - data;
                        ms = fs/100; % samples per ms
                        subplot(4,6,c,'Parent',f1);
                        yyaxis left
                        plot(-10:10,art(idx-(10*ms):idx+(10*ms)));
                        yyaxis right
                        plot(d(idx-(10*ms):idx+(10*ms)));
                    elseif meta{7} == 'P2'
                        r = join(ans,"_");
                        load(r(ii).name);
                        raw = output;
                        load(d(ii).name);
                        data = output;
                        art = raw - data;
                        ms = fs/100; % samples per ms
                        subplot(4,6,c,'Parent',f2);
                        yyaxis left
                        plot(-10:10,art(idx-(10*ms):idx+(10*ms)));
                        yyaxis right
                        plot(d(idx-(10*ms):idx+(10*ms)));
                    end
                end
                title(f1,[curFileName 'P1']);
                title(f2,[curFileName 'P2']);
                [idxF,~] = listdlg('PromptString','Select channels to redo:','ListString',{d(:).name});
                h = d(idxF);
                idxF = string({h.name})';
                satVolt = inputdlg('Set voltages for saturation:');
                algorithm = 'Fra';
                pars = struct('satVolt',satVolt{1},'idxF',idxF);
                stim_artifact_removal(DataStructure,idxA,idxD,algorithm,pars);
                f3 = figure;
                f4 = figure;
                for ii = 1:size(d,1)
                    idx = randperm(StimOnsets,1);
                    meta = split((d(ii).name),"_");
                    meta(7) = [];
                    if meta{7} == 'P1'
                        r = join(ans,"_");
                        load(r(ii).name);
                        raw = output;
                        load(d(ii).name);
                        data = output;
                        art = raw - data;
                        ms = fs/100; % samples per ms
                        subplot(4,6,c,'Parent',f3);
                        yyaxis left
                        plot(-10:10,art(idx-(10*ms):idx+(10*ms)));
                        yyaxis right
                        plot(d(idx-(10*ms):idx+(10*ms)));
                    elseif meta{7} == 'P2'
                        r = join(ans,"_");
                        load(r(ii).name);
                        raw = output;
                        load(d(ii).name);
                        data = output;
                        art = raw - data;
                        ms = fs/100; % samples per ms
                        subplot(4,6,c,'Parent',f4);
                        yyaxis left
                        plot(-10:10,art(idx-(10*ms):idx+(10*ms)));
                        yyaxis right
                        plot(d(idx-(10*ms):idx+(10*ms)));
                    end
                    title(f1,[curFileName 'P1 new']);
                    title(f2,[curFileName 'P2 new']);
                end
            end
        end
    end
end