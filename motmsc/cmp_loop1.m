%
% cmp_loop1 - loop on ccast SDR files, compare with IDPS 
%
%  loop on ccast files and scans, find matching IPDS scans, and
%  tabulate radiances for a selected FOR and channel subset
%

addpath asl
addpath ../source

% select day-of-the-year
doy = '293';

% parameters to save
ifor = 15;
sv1 = 750;
sv2 = 770;

% get a list of ccast files for the day
byear = '/asl/data/cris/ccast/sdr60/2013';
bdir  = fullfile(byear, doy);
blist = dir(fullfile(bdir, 'SDR*.mat'));

% get the band params
wlaser = 773.1301;
[inst, user] = inst_params('LW', wlaser);

% get the path to the IDPS SDR data
syear = '/asl/data/cris/sdr60/hdf/2013';
sdir  = fullfile(syear, doy);
sfile_old = '';

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

% initialize output
rad1 = [];
rad2 = [];
rtime = [];
rlat = [];
rlon = [];

% loop on ccast files
for fi = 1 : length(blist)

  bfile = fullfile(bdir, blist(fi).name);
  load(bfile)

  ix1 = find(sv1 <= vLW & vLW <= sv2);
  ix2 = find(sv1 <= wn_lw & wn_lw <= sv2);
  vrad = vLW(ix1);

  [m,nscan] = size(scTime);

  for bi = 1 : nscan

    % find the corresponding IDPS file id and scan index
    gid = geo.sdr_gid(bi, :);
    si = geo.sdr_ind(bi, :);  

    % skip to next scan if no matching IDPS scan
    if isnan(si), continue, end

    % get the IDPS SDR filename
    slist = dir(fullfile(sdir, ['SCRIS_npp_', gid, '*.h5']));
    if isempty(slist), continue, end
    sfile = fullfile(sdir, slist(end).name);

    % read the IDPS SDR file, if needed
    if ~strcmp(sfile_old, sfile)
      pd = readsdr_rawpd(sfile);
      sfile_old = sfile;
    end

    % skip to next scan if the ccast FOR is bad
    if L1a_err(ifor, bi), continue, end

    rad1 = cat(3, rad1, rLW(ix1, :, ifor, bi));
    rad2 = cat(3, rad2, pd.ES_RealLW(ix2, :, ifor, si));
    rtime = [rtime, geo.FORTime(ifor, bi)];
    rlat = [rlat, geo.Latitude(:, ifor, bi)];
    rlon = [rlon, geo.Longitude(:, ifor, bi)];

  end
  fprintf(1, '.')
end
fprintf(1, '\n')

bt1 = rad2bt(vrad, rad1);
bt2 = rad2bt(vrad, rad2);
tgrid = (rtime - rtime(1)) ./ (60 * 60 * 1e6);

ifov = 1;
y1 = mean(squeeze(bt1(:, ifov, :)));
y2 = mean(squeeze(bt2(:, ifov, :)));

figure(1); clf
subplot(2,1,1)
plot(tgrid, y1 - y2)
title(sprintf('FOV %d ccast - IDPS mean BT, %g to %g 1/cm', ifov, sv1, sv2))
% axis([4, 9, -8, 8])
xlabel('hours')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(tgrid, rlat(ifov,:))
% axis([4, 9, -100, 100])
xlabel('hours')
ylabel('latitude')
grid on; zoom on

% saveas(gcf, sprintf('FOV_%d_residuals', ifov), 'fig')

% save cmp_loop1 rad1 rad2 bt1 bt2 rtime rlat rlon vrad

