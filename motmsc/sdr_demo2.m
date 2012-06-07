
% find scan index to minimizes IDPS and bcast SDR difference
%
% conclusion: ds = 4 gives best match
% (that is, adding 4 to the IDPS scan index gives the best match 
%  with the RDR data)


addpath /home/motteler/cris/bcast/asl

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

% load a bcast SDR file
load /home/motteler/cris/data/2012/128/SDR_d20120507_t0207314.mat

% select a bcast scan index
bi = 43;

% get the corresponding IDPS SDR file time and scan index
gid = geo.sdr_gid(bi, :);
si = geo.sdr_ind(bi, :);  

% get the IDPS SDR path and filename
sdir = '/asl/data/cris/sdr60/hdf/2012/128';
slist = dir(fullfile(sdir, ['SCRIS_npp_', gid, '*.h5']));
sfile = fullfile(sdir, slist(end).name);

% read the IDPS SDR file
pd = readsdr_rawpd(sfile);

% --------
% LW tests
% --------

j = 9;   % select a FOV
k = 1;  % select a FOR

dmin = 1000;
for i = -10 : 10

  ds = i;  % scan index delta

  % bcast spectra
  x1 = vLW;
  y1 = real(rad2bt(x1, rLW(:, j, k, bi)));

  % IDPS spectra
  x2 = wn_lw;
  y2 = real(rad2bt(x2, pd.ES_RealLW(:, j, k, si + ds)));

  % match frequency grids (IDPS is a subset of bcast)
  ix = interp1(x1, 1:length(x1), x2, 'nearest');
  x1 = x1(ix);
  y1 = y1(ix);

  dd = rms(y2 - y1);
  if dd < dmin, 
    dmin = dd; 
    imin = i;
  end
end
[imin, dmin]

return

% comparison plot
figure (1)
plot(x1, y1, x2, y2)
title('bcast and IDPS spectra')
legend('bcast', 'IDPS', 'location', 'best')
grid
zoom on

% ----------------
% SW fitting tests
% -----------------

j = 5;   % select a FOV
k = 15;  % select a FOR

% bcast spectra
x1 = vSW;
y1 = real(rad2bt(x1, rSW(:, j, k, bi)));

% IDPS spectra
x2 = wn_sw;
y2 = real(rad2bt(x2, pd.ES_RealSW(:, j, k, si + ds)));

% match frequency grids (IDPS is a subset of bcast)
ix = interp1(x1, 1:length(x1), x2, 'nearest');
x1 = x1(ix);
y1 = y1(ix);

rms(y2 - y1)

% comparison plot
figure (2)
plot(x1, y1, x2, y2)
title('bcast and IDPS spectra')
legend('bcast', 'IDPS', 'location', 'best')
grid
zoom on

