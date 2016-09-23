%
% NAME
%   kc2resp3 - convolve kcarta to CrIS responsivity
%
% SYNOPSIS
%   [rad2, frq2] = kc2resp(user, rad1, frq1, dvL, dvM)
%
% INPUTS
%   user  - CrIS user grid params
%   rad1  - kcarta radiances, m x n array
%   frq1  - kcarta frequencies, m-vector
%   dvL   - first stage (low or source) dv
%   dvM   - second stage (intermediate) dv
%
% OUTPUTS
%   rad2  - CrIS radiances, k x n array
%   frq2  - CrIS frequency grid, k-vector
%
% DISCUSSION
%   derived from kc2cris, under development
%   loads resp_filt.mat on the current path
%
% HM, 26 Apr 2015
%

function [rad2, frq2] = kc2resp(user, rad1, frq1, dvL, dvM)

% check that array sizes match
frq1 = frq1(:);
[m, nobs] = size(rad1);
if m ~= length(frq1)
  error('rad1 and frq1 sizes do not match')
end

% this should work if resp_file is with kc2resp.m
load resp_filt

switch upper(user.band)
 case 'LW', resp_filt = filt_lw; resp_freq = freq_lw;
 case 'MW', resp_filt = filt_mw; resp_freq = freq_mw;
 case 'SW', resp_filt = filt_sw; resp_freq = freq_sw;
end

% filter limits define the band span
fv1 = resp_freq(1);     bv1 = fv1 - 20; 
fv2 = resp_freq(end);   bv2 = fv2 + 20;
ix = find(bv1 <= frq1 & frq1 <= bv2);
rad1 = rad1(ix, :);
frq1 = frq1(ix);

% down and up interpolate
rad1 = bandpass(frq1, rad1, fv1, fv2, 20, 20);
[rad2, frq2] = finterp(rad1, frq1, dvL);
[rad3, frq3] = finterp(rad2, frq2, dvM);
 
% regular kc2resp w/ frq3
ix = find(fv1 <= frq3 & frq3 <= fv2);
rad3 = rad3(ix, :);
frq3 = frq3(ix);

% interpolate the filter to the kcarta grid
kc_filt = interp1(resp_freq, resp_filt, frq3, 'spline');
kc_filt = kc_filt * ones(1, nobs);

% apply the filter
rad3 = rad3 .* kc_filt;
clear kcfilt rad1 frq1 rad2 frq2

%-----------------------------------
% set up interferometric parameters
%-----------------------------------

% CrIS params
v1 = user.v1;         % user grid start
v2 = user.v2;         % user grid end
dv2 = user.dv;        % user grid dv
vb = fv2;             % transform max

% get rational approx to dvM/dv2
[m1, m2] = rat(dvM/dv2);
if ~isclose(m1/m2, dvM/dv2, 4)
  error('no rational approximation for dvM / dv2')
end

% get the tranform sizes
for k = 4 : 24
  if m2 * 2^k * dvM >= vb, break, end
end
N1 = m2 * 2^k;
N2 = m1 * 2^k;

% get (and check) dx
dx1 = 1 / (2*dvM*N1);
dx2 = 1 / (2*dv2*N2);
if ~isclose(dx1, dx2, 4)
  error('dx1 and dx2 are different')
end
dx = dx1;

% fprintf(1, 'kc2cris: N1 = %7d, N2 = %5d, dx = %6.3e\n', N1, N2, dx);

%-------------------------------
% take kcarta to CrIS radiances
%-------------------------------

% embed kcarta radiance in a 0 to Vmax grid
ftmp = (0:N1)' * dvM;
rtmp = zeros(N1+1, nobs);
[ix, jx] = seq_match(ftmp, frq3);
rtmp(ix, :) = rad3(jx, :);

% radiance to interferogram
igm1 = real(ifft([rtmp; flipud(rtmp(2:N1, :))]));
igm1 = igm1(1:N1+1, :);

% apply a time-domain apodization
% dtmp = (0:N2)' * dx;
% apod = gaussapod(dtmp, 2) * ones(1, nobs);
% igm1(1:N2+1, :) = igm1(1:N2+1, :) .* apod;

% interferogram to radiance
rad2 = real(fft([igm1(1:N2+1,:); flipud(igm1(2:N2,:))]));
frq2 = (0:N2)' * dv2;

% return the user grid plus any guard channels
ix = find(v1 <= frq2 & frq2 <= v2);
rad2 = rad2(ix, :);
frq2 = frq2(ix);

% interpolate the filter to the user grid
user_filt = interp1(resp_freq, resp_filt, frq2, 'spline');
user_filt = user_filt * ones(1, nobs);

% apply the inverse filter
rad2 = rad2 ./ user_filt;

