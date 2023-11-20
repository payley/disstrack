directory = pwd;
files = dir(directory);
files = files(~ismember({files.name},{'.','..'}),:);
all = cell(size(files,1),1);
spD = cell(size(files,1),1);
figure;
plot(data)
hold on
for i = 1:numel(files)
    load(files(i).name)
    h = zeros(numel(StimOnsets),6001);
    for ii = 1:numel(StimOnsets)
        h(ii,:) = peak_train(StimOnsets(ii):StimOnsets(ii)+6000);
    end
    all{i} = h;
    pt = find(peak_train);
    spD{i} = pt;
    scatter(pt,data(pt));
end
for i = 1:size(all,1)
figure;
plotSpikeRaster(logical(all{i}),'PlotType','vertline');
title(files(i).name,'Interpreter','none');
end