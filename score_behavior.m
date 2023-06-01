%% Scoring skilled reach pellet task
% wip
E = blockObj.Events;
evID = 'GraspStarted';
idx = strcmp([E.Name],evID);
s = E(idx);
evID = 'AttemptStarted';
idx = strcmp([E.('Name')],{evID});
f = E(idx);
success = numel(s);
fail = numel(f);
total = success./(fail + success);
disp(total);