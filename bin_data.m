%% Combine elements of array to make a pseudo-histogram
function nM = bin_data(m,bin_size,fs)
% takes the total number of elements in an array and sums neighboring 
% elements together in bins
%
% INPUT: 
% m; array of data assuming each columnar element is a sample 
% bin_size; time represented by each bin
% fs; sample rate of the data in samples/sec
%
% OUTPUT:
% nM; binned data

nR = size(m,1); % number of rows of data
sM = size(m,2);
ff = fs/1000; % convert to ms
nSamp = bin_size*ff; % number of samples in each bin
nBins = sM/nSamp; % total number of bins
bin_edges = [0 linspace(nSamp,sM,nBins)];
nM = zeros(nR,nBins);
for i = 1:nBins
    deb = bin_edges(i) + 1;
    fin = bin_edges(i+1);
    nM(:,i) = sum(m(:,deb:fin),2);
end
