%% Intiate channel level stats using shuffled method 
function run_sig_rndBlanked_chLevel(DataStructure,idxA,idxD,useCAR,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms)
% last step in processing stim-evoked activity assays, shell for assigning
% to clusters
% primary contributor David Bundy with some adaptations made by Page Hayley

% INPUT: 
% DataStructure; a structure of the stimulation assay blocks organized by animal  
% idxA; index/indices for the animals to be run
% idxD; index/indices for the dates to be run
% useCAR; a logical for using CAR data
% useCluster; a logical for using the clusters for analysis
% smoothBW_ms; smoothing characteristic
% NResamp; number of repetitions of shuffled data where the precedent is 10,000
% MaxLatency_ms; sets upper limit for trial length
% DSms; sample frequency
%
% OUTPUT:
% saves stats in the block organization

if useCluster == 0
    setup_sig_rndBlanked_chLevel(DataStructure,idxA,idxD,useCAR,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms);
else
    CLUSTER_LIST = {'CPLMJS'};%{'CPLMJS';'CPLMJS2'; 'CPLMJS3'}; % MJS cluster profiles
    NWR = [1 16];              % Number of workers to use
    WAIT_TIME = 15;           % Wait time for looping if using findGoodCluster
    INIT_TIME = 2;            % Wait time for initializing findGoodCluster
    
    IN_ARGS = {DataStructure,idxA,idxD,useCAR,useCluster,smoothBW_ms,NResamp,MaxLatency_ms,DSms};
    
    ATTACHEDFILES = ...
        matlab.codetools.requiredFilesAndProducts('setup_sig_rndBlanked_chLevel.m');
    
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
    
    createTask(myJob,@setup_sig_rndBlanked_chLevel,0,IN_ARGS);
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

disp('Step complete');