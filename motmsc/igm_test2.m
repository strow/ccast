%
% igm_test1 - kcarta radiance to undecimated CrIS interferograms
%

% sample kcarta data
% kcfile = '/home/motteler/cris/sergio/JUNK2012/convolved_kcarta25.mat';
kcfile = '/home/motteler/cris/sergio/JUNK2012/convolved_kcarta13.mat';
d1 = load(kcfile);

% band 1 undecimated params
% note that opd and dv are the same as the regular band 1 values
df = 1;
npts = 20736;           % full undecimated IGM size
wlaser = 773.1301;      % recent real wlaser value
vlaser = 1e7 / wlaser;  % laser frequency
dx  = df / vlaser;      % undecimated distance step
opd = dx * npts / 2;    % max OPD
dv  = 1 / (2*opd);      % frequency step

% kcarta params
dvk  = 0.0025;
% Lmax = 1 / (2*dvk);
% Lpts = ceil(Lmax/dx);

% adjusted common params
Vmax = 1 / (2*dx);
N2 = round(Vmax/dvk);
V2 = N2 * dvk;
dx2 = 1/(2*V2);
% opd2 = dx2 * N2;
% dv2 = 1 / (2*opd2);
vlaser2 = df / dx2;
wlaser2 = 1e7 / vlaser2;

% get instrument and user grid params for adjusted wlaser
band = 'LW';
[inst, user] = inst_params(band, wlaser2);

% embed kcarta radiance in 0 to Vmax N2+1 point grid
frq2 = (0:N2)' * dvk;
rad2 = zeros(N2+1, 1);
% ix = interp1(frq2, (0:N2)', d1.w, 'nearest');
% rad2(ix) = d1.r;

iy = find(650 <= d1.w & d1.w <=1095);
vtmp =  d1.w(iy);	
rtmp =  d1.r(iy);	
ix = interp1(frq2, (0:N2)', vtmp, 'nearest');
rad2(ix) = rtmp;

% do the N2+1 point cosine transform (as a 2*N2 point FFT)
% igm1 = real(ifft([rad2; rad2(N2:-1:2,1)]));
igm1 = real(ifft([rad2; flipud(rad2(2:N2,1))]));

%---------------------
% reference transform
%---------------------
% specify n to trim the calculated one-sided interferogram and
% transform back to radiance.  This is the usual interferometric
% interpolation as done in finterp or fconvkc
%
% n = floor(npts/2);
N3 = round(inst.opd / dx2);
rad3 = real(fft([igm1(1:N3+1,1); flipud(igm1(2:N3,1))]));
frq3 = (0:N3)' * inst.dv;
ix = interp1(frq3, (0:N3)', inst.freq, 'nearest');
rad3 = rad3(ix);
frq3 = frq3(ix);

figure(1); clf
plot(frq3, rad3)

%--------------------
% onboard processing
%--------------------
% specify n to trim the calculated one-sided interferogram, then
% construct an (almost) symmetric double sided interferogram with
% indices running [1,2,...,n,n+1,n,...,3,2].  Note that n*dx is the
% half-path distance but we need n+1 points from the single sided
% interferogram since we have valid data at offsets from 0 to n*dx.
%
n = floor(npts/2);
% igm2 = [igm1(n+1:-1:1,1); igm1(2:n,1)];
igm2 = [flipud(igm1(1:n+1,1)); igm1(2:n,1)];

% set up the corresponding distance grid
dtmp = (0:N2)' * dx2;
dgrid = [-dtmp(n+1:-1:1,1); dtmp(2:n,1)];

% plot the results
figure(2); clf
plot(dgrid, igm2)
title('simulated CrIS undecimated interferogram')
xlabel('cm')
ylabel('sensor count')
grid on; zoom on

% FIR filter goes here

% do the decimation
i = 0;
dind = (1:inst.npts)' * inst.df - i;
igm_dec = igm2(dind);
dgr_dec = dgrid(dind);

% instrument params
npts = inst.npts;
cind = inst.cind;

% fix tind so it mimics fftshift for odd-sized point sets
tind = [ceil(npts/2)+1 : npts, 1 : ceil(npts/2)]';

% initialize the output array
spec = zeros(npts);

% do an FFT of shifted data.
stmp = fft(igm_dec(tind));

% permute the spectra to match the frequency scale
spec = stmp(cind);

figure(3)
plot(inst.freq, abs(spec))

