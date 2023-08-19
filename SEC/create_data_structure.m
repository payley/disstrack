%% Create Data Structure
DataStructure=struct('NetworkPath',[],'AnimalName',[],...
    'DateStr',[],'Run',[],...
    'P1Site',[],'P2Site',[],'StimOn',[],'StimProbe',[],'StimChannel',[],...
    'StimBiphasic',[],'StimAmp',[],'StimPhaseDuration',[],'CathLeading',[]);
RatInd = 0;
%% R20-99
RatInd = 1;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R20-99';
DataStructure(RatInd).DateStr =  {'2021_04_01'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5 6]};
DataStructure(RatInd).StimOn =       [1 0 0 0 1 0]; % excluding 3 because it was a faulty trial
DataStructure(RatInd).StimProbe =    [1 0 0 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[16 0 0 0 1 0 ]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'015' 'NaN' 'NaN' 'NaN' '000' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [60 0 0 0 60 0];
DataStructure(RatInd).StimPhaseDuration = [200 0 0 0 200 0];
DataStructure(RatInd).CathLeading =  [1 0 0 0 1 0];
DataStructure(RatInd).StimBiphasic = [1 0 0 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R21-09
RatInd = 2;
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
                                  {'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'},{'NaN' '008' 'NaN' '012' 'NaN'},...
                                  {'NaN' '008' 'NaN' '012' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R23-01
RatInd = 3;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R23-01';
DataStructure(RatInd).DateStr =  {'2023_01_20','2023_01_23','2023_01_24','2023_01_31',...
                                '2023_02_07','2023_02_14','2023_02_21'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[2 3 4 5 6],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 23 0 3 0],[0 23 0 2 0],[0 21 0 2 0],[0 21 0 7 0],...
                                     [0 4 0 28 0],[0 21 0 28 0],[0 5 0 16 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '022' 'NaN' '004' 'NaN'},{'NaN' '022' 'NaN' '001' 'NaN'},{'NaN' '020' 'NaN' '001' 'NaN'},{'NaN' '020' 'NaN' '006' 'NaN'},...
                                  {'NaN' '003' 'NaN' '027' 'NaN'},{'NaN' '020' 'NaN' '027' 'NaN'},{'NaN' '004' 'NaN' '015' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R23-06
RatInd = 4;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R23-06';
DataStructure(RatInd).DateStr =  {'2023_01_19','2023_01_31','2023_02_07',...
                                  '2023_02_14','2023_02_21'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5],[1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 14 0 21 0],[0 1 0 1 0],[0 4 0 3 0],...
                                     [0 21 0 10 0],[0 8 0 15 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '013' 'NaN' '020' 'NaN'},{'NaN' '000' 'NaN' '000' 'NaN'},{'NaN' '003' 'NaN' '002' 'NaN'},...
                                  {'NaN' '020' 'NaN' '009' 'NaN'},{'NaN' '007' 'NaN' '014' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R23-09
RatInd = 5;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R23-09';
DataStructure(RatInd).DateStr =  {'2023_01_30','2023_02_06','2023_02_13','2023_02_20',...
                                  '2023_02_27'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 3 0 19 0],[0 23 0 21 0],[0 11 0 21 0],[0 11 0 7 0],...
                                     [0 10 0 7 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '002' 'NaN' '018' 'NaN'},{'NaN' '022' 'NaN' '020' 'NaN'},{'NaN' '010' 'NaN' '020' 'NaN'},...
                                  {'NaN' '010' 'NaN' '006' 'NaN'},{'NaN' '009' 'NaN' '006' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R23-10
RatInd = 6;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R23-10';
DataStructure(RatInd).DateStr =  {'2023_01_29','2023_02_06','2023_02_13','2023_02_20',...
                                  '2023_02_27'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 4 0 8 0],[0 5 0 5 0],[0 4 0 4 0],[0 4 0 4 0],...
                                     [0 8 0 3 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '003' 'NaN' '007' 'NaN'},{'NaN' '004' 'NaN' '004' 'NaN'},{'NaN' '003' 'NaN' '003' 'NaN'},...
                                  {'NaN' '003' 'NaN' '003' 'NaN'},{'NaN' '007' 'NaN' '002' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
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