
function [rout,apod] = weaksine(rin,frac_sine);

%%
%% function [rout,apod] = weaksine(rin,frac_sine);
%%
%% Apply sine (aka cosine) apodization to an input spectrum.
%%
%% Inputs:
%%  rin:        Nx1 vector of input radiances
%%  frac_sine:  Fraction of N where sine/cosine apodization is
%%              applied.  I.e. In the interferogram point index
%%              domain, apod = 1 for i = 1:N*frac_sine and equals
%%              half a cosine wave from N*frac_sine to N.  Should
%%              be >0 and <1.
%% Outputs:
%%  rout:       Nx1 vector of apodized radiances
%%  apod:       Nx1 vector of the weak-sine apodization function
%%
%% DCT, 01 Oct 2013
%% 

%% Number of points in input spetrum
N = length(rin);

%% Compute apodization function
apod = ones(N,1);
i = (1:N)';
ind = find(i >= N*(1-frac_sine));
ind = (ind(1)-1:ind(end))';
apod(ind) = 0.5 + 0.5*cos((ind-ind(1))/N/frac_sine*pi);

%% Butterfly
rin2 = [rin(1:end);flipud(rin(2:end-1))];
apod2 = [apod(1:end);flipud(apod(2:end-1))];

%% Compute Interferogram, apodization, inverse FFT, and extract
%% first half
%rout2 = ifft(fft(rin2));
%rout = rout2(1:N);
rout2 = ifft(fft(rin2).*apod2);
rout = rout2(1:N);

