%% Find d' value for first 5 ms

% set variables for statistical tests
time_win = [0 5]; % timing of interest in ms
bn_sz = 0.2; % rebinned data
fs = 30000; % sample rate

% create variables for table
animal_name = {};
block = {};
array = [];
ch = {};
stim_ch = [];
stim_probe = [];
inj_array = [];
postinj_t = [];
dprime = [];
D = table(animal_name,block,array,ch,stim_ch,stim_probe,inj_array,postinj_t,dprime);
D = table2struct(D);
pl = 1;

% locate chPlot file
for bb = 1:size(C,1)
    root = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
    meta = split(C.Blocks{bb},'_');
    f_loc = fullfile(root,meta{1},C.Blocks{bb});
    cd(f_loc)
    load([C.Blocks{bb} '_stats_swtteo.mat']);
    fprintf('%s\n',C.Blocks{bb})
    % find d-prime value for every channel
    for i = 1:size(chPlot,1)
        sr = 200/6000; % current time represented by every sample
        sw = time_win(2)/sr; % samples within the window
        blank = sum(chPlot.blank_win{i}(1:sw) == 0) * sr; % finds the blanked indices within the window and converts to ms
        rawD = chPlot.evoked_trials{i};
        d = d_prime(rawD,time_win,blank,bn_sz,fs);
        % add values and associated variables to structure
        D(pl).animal_name = C.Animal_Name(bb);
        D(pl).block = C.Blocks(bb);
        D(pl).array = str2double(chPlot.arr{i}(2));
        D(pl).ch = chPlot.ch{i};
        D(pl).stim_ch = C.Stim_Ch(bb);
        D(pl).stim_probe = C.Stim_Probe(bb) == D(pl).array;
        D(pl).inj_array = C.Inj_Array(bb) == D(pl).array;
        D(pl).postinj_t = C.PostInj_Time(bb);
        D(pl).dprime = d;
        pl = pl + 1;
    end
end
D([D(:).stim_probe] == 0) = []; % remove any channels on the unstimulated array
D = struct2table(D); % convert to table
D.inj = zeros(size(D,1),1);
D.inj(D.postinj_t > 0) = 1;
D.week = zeros(size(D,1),1);
D.week(D.postinj_t > 0 & D.postinj_t < 7) = 1;
D.week(D.postinj_t > 7 & D.postinj_t < 14) = 2;
D.week(D.postinj_t > 14 & D.postinj_t < 21) = 3;
D.week(D.postinj_t > 21 & D.postinj_t < 28) = 4;
D.week = categorical(D.week);
%% Make a GLME model
formula = 'dprime ~ inj*postinj_t + inj_array:postinj_t + (1|animal_name:ch)';
mixed_model = fitglme(D, formula,'Distribution','Normal');

formula = 'dprime ~ inj_array*week + (1|animal_name:ch)';
mixed_model = fitglme(D, formula,'Distribution','Normal');
anova(mixed_model);