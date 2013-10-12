%
% high res comparisons
%   - old vs new high spectra
%   - eng packet vs old saved emissivity
%
% note: new high res has 
%   (1) correct cut point for all 3 bands
%   (2) non-linearity correction for band 1
%   (3) narrower wings for band 1 filter
%

band = 'SW';

addpath utils

% sdr = 'SDR_d20130827_t1823008.mat';
% sdr = 'SDR_d20130827_t1823008.mat';
  sdr = 'SDR_d20130827_t1911006.mat';

% old and new high res data
p1 = '/asl/data/cris/ccast/sdr60_old_hr2/2013/239/';
p2 = '/asl/data/cris/ccast/sdr60_hr2/2013/239/';        

f1 = fullfile(p1, sdr);
f2 = fullfile(p2, sdr);

d1 = load(f1);
d2 = load(f2);
d3 = load('../inst_data/emisvxHR.mat');

switch upper(band)
  case 'LW'
    v1 = d1.vLW; v2 = d2.vLW;
    r1 = squeeze(pcorr2(d1.rLW(:, 5, 15, 30)));
    r2 = squeeze(pcorr2(d2.rLW(:, 5, 15, 30)));
    e3 = d3.e1hi; iband = 1;
  case 'MW', 
    v1 = d1.vMW; v2 = d2.vMW;
    r1 = squeeze(pcorr2(d1.rMW(:, 5, 15, 30)));
    r2 = squeeze(pcorr2(d2.rMW(:, 5, 15, 30)));
    e3 = d3.e2hi; iband = 2;
  case 'SW', 
    v1 = d1.vSW; v2 = d2.vSW;
    r1 = squeeze(pcorr2(d1.rSW(:, 5, 15, 30)));
    r2 = squeeze(pcorr2(d2.rSW(:, 5, 15, 30)));
    e3 = d3.e3hi; iband = 3;
end

%-----------------
% compare spectra
%-----------------

[ix, jx] = seq_match(v1, v2);
v1 = v1(ix); v2 = v2(jx);
r1 = r1(ix); r2 = r2(jx);
b1 = real(rad2bt(v1, r1));
b2 = real(rad2bt(v2, r2));

figure(1); clf
subplot(2,1,1)
plot(v1, b1, v2, b2)
legend('old', 'new', 'location', 'best')
title(sprintf('%s high res spectra', upper(band)));
grid on; zoom on

subplot(2,1,2)
plot(v1, b1 - b2)
ax = axis; ax(3) = -0.5; ax(4) = 0.5; axis(ax);
legend('old - new', 'location', 'best')
grid on; zoom on

%--------------------
% compare emissivity
%--------------------

wtmp = 773.1301;
opt1.resmode = 'hires2';
[inst1, user1] = inst_params(band, wtmp, opt1);

e_ICT = d1.eng.ICT_Param.Band(iband).ICT.EffEmissivity.Pts;

if length(e_ICT) ~= length(inst1.freq)
  opt1.resmode = 'lowres';
  [inst2, user2] = inst_params(band, wtmp, opt1);

  if length(e_ICT) ~= length(inst2.freq)
    error('no frequency grid for eng packet emissivity')
  end

  e_ICT = interp1(inst2.freq, e_ICT, inst1.freq, 'linear', 'extrap');
end

figure(2); clf
subplot(2,1,1)
plot(inst1.freq, e3, inst1.freq, e_ICT)
title(sprintf('%s high res emissivity', upper(band)));
legend('old', 'new', 'location', 'best')
grid on; zoom on

subplot(2,1,2)
plot(inst1.freq, e3 - e_ICT)
legend('old - new', 'location', 'best')
grid on; zoom on

