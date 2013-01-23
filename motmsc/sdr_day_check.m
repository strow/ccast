
addpath /home/motteler/cris/bcast/asl

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

% get the IDPS SDR path and filename
sdir = '/asl/data/cris/sdr60/hdf/2012/112';
slist = dir(fullfile(sdir, ['SCRIS_npp_*.h5']));

nfile = length(slist);
nchan = length(wn_lw);

yall = zeros(nchan,nfile);

for i = 1 : nfile

  sfile = fullfile(sdir, slist(i).name);

  % read the IDPS SDR file
  pd = readsdr_rawpd(sfile);

  % --------
  % LW tests
  % --------

  j = 5;   % select a FOV
  k = 15;  % select a FOR

  si = 31; % select a scan index;

  % IDPS spectra
  x2 = wn_lw;
  y2 = real(rad2bt(x2, pd.ES_RealLW(:, j, k, si)));

  % comparison plot
  % figure (1)
  % plot(x2, y2)
  % title('DPS quick check')
  % grid
  % zoom on

  yall(:, i) = y2;

end

save yall yall x2

for i = [51, 60, 82, 94, 97, 109, 147, 175]
  plot(x2, yall(:, i))
  tmp = slist(i).name(11:28);
  tmp(10) = ' ';
  title(tmp)
  grid
  saveas(gcf, slist(i).name(11:28), 'png')
  pause
end


