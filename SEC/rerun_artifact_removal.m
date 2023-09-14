directory_locA = dir(pwd);
directory_locA = directory_locA(~ismember({directory_locA.name},{'.','..'}));
for i = 1:size(directory_locA)
    directory_locB = dir(fullfile(directory_locA(i).folder,directory_locA(i).name));
    directory_locB = directory_locB(~ismember({directory_locB.name},{'.','..'}));
    idx = contains({directory_locB.name},{'RawData_StimSmoothed'});
    if sum(idx) > 0
        cd(fullfile(directory_locB(idx).folder,directory_locB(idx).name));
        directory_loc = pwd;
        directory = dir(directory_loc);
        directory = directory(~ismember({directory.name},{'.','..'}));
        for i = 1:size(directory,1)
            load([directory(i).name],'pars');
            algorithm = pars.algorithm;
            if isfield(pars,'satVolt')
                if isfield(pars,'blanking')
                    disp('What are you thinking??!')
                    return
                end
            end
            meta = split([directory(i).name],'_');
            meta{10}(end-3:end) = [];
            loc = split(directory_loc,'\');
            f_ch = char(join(meta(8:10),'_'));
            f_name = char(join(meta(1:5),'_'));
            f_dir = char(join(loc(1:end-1),'\'));
            stim_artifact_removal(f_dir,f_name,f_ch,algorithm,pars);
            filter_rereference(f_dir,f_name,f_ch);
        end
    end
end
