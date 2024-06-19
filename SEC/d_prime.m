%% Run d-prime
function d = d_prime(rawD,time_win,blank,bin_sz,fs)
% takes raw spiking data for every stimulation trial on a channel and
% compares the signal distribution to a baseline set as the equivalent
% period prior to stimulation
%
% INPUT: 
% rawD; a matrix of spike times for every stimulation trial in samples
% time_win; the length of time in ms to be assessed
% blank; the length of the artifactual blanking period in ms
% bin_sz; the length of time in ms represented by every bin
% fs; the recorded sample rate 
%
% OUTPUT:
% d; the d-prime value for the signal vs. the baseline

% set-up signal/artifactual windowing
t_sig = zeros(1,200/bin_sz);
t_base = zeros(1,200/bin_sz);
t_sz = time_win(2)/bin_sz; % number of bins in the time window
t_win = ones(t_sz,1); % creates a logical index for the number of bins within the time window
t_win(1:ceil(blank/bin_sz)) = 0; % disregards any bins with artifactual blanking
t_sig(1:t_sz) = t_win; % indexes bins to be included
t_base(end-t_sz+1:end) = t_win;

% derive standardized rates
binD = bin_data(rawD,bin_sz,fs); % bins data based on bin_sz
ifrD = smoothdata(binD./bin_sz,2,'gaussian',10); % smooths using a gaussian kernel after converting to ifr
% ifrD = ifrD - mean(ifrD,2);
base = ifrD(:,logical(t_base)); % extracts window
sig = ifrD(:,logical(t_sig)); % extracts window

% run d-prime
m_base = mean(base);
m_sig = mean(sig);
var_base = var(m_base,0,2);
var_sig = var(m_sig,0,2);
mu_base = mean(m_base,2);
mu_sig = mean(m_sig,2);
d = abs((mu_sig - mu_base)./sqrt(0.5*((var_sig) + (var_base))));