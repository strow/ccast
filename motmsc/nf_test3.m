%
% nf_test3 --  undecimate and invert numeric filter
%
% the regression used here to invert tne numeric filter did not work

addpath ../davet
addpath ../source

% get sample interferogram data
rid = 'd20150401_t0712300';
rfile = ['/asl/data/cris/ccast/rdr60_hr/2015/091/RDR_', rid];
load(rfile);
eng = struct([]);
[sci, eng] = scipack(d1, eng);
wlaser = metlaser(eng.NeonCal);
[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);
clear d1

% select an interferogram
iFOV = 1;
ix = find(igmFOR == 15);
igm = igmLW(:, iFOV, ix(31));
clear igmLW igmMW igmSW 

% instrument params
band = 'LW';
opts = struct;
opts.resmode = 'hires2';
opts.addguard = 'true';
[inst, user] = inst_params(band, wlaser, opts);

% interpolate interferogram to undecimated grid
m = inst.npts * inst.df;
x = 1 : inst.df : m;
xi = 1 : m;
yi = interpft(igm, m);

figure(1); clf
plot(x, real(igm), xi, real(yi))
title('interpolated interferogram')
legend('original', 'interpolated')
grid on; zoom on

% freq domain filter
tfile = '../inst_data/FIR_19_Mar_2012.txt';
fNF = specNF(inst, tfile);
vNF = inst.freq;

% time domain filter
d2 = load(tfile);
switch upper(inst.band)
  case 'LW', filt = d2(:,1) + 1i * d2(:,2);
  case 'MW', filt = d2(:,3) + 1i * d2(:,4);
  case 'SW', filt = d2(:,5) + 1i * d2(:,6);
  otherwise, error(['bad band spec ', inst.band])
end

% time domain filter as a linear transform
n = inst.df * inst.npts;
k = length(filt);
Fd = zeros(k, 2*n);
Fi = zeros(k, 2*n);
Fj = zeros(k, 2*n);

for i = 1 : n
  j = 2 * (i - 1) + 1;

  Fd(:, j)   = real(filt);
  Fd(:, j+1) = imag(filt);

  Fi(:, j)   = ones(k, 1) * j; 
  Fi(:, j+1) = ones(k, 1) * (j+1);

  Fj(:, j)   = i + (0 : k-1);
  Fj(:, j+1) = i + (0 : k-1);

end

NF = sparse(Fi(:), Fj(:), Fd(:), 2*n, n + k - 1);

figure(2); clf
ix = 1:255;
plot(ix, real(filt), ix, imag(filt))
title('time domain FIR filter')
legend('real', 'imag')
grid on; zoom on

igm2 = [real(yi(:)), imag(yi)]';
igm2 = igm2(:);

igm3 = NF \ igm2;

figure(3)
plot(igm3)

