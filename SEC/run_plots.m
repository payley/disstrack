%% Run plots for comparison
% Must use a version later than Matlab 2017a
%% Load files
if isfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_list.mat')
    load('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_list.mat');
else
    disp('Missing structual elements or wrong path');
    return
end

if isfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_DataStructure.mat')
    load('P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\SEC_DataStructure.mat');
else
    disp('Missing structual elements or wrong path');
    return
end
%% Plot SEC data as an array
[C,sel] = select_data(L,DataStructure,1); % run selection function
clearvars L DataStructure
plot = 'both';
plot_array(plot,C);
plot = 'lat';
plot_array(plot,C);
resp = 1;
nI = plot_matching_map(C,resp);