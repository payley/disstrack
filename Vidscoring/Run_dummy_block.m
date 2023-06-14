%% Make new file for baseline data
% set variables here
set_events = 0; % logical variable to proceed to extract events from video stream (1) or to set stand-in events to skip to the VidScorer (0)
vidpath = 'R:\Rat\Intan\Videos\PH\To Be Sorted';
AnimalID = 'R22-28';
Year = '2022';
Month = '08';
Day = '16';
Phase = '0'; % may also be saved as RecID
RecDate = '220816';
RecTime = '000000';

orig_blockID = ('Dummy-Fill-000000');
blockID = [AnimalID '-' RecDate];
path = fullfile('P:\Extracted_Data_To_Move\Rat\Intan\PH\phDummy');

% checks if a new block with the above metadata has already been created
if ~exist(fullfile(path,blockID)) > 0
    status = copyfile(fullfile(path,orig_blockID),fullfile(path,blockID));
    status = copyfile(fullfile(path,[orig_blockID,'_Block.mat']),fullfile(path,[blockID '_Block.mat']));
    status = copyfile(fullfile(path,[orig_blockID,'_Pars.mat']),fullfile(path,[blockID '_Pars.mat']));

    % loads new blockobj
    load(fullfile(path,[blockID '_Block.mat']));

    % resets variables to match new block
    blockObj.Meta.AnimalID = AnimalID;
    blockObj.Meta.Year = Year;
    blockObj.Meta.Month = Month;
    blockObj.Meta.Day = Day;
    blockObj.Meta.Phase = Phase;
    blockObj.Meta.RecDate = RecDate;
    blockObj.Meta.RecTime = RecTime;
    blockObj.Meta.ParentID = AnimalID;
    blockObj.Meta.BlockID = blockID;

    % initializes videos
    blockObj.Pars.Video.VidFilePath = vidpath;
    blockObj.initVideos;
    if isempty(blockObj.Cameras)
        disp('did not find videos')
        return
    end
    [blockObj.Cameras(1).Meta.CameraID] = deal('Ang');
    [blockObj.Cameras(2).Meta.CameraID] = deal('Str');
    blockObj.linkTime; % was not linking time previously causing some issues, may or may not need
    blockObj.save % saving to the old block not the new
    status = copyfile(fullfile(path,[orig_blockID,'_Block.mat']),fullfile(path,[blockID '_Block.mat']));
else
    load(fullfile(path,[blockID '_Block.mat']));
end
%% Prevent overwriting files by using the dummy block
bl_new = blockObj;
load(fullfile(path,[orig_blockID '_Block.mat']));
%% Load variables
nVideos = size(blockObj.Cameras(1).Meta,2);
fps = 120;  
%% Load cameras and extract signal
cam = blockObj.Cameras(:); 
cam1 = blockObj.Cameras(1); 
% run section or set breakpoint here to manually adjust video
% cam1.showThumb; pulls up video
% cam1.setActive(true); allows you to manipulate the video
% cam1.seek(10e3); jumps to frame closest to ms value
%% Plot to view
if set_events == 1
    %% Extract signal
    sig = cam.extractSignal;

    Time=1:length(sig);
    Time=Time/fps;

    ax = axes(figure);
    plot(ax,Time,sig);
    hold(ax,'on')
    plot(ax,Time(1:end-1),diff(sig));

    th = quantile(abs(diff(sig)),0.996);
    plot(ax,[0 Time(end)],[th th],'--g');
    plot(ax,[0 Time(end)],-[th th],'--g');
    th = quantile(abs(diff(sig)),0.997);
    plot(ax,[0 Time(end)],[th th],'--g');
    plot(ax,[0 Time(end)],-[th th],'--g');
    th = quantile(abs(diff(sig)),0.998);
    plot(ax,[0 Time(end)],[th th],'--g');
    plot(ax,[0 Time(end)],-[th th],'--g');

    %% Input hold times and threshold
    Onset_s = 0;
    Offset_s = 4100;
    Offset_s = Time(end)-Offset_s;
    Thresh = 1.35;
    Method = 'Thresh';
    %% Find events
    [TrialStart,TrialEnd] = parseTrialsFromVideoLEDsignal(sig,fps,Method,Thresh,Onset_s,Offset_s);

    if not(numel(TrialEnd) == numel(TrialStart))
        warning('Start events must match end events');
    end
    %% Replot
    PlotEvents(sig,TrialStart,TrialEnd,fps)
    %% Create event structure
    Evt = struct('Ts',[],...
        'Tag',[],...
        'Name',[],...
        'Duration',[],...
        'Data',[],...
        'Trial',[]...
        );
    TrialStartEvt = repmat(Evt,1,numel(TrialStart));
    TrialEndEvt = repmat(Evt,1,numel(TrialEnd));

    [TrialEndEvt.Tag] = deal('ETrial');
    [TrialEndEvt.Name] = deal('EndTrial');                                      % This needs to match what you have in bl.Pars.Event.EvtNames
    [TrialEndEvt.Duration] = deal(1);
    [TrialEndEvt.Data] = deal({});
    [TrialEndEvt.Trial] = deal(nan);

    [TrialStartEvt.Tag] = deal('BTrial');
    [TrialStartEvt.Name] = deal('BeginTrial');                                      % This needs to match what you have in bl.Pars.Event.EvtNames
    [TrialStartEvt.Duration] = deal(1);
    [TrialStartEvt.Data] = deal({});
    [TrialStartEvt.Trial] = deal(nan);

    for ee=1:numel(TrialStart)
        TrialEndEvt(ee).Ts      = TrialEnd(ee);
        TrialStartEvt(ee).Ts    = TrialStart(ee);
    end

    blockObj.addEvent([TrialStartEvt TrialEndEvt]);

    blockObj.save;
