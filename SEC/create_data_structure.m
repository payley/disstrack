%% Create Data Structure
DataStructure=struct('NetworkPath',[],'AnimalName',[],...
    'DateStr',[],'Run',[],...
    'P1Site',[],'P2Site',[],'StimOn',[],'StimProbe',[],'StimChannel',[],...
    'StimBiphasic',[],'StimAmp',[],'StimPhaseDuration',[],'CathLeading',[]);
RatInd = 0;

%% R21-09
RatInd = 1;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R21-09';
DataStructure(RatInd).DateStr =  {'2021_06_28','2021_07_05','2021_07_11','2021_07_20',...
                                  '2021_07_21','2021_07_28','2021_08_04'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'rRFA';
DataStructure(RatInd).P2Site = 'lRFA';
DataStructure(RatInd).Run =         {[2 3 4 5 6],[1 2 3 4 5],[3 4 5 6 7],[1 2 3 4 5],...
                                     [3 4 5 6 7],[2 3 4 5 6],[1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 9 0 13 0],[0 9 0 13 0],[0 9 0 13 0],[0 9 0 13 0],...
                                     [0 9 0 13 0],[0 9 0 13 0],[0 9 0 13 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'},...
                                  {'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration_us = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R20-99
RatInd = 2;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R20-99';
DataStructure(RatInd).DateStr =  {'2020_04_01'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5 6]};
DataStructure(RatInd).StimOn =       [1 0 0 0 1 0]; % excluding 3 because it was a faulty trial
DataStructure(RatInd).StimProbe =    [1 0 0 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[16 0 0 0 1 0 ]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'015' 'NaN' 'NaN' 'NaN' '000' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [60 0 0 0 60 0];
DataStructure(RatInd).StimPhaseDuration_us = [200 0 0 0 200 0];
DataStructure(RatInd).CathLeading =  [1 0 0 0 1 0];
DataStructure(RatInd).StimBiphasic = [1 0 0 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% Save
% saves data structure
save('phEvokedAct/SEC_DataStructure.mat','DataStructure')

% creates an updated list of animals and rec dates for easy reference
animals = {DataStructure(:).AnimalName}'; 
dates = cell(numel(animals),1);
L = table(animals,dates);
for c = 1:numel(animals)
    L.dates{c} = string(DataStructure(c).DateStr); 
end
save('phEvokedAct/SEC_list.mat','L')