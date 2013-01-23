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
npts = 20736;
wlaser = 773.1301;
vlaser = 1e7 / wlaser;  % laser frequency
dx  = df / vlaser;      % distance step
opd = dx * npts / 2;    % max OPD
dv  = 1 / (2*opd);      % frequency step

% kcarta params
dvk  = 0.0025;
Lmax = 1 / (2*dvk);
Lpts = ceil(Lmax/dx);

% adjusted common params
Vmax = 1 / (2*dx);
N2 = round(Vmax/dvk);
V2 = N2 * dvk;
dx2 = 1/(2*V2);
opd2 = dx2 * N2;
dv2 = 1 / (2*opd2);
vlaser2 = df / dx2;
wlaser2 = 1e7 / vlaser2;

% embed kcarta radiance in 0 to Vmax grid
frq2 = (0:N2)' * dvk;
rad2 = zeros(N2+1, 1);
ix = interp1(frq2, (0:N2)', d1.w, 'nearest');
rad2(ix) = d1.r;

% do the cosine transform
igm1 = real(ifft([rad2; rad2(N2:-1:2,1)]));
igmx = real(ifft([rad2; flipud(rad2(2:N2,1))]));

% specify n to trim the calculated one-sided interferogram, then
% construct an (almost) symmetric double sided interferogram with
% indices running [1,2,...,n,n+1,n,...,3,2].  Note that n*dx is the
% half-path distance but we need n+1 points from the single sided
% interferogram since we have valid data at offsets from 0 to n*dx.
%
n = floor(npts/2);
igm2 = [igm1(n+1:-1:1,1); igm1(2:n,1)];

% set up the corresponding distance grid
dtmp = (0:N2)' * dx2;
dgrid = [-dtmp(n+1:-1:1,1); dtmp(2:n,1)];

% plot the results
figure(1); clf
plot(dgrid, igm2)
title('simulated CrIS undecimated interferogram')
xlabel('cm')
ylabel('sensor count')
grid on; zoom on

