%% algorithms for cleaning stim artifacts from data
function [data,tAfter_ms,PeakedDelay,FalloffDelay] = stim_artifact_removal_algorithm(data,algorithm,fs,StimOnsets,StimOffsets,...
    tBefore,tAfter,meth,polyOrder)
% utilized in the second step of processing stim-evoked activity assays
% uses algorithms made by David Bundy and Francesco Negri

% INPUT:
% data; raw data stream
% algorithm; case for algorithm to be run
% fs; sample rate
% StimOffsets; string of stim onset times extracted from the data
% StimOffsets; string of stim offset times extracted from the data
% tBefore; the default time before the stimulation that is blanked
% tAfter; the default minimum time after the stimulation that is blanked
% meth; the method of fitting
% polyOrder; polynomial order for fitting
%
% OUTPUT:
% data; cleaned data with no artifacts
% tAfter_ms; blanking time after stimulus
% PeakedDelay; blanking period determined by first method
% FalloffDelay; blanking period determined by second method

switch algorithm
    case 'Bundy'
        % set up parameters
        fs = fs; % sample rate

        % Voltage limits
        uint16lim = [0 65535];
        Vlim = 0.195*(uint16lim-32768);
        VmaxAbs = max(abs(Vlim));
        VmaxThresh = 0.99*VmaxAbs;

        % Timing for blanking search
        Pre_ms = -5;
        Post_ms = 50;
        Pre_samp = floor(fs*Pre_ms/1000); % sample correlating to time before stim
        Post_samp = ceil(fs*Post_ms/1000); % sample correlating to time after stim

        % Put data immediately after stimulus into variable to find blanking time
        RawTimeCourse = [];
        for curstim = 1:length(StimOffsets)
            curSampStart = StimOffsets(curstim) + Pre_samp;
            curSampEnd = StimOffsets(curstim) + Post_samp;
            RawTimeCourse = vertcat(RawTimeCourse,data(curSampStart:curSampEnd));
        end
        PlotTime = Pre_ms(1):1000/fs:Post_ms(end);

        % Find fall-off delay
        thresh = rms(abs(diff(diff(mean(RawTimeCourse,1)))));
        FalloffDelay = PlotTime(find(abs(diff(diff(mean(RawTimeCourse,1))))>thresh,1,'last'));

        % Find time that signal is peaked after stimulus pulse
        if max(abs(data)) >= VmaxThresh
            %PeakedDelay=PlotTime(find(abs(mean(RawTimeCourse,1))>=VmaxThresh,1,'last'));
            PeakedDelay = PlotTime(find(max(abs(RawTimeCourse),[],1)>VmaxThresh,1,'last'));
        else
            PeakedDelay = 0;
        end
        if isempty(PeakedDelay)
            PeakedDelay = 0;
        end

        % Determine delay to use (maximum of arbitrary minimum blanking
        % period, fall-off slowing, and peaked period ending
        MaxDelay = max(FalloffDelay,PeakedDelay);

        if MaxDelay <= (tAfter-0.25)
            tAfter_ms = tAfter;
        else
            tAfter_ms = MaxDelay + 0.25;
        end

        % Determine smoothing times/samples
        tBefore_s = ceil(tBefore*fs/1000);
        tAfter_s = ceil(tAfter_ms*fs/1000);

        numInterStimSamps = median(StimOffsets(2:end)-StimOffsets(1:end-1));
        UnusableSamps = (-1*tBefore_s):tAfter_s;
        numUnusableSamps = length(UnusableSamps);
        numSmoothSamps = numInterStimSamps - numUnusableSamps;
        % SmoothSamps=1:numSmoothSamps;

        % Detrend pre-stim period
        PreEnd = StimOffsets(1) - tBefore_s;
        if strcmp(meth,'Poly')
            data(1:PreEnd) = detrend(data(1:PreEnd));
        elseif strcmp(meth,'SlidingPoly')
            data(1:PreEnd) = SlidingPolySmooth(data(1:PreEnd),polyOrder,6*fs/1000+1);
        end
        FitData = zeros(size(data));

        % Smooth each stimulus pulse and
        for curStim = 1:length(StimOffsets)
            % Get samples
            InterpSamps = StimOffsets(curStim) + UnusableSamps;
            StartSamp = StimOffsets(curStim) + tAfter_s;
            if curStim == length(StimOffsets)
                EndSamp = StimOffsets(curStim) + tAfter_s + numSmoothSamps;
            else
                EndSamp = StimOffsets(curStim+1) - tBefore_s;
            end
            curSamps = StartSamp:EndSamp;
            SmoothSamps = 1:length(curSamps);
            curData = data(curSamps);

            % Fit polynomial and subtract
            if strcmp(meth,'Poly')
                [data(curSamps),FitData(curSamps)] = PolySmooth(curData,polyOrder);
            elseif strcmp(meth,'SlidingPoly')
                [data(curSamps),FitData(curSamps)] = SlidingPolySmooth(curData,polyOrder,6*fs/1000+1);
            end

            %interpolate over unusable samps
            RefSamps=[InterpSamps(1) InterpSamps(end)];
            data(InterpSamps) = interp1(RefSamps,data(RefSamps),InterpSamps);
        end

        % Detrend post-stim period
        PostStart = StimOffsets(end) + tAfter_s + numSmoothSamps + 1;
        if strcmp(meth,'Poly')
            data(PostStart:end) = detrend(data(PostStart:end));
        elseif strcmp(meth,'SlidingPoly')
            data(PostStart:end) = SlidingPolySmooth(data(PostStart:end),polyOrder,6*fs/1000+1);
        end

        % For debugging
        %figure;
        %Time=1:length(data);
        %Time=1000*Time/fs;
        %ax1=subplot(2,1,1);plot(Time,data,'b');
        %ax2=subplot(2,1,2);plot(Time,InData.data,'r');hold on;plot(Time,FitData,'b');legend('Raw Data','Artifact Fit');
        %linkaxes([ax1 ax2],'x');

        output = data;

    case 'Fra'
        sig = data;
        p = struct('fs',fs,'StimI',StimOnsets);
        output = logssar(sig, p.StimI, p.fs, 1e-3);
end
end

    function [OutData,FitData] = PolySmooth(curSmoothData,Order)
        SmoothSamps = 1:length(curSmoothData);
        if size(SmoothSamps(1)) ~= size(curSmoothData,1)
            SmoothSamps = SmoothSamps';
        end
        [p,S,mu] = polyfit(SmoothSamps,curSmoothData,Order);
        FitData = polyval(p,SmoothSamps,[],mu);
        OutData = curSmoothData - FitData;
    end

    function [OutData,FitData] = SlidingPolySmooth(curSmoothData,Order,Span)
        FitData = smooth(curSmoothData,ceil(Span),'sgolay',Order);
        [p,S,mu] = polyfit(1:Span,curSmoothData(1:Span),Order);
        FitData(1:ceil(Span/2)) = polyval(p,1:ceil(Span/2),[],mu);
        [p,S,mu] = polyfit(1:Span,curSmoothData(end-(Span-1):end),Order);
        FitData(end-ceil(Span/2)+1:end) = polyval(p,ceil(Span/2):Span,[],mu);
        if size(curSmoothData,1) ~= size(FitData,1)
            FitData=FitData';
        end
        OutData = curSmoothData - FitData;
    end
