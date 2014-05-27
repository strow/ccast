%
% cmp_fovs2 - find obs with similar FOVs and compare them
%
% loop on files and obs (for a subset of FORs close to nadir) and
% find obs where all 9 fovs are relatively close as an RMS residual
% over the whole user grid.  Then sort and plot in residual order.
%
% works for both regular and high res data.  The call to inst_params
% is only to get the user grid endpoints, and doesn't need to be the
% high res version to do high res.
%
% change all the uppercase names, e.g. SW to MW, to change bands
% 

addpath ./utils
addpath ../source

% path to SDR mat files
% sdir = '/asl/data/cris/ccast/sdr60/2012/264/';    % 20 Sep 2012
  sdir = '/asl/data/cris/ccast/sdr60_hr/2013/240';  % hires day 2
  sdir = '/asl/data/cris/ccast/sdr60/2014/060';     % 1 Mar 2014

% get a list of files
flist = dir(fullfile(sdir, 'SDR*.mat'));

% initialize output struct
mlist = struct([]);

% loop on SDR files
for fi = 1 : length(flist);

  % get the filename
  rid = flist(fi).name(5:22);
  stmp = ['SDR_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);
  
  % get the data
  load(sfile)
  [m, nscan] = size(scTime);

  % compare results at the user grid
  [inst, user] = inst_params('MW', 773.13);
  vband = [user.v1, user.v2];
  iband = interp1(vMW, 1:length(vMW), vband, 'nearest');
  ix =  iband(1) : iband(2);
  vgrid = vMW(ix);

  % search for FORs with similar FOVs
  dmin = 1e6;
  for i = 15 : 16
    for j = 1 : nscan
      fovbt = real(rad2bt(vgrid, rMW(ix, :, i, j)));
      t1 = max(rmscol(fovbt - fovbt(:,5) * ones(1,9)));
      if t1 < dmin
        dmin = t1;
        dij = [i,j];
      end
    end
  end
  mlist(fi).i = dij(1);
  mlist(fi).j = dij(2);
  mlist(fi).dmin = dmin;
  mlist(fi).sfile = sfile;
  mlist(fi).rid = rid;
  fprintf(1, '.');
end
fprintf(1, '\n')

% sort the results by residual
[tsrt, isrt] = sort([mlist(:).dmin]);
mlist = mlist(isrt);

% loop on files in residual order
for fi = 1 : length(mlist)

  % get values for this file
  rid = mlist(fi).rid;
  sfile = mlist(fi).sfile;
  dmin = mlist(fi).dmin;
  i = mlist(fi).i;
  j = mlist(fi).j;

  % get the data
  load(sfile)
  [m, nscan] = size(scTime);

  % show results at the user grid
  [inst, user] = inst_params('MW', 773.13);
  vband = [user.v1, user.v2];
  iband = interp1(vMW, 1:length(vMW), vband, 'nearest');
  ix =  iband(1) : iband(2);
  vgrid = vMW(ix);

  % plot results
  rtmp = rid;
  rtmp(10) = ' ';
  fovnames = {'FOV 1','FOV 2','FOV 3',...
              'FOV 4','FOV 5','FOV 6',...
              'FOV 7','FOV 8','FOV 9'};

  figure(1); clf
  subplot(2,1,1)
  fovbt = real(rad2bt(vgrid, rMW(ix, :, i, j)));
  plot(vgrid, fovbt);
  legend(fovnames, 'location', 'southeast')
  title(['MW, all FOVs, ', rtmp])
  xlabel('wavenumber')
  ylabel('BT, K')
  grid on; zoom on

  subplot(2,1,2)
  plot(vgrid, fovbt - fovbt(:,5)*ones(1,9));
  legend(fovnames, 'location', 'southeast')
  title('all FOVs minus FOV 5')
  xlabel('wavenumber')
  ylabel('dBT, K')
  grid on; zoom on

  saveas(gcf, sprintf('cmp_fovs_MW_%d', fi), 'fig')

  fprintf(1, 'fi %2d FOR %d dmin %5.3f rid %s lat %6.1f lon %6.1f\n', ...
          fi, i, dmin, rid, geo.Latitude(5,i,j), geo.Longitude(5,i,j));
  pause
end

