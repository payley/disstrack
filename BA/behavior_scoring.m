%% Get events
E = blockObj.Events;
E = E(~isnan([E.Trial]));
E = E(~isnan([E.Ts]));
E = E(contains([E.Name],'Grasp'));
%% Combine events
e = blockObj.Events;
e = e(~isnan([e.Trial]));
e = e(~isnan([e.Ts]));
e = e(contains([e.Name],'Grasp'));
E = [E e];
%% Calculate score
tot = size(E,2);
success = sum(contains([E.Name],'GraspStarted'));
nonstereotyped = sum(contains([E.Name],'GraspStarted_NS'));
fail = sum(contains([E.Name],'GraspAttempted'));
perc = success/(success + fail);   
firstsuccess = success - nonstereotyped;