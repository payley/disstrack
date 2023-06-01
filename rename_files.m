%% Useful function to run through directories and rename by replacing patterns
dirOrig = dir();
dirOrig(~[dirOrig.isdir]) = [];
dirOrig(1:2) = [];
for i = 1:numel(dirOrig)
    thisdir = dir(fullfile(dirOrig(i).folder,'**\*.mat'));
    for ii = 1:numel(thisdir)
        if sum(contains(thisdir(ii).name,["P3","P4"])) > 0
            rename = strrep(thisdir(ii).name,'P3','P1');
            rename = strrep(rename,'P4','P2');
            old = fullfile(thisdir(ii).folder,thisdir(ii).name);
            new = fullfile(thisdir(ii).folder,rename);
            movefile(old,new);
        end
    end
end