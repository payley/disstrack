load('SEC_DataStructure.mat');
stim_ch = [];
[idxA,~] = listdlg('PromptString','Select animal(s):','ListString',{DataStructure.AnimalName});
[idxD,~] = listdlg('PromptString','Select day(s):','ListString',DataStructure(idxA).DateStr);
for i = [5] % set as the runs you want to check
    curFileName = [DataStructure(idxA).AnimalName '_' ...
        DataStructure(idxA).DateStr{idxD} '_' ...
        num2str(DataStructure(idxA).Run{idxD}(i))];
    for ii = 1:64
        if ii < 33
            nii = ii - 1;
            aCh = cell2mat(compose('%03d',nii));
            load(fullfile(DataStructure(idxA).NetworkPath,DataStructure(idxA).AnimalName,...
                curFileName,...
                [curFileName '_Digital'],...
                'STIM_DATA',...
                [curFileName '_STIM_P1_Ch_' aCh '.mat']));
            disp(['P1_Ch_' aCh])
            if range(data) > 0
                disp('Found!')
                add = string(sprintf('P1 %s',aCh));
                stim_ch = [stim_ch add];
            end
        else
            nii = ii - 33;
            aCh = cell2mat(compose('%03d',nii));
            load(fullfile(DataStructure(idxA).NetworkPath,DataStructure(idxA).AnimalName,...
                curFileName,...
                [curFileName '_Digital'],...
                'STIM_DATA',...
                [curFileName '_STIM_P2_Ch_' aCh '.mat']));
            disp(['P2_Ch_' aCh])
            if range(data) > 0
                disp('Found!')
                add = string(sprintf('P2 %s',aCh));
                stim_ch = [stim_ch add];
            end
        end
    end
end