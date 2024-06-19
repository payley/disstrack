%% Make z-distribution from catch trial
function chPlot = base_spiking(chPlot,sw,bin_sz,win,f_loc,tr)
% takes the total number of elements in an array and sums neighboring 
% elements together in bins
%
% INPUT: 
% chPlot, table of channel values
% sw; switch methods of determining baseline (either 'pre' or 'catch')
% f_loc; file location
% tr; number of stimulation trials to match
% win; window of interest in ms
% bin_sz; length of time for each bin
%
% OUTPUT:
% chPlot; updated table of channel values

switch sw
    case 'catch'
        cd(f_loc{1});
        D = dir;
        D(matches({D(:).name},'.')) = [];
        D(matches({D(:).name},'..')) = [];
        reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
            24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
            60 61 62 63 64 53 54 55 56 57 58 49 50 51 52];
        if numel(D) < 64
            reArr = [11 12 13 14 15 16 5 6 7 8 9 10 1 2 3 4 20 19 18 17 26 25 24 23 22 21 ...
                32 31 30 29 28 27 43 44 45 46 47 48 37 38 39 40 41 42 33 34 35 36];
        end
        for i = 1:numel(D) % runs for every channel
            load(D(reArr(i)).name);
            fs = pars.FS;
            samp = (fs/1000 * win); % number of samples in the time window of interest
            lng = size(peak_train,1); % total number of samples in the recording
            ext = lng - samp; % number of samples to select from as start points
            idxS = randperm(ext,tr); % randomly generates start points for trials
            Sp = [];
            for ii = 1:tr % repeats for every trial to be generated
                sp = zeros(1,samp);
                idxSp = find(peak_train(idxS(ii):idxS(ii) + samp - 1));
                sp(idxSp) = 1;
                sp = sparse(sp);
                Sp = [Sp; sp];
            end
            chPlot.baseline{i} = Sp;
            bSp = bin_data(sum(Sp,1),bin_sz,fs);
            [~,zm,zs] = zscore(bSp./tr);
            chPlot.z_mean{i} = zm;
            chPlot.z_std{i} = zs;
        end
    case 'pre'
        cd('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct');
        [C,sel] = select_data(L,DataStructure,1);
        load('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\');
end

