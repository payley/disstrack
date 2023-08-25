% basic format for updating parameters in files
% this format specifically works while being in the RawData_StimSmoothed
% directory
f_dir = pwd;
files = dir(f_dir);
files = files(~ismember({files.name},{'.','..'}));
nF = size(files,1);
% TimeAfter_ms = 1;
for i = 1:nF
    load(string({files(i).name}),'pars');
    if strfind(pars.algorithm,'Salpa') == 1
        meta_dir = split(f_dir,'\');
        dir_base = join(string(meta_dir(1:8)),'\');
        dir_name1 = string(f_dir);
%         dir_name2 = string(fullfile(dir_base, [char(meta_dir(8)) '_Filtered_StimSmoothed']));
        meta_f = split(files(i).name,'_');
        bl_name = join(string(meta_f(1:5)),'_');
        ch_name = join(string(meta_f(8:10)),'_');
        f_loc1 = string(fullfile(dir_name1,[char(bl_name) '_Raw_StimSmoothed_' char(ch_name)]));
%         f_loc2 = string(fullfile(dir_name2,[char(bl_name) '_Filt_' char(ch_name)]));
        load(f_loc1,'pars');
        pars.fs = 30000;
        save(f_loc1,'pars','-append');
%         save(f_loc2,'TimeAfter_ms','-append');
        disp(f_loc1);
    end
end