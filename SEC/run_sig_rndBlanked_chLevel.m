UseCluster = 1;
%UseCluster=0;
UseCAR = 0;
SmoothBW_ms = 0.2;

load('SEC_DataStructure.mat');
if UseCluster == 0
    Calc_ChannelSpikeTriggeredStats_RatConnectivity_RandomBlanked(DataStructure,0,SmoothBW_ms,UseCAR);
else
    CLUSTER_LIST = {'CPLMJS'};%{'CPLMJS';'CPLMJS2'; 'CPLMJS3'}; % MJS cluster profiles
    NWR = [1 16];              % Number of workers to use
    WAIT_TIME = 15;           % Wait time for looping if using findGoodCluster
    INIT_TIME = 2;            % Wait time for initializing findGoodCluster
    
    IN_ARGS = {DataStructure,1,SmoothBW_ms,UseCAR};
    
    ATTACHEDFILES = ...
        matlab.codetools.requiredFilesAndProducts('Calc_ChannelSpikeTriggeredStats_RatConnectivity_RandomBlanked.m');
    
    fprintf(1,'Searching for Idle Workers...');
    CLUSTER = findGoodCluster('CLUSTER_LIST',CLUSTER_LIST,...
        'NWR',NWR, ...
        'WAIT_TIME',WAIT_TIME, ...
        'INIT_TIME',INIT_TIME);
    fprintf(1,'Beating them into submission...');
    
    myCluster = parcluster(CLUSTER);
    myJob     = createCommunicatingJob(myCluster, ...
        'AttachedFiles', ATTACHEDFILES, ...
        'Name', ['Stim Triggered Global Stats'], ...
        'NumWorkersRange', NWR, ...
        'FinishedFcn', @JobFinishedAlert, ...
        'Type','pool', ...
        'Tag', ['Queued: Global Stimulus triggered stats']);
    
    createTask(myJob,@Calc_ChannelSpikeTriggeredStats_RatConnectivity_RandomBlanked,0,IN_ARGS);
    fprintf(1,'complete. Submitting to %s...\n',CLUSTER);
    submit(myJob);
    fprintf(1,'\n\n\n----------------------------------------------\n\n');
    wait(myJob, 'queued');
    fprintf(1,'Queued job:  Window Stim Triggered Stats\n');
    fprintf(1,'\n');
    wait(myJob, 'running');
    fprintf(1,'\n');
    fprintf(1,'->\tJob running.\n');
    pause(90); % Needs about 1 minute to register all worker assignments.
    fprintf(1,'Using Server: %s\n->\t %d/%d workers assigned.\n', ...
        CLUSTER,...
        myCluster.NumBusyWorkers, myCluster.NumWorkers);
    
end
