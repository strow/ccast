%
% cmp_idps - compare b/ccast and IDPS spectra.  
%
% specify a bcast SDR file and scan index, find the corresponding
% IDPS file and scan, and compare selected spectra.  This is simple
% because the bcast SDR files include the gid string from the GCRSO
% file, which is also an identifier for the IDPS SDR files.

addpath ./asl
addpath ../source

% select day-of-the-year
doy = '293';

% get a list of files for this day
byear = '/asl/data/cris/ccast/sdr60/2013/';  
bdir  = fullfile(byear, doy);
blist = dir(fullfile(bdir, 'SDR*.mat'));

% choose and load particular file
fi = 58;
bfile = fullfile(bdir, blist(fi).name);
load(bfile)

% select a ccast scan index
bi = 31;

% find the corresponding IDPS SDR file time and scan index
gid = geo.sdr_gid(bi, :);
si = geo.sdr_ind(bi, :);  

% get the IDPS SDR path and filename
syear = '/asl/data/cris/sdr60/hdf/2013';
sdir  = fullfile(syear, doy);
slist = dir(fullfile(sdir, ['SCRIS_npp_', gid, '*.h5']));
sfile = fullfile(sdir, slist(end).name);

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

% read the IDPS SDR file
pd = readsdr_rawpd(sfile);

% get user grid
wlaser = 773.1301;
[inst, user] = inst_params('LW', wlaser);

%---------------------------------------
% compare a selected FOV, FOR, and scan
%---------------------------------------
iFOV = 1;   % select a FOV
iFOR = 15;  % select a FOR

if L1a_err(iFOR, bi)
  fprintf(1, 'bad obs, FOR %d scan %d\n', iFOR, bi)
  return
end

% bcast spectra
x1 = vLW';
y1 = real(rad2bt(x1, rLW(:, iFOV, iFOR, bi)));

% IDPS spectra
x2 = wn_lw;
y2 = real(rad2bt(x2, pd.ES_RealLW(:, iFOV, iFOR, si)));

% match frequency grids (IDPS is a subset of bcast)
ix = interp1(x1, 1:length(x1), x2, 'nearest');
x1 = x1(ix);
y1 = y1(ix);
% rms(y2 - y1)
% rms(x2 - x1)

% comparison plot
figure(1); clf
subplot(2,1,1)
plot(x1, y1, x2, y2)
ax = axis; ax(1) = user.v1; ax(2) = user.v2; axis(ax);
rtmp = gid; rtmp(10) = ' ';
title(sprintf('%s FOV %d FOR %d Scan %d', rtmp, iFOV, iFOR, bi))
legend('ccast', 'IDPS', 'location', 'best')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(x1, y1 - y2)
ax(1) = user.v1; ax(2) = user.v2; ax(3) = -0.5; ax(4) = 0.5; axis(ax);
title('ccast - IDPS')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

%----------------------------------------------
% compare all FOVs for a selected FOR and scan
%----------------------------------------------

% bcast spectra
y1 = real(rad2bt(x1, rLW(ix, :, iFOR, bi)));

% IDPS spectra
y2 = real(rad2bt(x2, pd.ES_RealLW(:, :, iFOR, si)));

fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

figure(2); clf
plot(x1, y1 - y2)
ax(1) = user.v1; ax(2) = user.v2; ax(3) = -0.5; ax(4) = 0.5; axis(ax);
title(sprintf('ccast - IDPS, %s FOR %d Scan %d', rtmp, iFOR, bi))
legend(fovnames, 'location', 'best')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