elseif set_events == 0
    TrialStartEvt = struct('Ts',1,'Tag','BTrial','Name','BeginTrial','Duration',1,'Data',{1},'Trial',nan);
    TrialEndEvt = struct('Ts',5,'Tag','ETrial','Name','EndTrial','Duration',1,'Data',{1},'Trial',nan);
    blockObj.addEvent([TrialStartEvt TrialEndEvt]);
    blockObj.save;
end
%% Open vidscorer and score video
nigeLab.libs.VidScorer(blockObj.Cameras);
%% Open vidscorer and score video
L = struct2table(blockObj.Events);
fail = sum(strcmpi(L.Name,'Fail'));
success = (sum(strcmpi(L.Name,'Grasp')))+(sum(strcmpi(L.Name,'NonStereotyped')));
tot = sum(L.Trial == 1);
perc = success/tot;
%% Saves the default block with the set events/labels into the new block
blockObj.save;
status = copyfile(fullfile(path,orig_blockID),fullfile(path,blockID));
status = copyfile(fullfile(path,[orig_blockID '_Block.mat']),fullfile(path,[blockID '_Block.mat']));
status = copyfile(fullfile(path,[orig_blockID '_Pars.mat']),fullfile(path,[blockID '_Pars.mat']));
%% Helper function to find trial events
function [TrialStart,TrialEnd] = parseTrialsFromVideoLEDsignal(sig,fps,Method,th,VideoOffsetStart,VideoOffsetEnd)
% Example of function used to parse trials from videos.
% At the end of the day we just need an array with trial starting time and
% another array with trial ending time in seconds

% Method 'Diff' or 'Thresh'

if nargin <2
    error('Not enough input arguments');
elseif nargin<3
    Method='Diff';
    th=0.998;
    VideoOffsetStart = 50;    %[seconds] Beginning of video to skip for detection
    VideoOffsetEnd   = 0;     %[seconds] Final part of video to skip for detection
elseif nargin<4
    if strcmp(Method,'Thresh')
        th=0.7;
    elseif strcmp(Method,'Diff')
        th=0.998;
    end
    VideoOffsetStart = 50;    %[seconds] Beginning of video to skip for detection
    VideoOffsetEnd   = 0;     %[seconds] Final part of video to skip for detection
elseif nargin<5
    VideoOffsetStart = 50;    %[seconds] Beginning of video to skip for detection
    VideoOffsetEnd   = 0;     %[seconds] Final part of video to skip for detection                                                                            % the usual digital signal, but might work.
elseif nargin<6
    VideoOffsetEnd   = 0;     %[seconds] Final part of video to skip for detection                                                                            % the usual digital signal, but might work.
end

sigDiff = diff(sig);

sigDiff(1: round(VideoOffsetStart*fps) )   = nan;
sigDiff(round(end-VideoOffsetEnd*fps):end) = nan;

if strcmp(Method,'Diff')
    th = quantile(abs(sigDiff),th);

    TrialStart = sigDiff > th;
    TrialStart = find(xor(TrialStart(1:end-1),TrialStart(2:end)));
    TrialEnd = sigDiff < -th;
    TrialEnd = find(xor(TrialEnd(1:end-1),TrialEnd(2:end)));

    TrialStart = TrialStart(1:2:end);
    TrialEnd = TrialEnd(2:2:end);

elseif strcmp(Method,'Thresh')
    sigThresh=sig;
    sigThresh(1: round(VideoOffsetStart*fps) )   = nan;
    sigThresh(round(end-VideoOffsetEnd*fps):end) = nan;

    sigThresh=sigThresh > th;

    TrialStart=find(diff(sigThresh)>0);
    TrialEnd=find(diff(sigThresh)<0);
end



% Sanity check
ax = axes(figure);
plot(ax,sig);
hold(ax,'on')
plot(ax,diff(sig));

plot(ax,TrialStart,sigDiff(TrialStart),'r*');
plot(ax,TrialEnd,sigDiff(TrialEnd),'r*');

plot(ax,[0 numel(sigDiff)],[th th],'--g');
if strcmp(Method,'Diff')
    plot(ax,[0 numel(sigDiff)],-[th th],'--g');
end
yl = ax.YLim;

plot(ones(1,2)*VideoOffsetStart*fps,yl,'--r');
plot(numel(sigDiff)-ones(1,2)*VideoOffsetEnd*fps,yl,'--r');


TrialStart = TrialStart./fps;
TrialEnd = TrialEnd./fps;

end

%% Helper Function to Add Event
function [Events] = AddEvent(Events,Event2Add)
ind2add=find(Events>Event2Add,1,'first');

Events=[Events(1:ind2add-1) Event2Add Events(ind2add:end)];

end

%% Helper Function to Remove Event
function [Events] = RemoveEvent(Events,Event2Remove)

ind2remove=find(Events==Event2Remove);

Events(ind2remove)=[];
end

%% Helper Function to Plot
function PlotEvents(sig,TrialStart,TrialEnd,fps)
% Sanity check
ax = axes(figure);
plot(ax,(1:length(sig))/fps,sig);
hold(ax,'on')
plot(ax,(1:length(sig)-1)/fps,diff(sig));

plot(ax,TrialStart,sig(round(TrialStart*fps)),'g*');
plot(ax,TrialEnd,sig(round(TrialEnd*fps)),'r*');

plot(ax,TrialStart,0.2*ones(size(TrialStart)),'r*');
plot(ax,TrialEnd,-0.2*ones(size(TrialEnd)),'r*');
end