%% Make table of all stim blocks 
dir = [];
animal_name = [];
bl_list = [];
stim_ch = [];
stim_probe = [];
probe_flip = [];
stim_array = {};
inj_array = [];
postinj_time = [];
postimpl_time = [];
ct = 1; % used to add data for each loop
idxSub = 2:13;
aa = L.animals(idxSub);
p_injh = [1,2,1,1,1,2,2,1,2,1,2,1];
cd('C:\MyRepos\disstrack\SEC')
load('inj_dates.mat');
load('impl_dates.mat');
for i = 1:numel(aa)
    idxA = idxSub(i);
    dd = L.dates{idxA};
    for ii = 1:numel(dd)
        iDate = dd(ii);
        runs = DataStructure(idxA).Run{ii};
        rIdx = find(logical(DataStructure(idxA).StimOn)); 
        for iii = rIdx
            dir = [dir {fullfile(DataStructure(idxA).NetworkPath,DataStructure(idxA).AnimalName)}];
            bl_list = [bl_list string(fullfile([char(aa{i}) '_' char(iDate) '_' char(string(runs(iii)))]))]; 
            stim = DataStructure(idxA).StimChannel{ii}(iii);
            stim_ch = [stim_ch stim];
            stP = DataStructure(idxA).StimProbe(iii);
            stim_probe = [stim_probe stP];
            inj_array = [inj_array p_injh(i)];
            animal_name = [animal_name; string(aa{i})];
            if iscell(DataStructure(idxA).P1Site) % deals with exception with different probe sites
                site = DataStructure(idxA).P1Site{iii};
            else
                site = DataStructure(idxA).P1Site;
            end
            if site == 'rRFA'
                probe_flip = [probe_flip 1];
                if stP == 1
                    stim_array{ct} = 'rRFA';
                elseif stP == 2
                    stim_array{ct} = 'lRFA';
                end
            else
                probe_flip = [probe_flip 0];
                if stP == 1
                    stim_array{ct} = 'lRFA';
                elseif stP == 2
                    stim_array{ct} = 'rRFA';
                end
            end
            % determine post-inj day
            meta = split(iDate,'_');
            dt = datetime(join(meta,'-'));
            if dt < inj_dates.dates(i)
                dy = 0;
            elseif isnat(inj_dates.dates(i))
                dy = 0;
            else
                dur = between(inj_dates.dates(i),dt,'days');
                dy = split(dur,{'days'});
            end
            postinj_time = [postinj_time; dy];
            % find post-implant day
            dur = between(impl_dates.dates(i),dt,'days');
            dy = split(dur,{'days'});
            postimpl_time = [postimpl_time; dy];
            ct = ct + 1; % used to add data for each loop
        end
    end
end
C = table(animal_name,bl_list',dir',stim_ch',stim_probe',probe_flip',...
    stim_array',inj_array',postinj_time,postimpl_time,'VariableNames',{'Animal_Name','Blocks','Dir',...
    'Stim_Ch','Stim_Probe','Probe_Flip','Stim_Array','Inj_Array','PostInj_Time','PostImpl_Time'});
clearvars -except C L DataStructure