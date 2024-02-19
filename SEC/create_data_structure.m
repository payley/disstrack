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
DataStructure(RatInd).DateStr =  {'2021_04_01','2021_04_07','2021_04_09'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[0 1 2 5 6],[0 1 2 3 4],[0 1 2 3 4]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 16 0 1 0],[0 15 0 17 0],[0 20 0 5 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '015' 'NaN' '000' 'NaN'},{'NaN' '014' 'NaN' '016' 'NaN'},{'NaN' '019' 'NaN' '004' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 60 0 60 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
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
%% R21-10
RatInd = 3;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R21-10';
DataStructure(RatInd).DateStr =  {'2021_07_05','2021_07_07','2021_07_13','2021_07_22',...
                                  '2021_08_06'}; 
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'rRFA';
DataStructure(RatInd).P2Site = 'lRFA';
DataStructure(RatInd).Run =         {[0 1 2 3 4],[1 2 3 4 5],[1 2 3 4 5],[2 4 5 6 7],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 2 0 1 0],[0 2 0 1 0],[0 2 0 1 0],[0 2 0 1 0],... 
                                     [0 2 0 1 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '001' 'NaN' '000' 'NaN'},{'NaN' '001' 'NaN' '000' 'NaN'},{'NaN' '001' 'NaN' '000' 'NaN'},{'NaN' '001' 'NaN' '000' 'NaN'},... 
                                  {'NaN' '001' 'NaN' '000' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-01
RatInd = 4;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-01';
DataStructure(RatInd).DateStr =  {'2022_02_22','2022_02_28','2022_03_09','2022_03_15',...
                                '2022_03_22','2022_03_29','2022_04_06'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = {'rRFA','rRFA','rRFA','rRFA','rRFA','lRFA','rRFA'};
DataStructure(RatInd).P2Site = {'lRFA','lRFA','lRFA','lRFA','lRFA','rRFA','lRFA'};
DataStructure(RatInd).Run =         {[0 1 2 3 4],[1 2 3 4 5],[0 1 2 3 4],[1 2 3 4 5],...
                                     [1 2 3 4 5], [2 5 4 3 6], [1 2 3 4 5]}; % switched block order for 3/29 may need to rethink if order matters
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 1 0 10 0],[0 1 0 10 0],[0 2 0 10 0],[0 2 0 10 0],...
                                     [0 2 0 10 0],[0 10 0 2 0],[0 2 0 10 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '000' 'NaN' '009' 'NaN'},{'NaN' '000' 'NaN' '009' 'NaN'},{'NaN' '001' 'NaN' '009' 'NaN'},{'NaN' '001' 'NaN' '009' 'NaN'},...
                                  {'NaN' '001' 'NaN' '009' 'NaN'},{'NaN' '009' 'NaN' '001' 'NaN'},{'NaN' '001' 'NaN' '009' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-02
RatInd = 5;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-02';
DataStructure(RatInd).DateStr =  {'2022_02_24','2022_03_02','2022_03_07','2022_03_10',...
                                '2022_03_14'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = {'rRFA'};
DataStructure(RatInd).P2Site = {'lRFA'};
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 4 5 6 7],[1 2 3 4 5],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 32 0 10 0],[0 32 0 10 0],[0 12 0 10 0],[0 12 0 10 0],...
                                     [0 12 0 10 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '031' 'NaN' '009' 'NaN'},{'NaN' '031' 'NaN' '009' 'NaN'},{'NaN' '011' 'NaN' '009' 'NaN'},{'NaN' '011' 'NaN' '009' 'NaN'},...
                                  {'NaN' '011' 'NaN' '009' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-05
RatInd = 6;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-05';
DataStructure(RatInd).DateStr =  {'2022_04_03','2022_04_12','2022_04_19','2022_04_27','2022_05_04',...
                                '2022_05_11','2022_05_19'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5]...
                                     [1 2 3 4 5],[1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 2 0 1 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 3 0 21 0],[0 3 0 8 0],[0 3 0 8 0],[0 3 0 8 0],[0 3 0 21 0],...
                                     [0 3 0 21 0],[0 3 0 21 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '002' 'NaN' '020' 'NaN'},{'NaN' '002' 'NaN' '007' 'NaN'},{'NaN' '002' 'NaN' '007' 'NaN'},{'NaN' '002' 'NaN' '007' 'NaN'},{'NaN' '002' 'NaN' '020' 'NaN'},...
                                  {'NaN' '002' 'NaN' '020' 'NaN'},{'NaN' '002' 'NaN' '020' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-27
RatInd = 7;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-27';
DataStructure(RatInd).DateStr =  {'2022_09_03','2022_09_25','2022_10_03','2022_10_10',...
                                '2022_10_17'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5 ],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 21 0 6 0],[0 21 0 6 0],[0 21 0 16 0],[0 16 0 16 0],...
                                     [0 21 0 16 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '020' 'NaN' '005' 'NaN'},{'NaN' '020' 'NaN' '005' 'NaN'},{'NaN' '020' 'NaN' '015' 'NaN'},{'NaN' '015' 'NaN' '015' 'NaN'},...
                                  {'NaN' '020' 'NaN' '015' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-28
RatInd = 8;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-28';
DataStructure(RatInd).DateStr =  {'2022_09_07','2022_09_26','2022_10_03','2022_10_10',...
                                '2022_10_17'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 13 0 26 0],[0 26 0 13 0],[0 26 0 13 0],[0 26 0 6 0],...
                                     [0 26 0 4 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '012' 'NaN' '025' 'NaN'},{'NaN' '025' 'NaN' '012' 'NaN'},{'NaN' '025' 'NaN' '012' 'NaN'},{'NaN' '025' 'NaN' '005' 'NaN'},...
                                  {'NaN' '025' 'NaN' '003' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R22-29
RatInd = 9;
DataStructure(RatInd).NetworkPath = 'P:\Extracted_Data_To_Move\Rat\Intan\PH\phEvokedAct\';
DataStructure(RatInd).AnimalName =  'R22-29';
DataStructure(RatInd).DateStr =  {'2022_09_12','2022_09_27','2022_10_04','2022_10_11',...
                                '2022_10_18'};
% DataStructure(RatInd).TimeStr =  {'225041' '225551' '225934' '230447' '230845'};
DataStructure(RatInd).P1Site = 'lRFA';
DataStructure(RatInd).P2Site = 'rRFA';
DataStructure(RatInd).Run =         {[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4 5],[1 2 3 4],...
                                     [1 2 3 4 5]};
DataStructure(RatInd).StimOn =       [0 1 0 1 0];
DataStructure(RatInd).StimProbe =    [0 1 0 2 0]; % change if using NigeLab workflow
DataStructure(RatInd).StimChannel = {[0 20 0 12 0],[0 20 0 12 0],[0 20 0 12 0],[0 20 0 12 0],...
                                     [0 20 0 12 0]};     % convert to id (i.e. A-000) by subtracting one
DataStructure(RatInd).StimChID = {{'NaN' '019' 'NaN' '011' 'NaN'},{'NaN' '019' 'NaN' '011' 'NaN'},{'NaN' '019' 'NaN' '011' 'NaN'},{'NaN' '019' 'NaN' '011' 'NaN'},...
                                  {'NaN' '019' 'NaN' '011' 'NaN'}};
DataStructure(RatInd).StimAmp   =    [0 1 0 1 0];
DataStructure(RatInd).StimPhaseDuration = [0 200 0 200 0];
DataStructure(RatInd).CathLeading =  [0 1 0 1 0];
DataStructure(RatInd).StimBiphasic = [0 1 0 1 0];
DataStructure(RatInd).Pars = struct('NumStimPulses',[],'TimeAfterStim',[],'TimeBeforeStim',[],'ArtRemovalMethod',[],...
    'PolyOrder',[],'ThreshRMS',[],'ThreshMethod',[],'UseCARforNEO',[],'sdRMS',[],'SmoothBW',[],'NResample',[],...
    'DSms',[],'MaxLatency',[]);
%% R23-01
RatInd = 10;
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
RatInd = 11;
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
RatInd = 12;
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
RatInd = 13;
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