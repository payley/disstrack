%% Load impedance table 
% load file
x1 = [1 2 3 4 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 0 1 2 3 4 5 1 2 3 4 ...
    8 9 10 11 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12 8 9 10 11];
x2 = x1 + 1;
x3 = x2;
x4 = x1;
y1 = [6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1 ...
    6 6 6 6 5 5 5 5 5 5 4 4 4 4 4 4 3 3 3 3 3 3 2 2 2 2 2 2 1 1 1 1];
y2 = y1;
y3 = y2 - 1;
y4 = y3;
xc = x1 + 0.1; % add value to shift left
yc = y1 - 0.5;
xAll = [x1; x2; x3; x4];
yAll = [y1; y2; y3; y4];
map = [0 1 0; 0.1 1 0; 0.2 1 0; 0.3 1 0; 0.4 1 0; 0.5 1 0; 0.6 1 0; 0.7 1 0; 0.8 1 0; 0.9 1 0; ...
    1 1 0; 1 0.9 0; 1 0.8 0; 1 0.7 0; 1 0.6 0; 1 0.5 0; 1 0.4 0; 1 0.3 0; 1 0.2 0; 1 0.1 0; ...
    1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0]; % color values
dat = size(impT,2);
reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 24 25 26 17 18 19 20 ...
        36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]; % uses index for the table3(ie ch# + 1)

% rearrange values to match array design and plot left to right
for i = 1:64
    idx = reArr(i);
    nimpT(i,:) = impT(idx,:);  
end
nimpT.Properties = impT.Properties;

if nimpT.Properties.CustomProperties.recOrientation == 'R'
    st = nimpT;
    st(1:32,:) = nimpT(33:64,:);
    st(33:64,:) = nimpT(1:32,:);
    nimpT = st;
    if nimpT.array(1) == 1
        return
    end
end

% plot impedance values as patches
for i = 3:dat
    c = table2array(nimpT(:,i));
    fc = c';
    figure('Position', [10 10 1000 475]);
    patch(xAll,yAll,fc);
    set(gca,'XColor','none','YColor','none')
    str = nimpT.Properties.VariableNames(i);
    title(strrep(str, '_', ' '));
    % add text to objects
    avg = c/1000000;
    label = string([1:64]');
% with standard deviations
%     s = ((i - 1)* 5);
%     std = H{:,s};
%     var = std/1000000;

%     for ii = 1:size(avg,1)
%         txt = "%0.2f +/- %0.1f";
%         label(ii) = sprintf(txt,avg(ii),var(ii));
%     end
% without standard deviations
    for ii = 1:size(avg,1)
      txt = "%0.2f";
      label(ii) = sprintf(txt,avg(ii));
    end
    label = char(label);
    text(xc,yc,label);
    colormap(map);
    colorbar;
    caxis ([10000 3000000]);
end

% plot avg impedances across frequencies 
% if dat > 2
%     for i = 2:dat
%         n = i - 1;
%         m(n) = mean(impT{:,i});
%     end
%     plot(m);
% end

clearvars -except impT nimpT H m