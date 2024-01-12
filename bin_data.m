%% Combine elements of array to make a pseudo-histogram
function nM = bin_data(m,bin_size,fs)
% takes the total number of elements in an array and sums neighboring 
% elements together in bins
%
% INPUT: 
% m; array of data which must be a single dimension (i.e. 1xn) assuming
% each element is a sample 
% bin_size; time represented by each bin
% fs; sample rate of the data in samples/sec
%
% OUTPUT:
% nM; binned data

if size(m,2) < size(m,1)
    error('Data is formatted incorrectly');
end

sM = size(m,2);
ff = fs/1000; % convert to ms
nSamp = bin_size*ff; % number of samples in each bin
nBins = sM/nSamp; % total number of bins
bin_edges = [0 linspace(nSamp,sM,nBins)];
nM = zeros(1,nBins);
for i = 1:nBins
    deb = bin_edges(i) + 1;
    fin = bin_edges(i+1);
    nM(i) = sum(m(deb:fin));
end