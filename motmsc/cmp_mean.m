%
% cmp_mean - compare mean over a set of files
%
% specify a directory and find the mean brightness temp for each FOV
% over all files, for a specific for.  compare mean values vs FOV 5.
%
% works for both regular and high res data.  the call to inst_params
% is only to get the user grid endpoints, and doesn't need to be the
% high res version to do high res.
%
% change all the uppercase names, e.g. SW to MW, to change bands
% 

addpath utils

% path to SDR mat files
% sdir = '/asl/data/cris/ccast/sdr60/2012/264/';
% sdir = '/asl/data/cris/ccast/sdr60_hr_x2/2013/240/';
% sdir = '/asl/data/cris/ccast/sdr60_hr/2013/240/';
% sdir = '/asl/data/cris/ccast/sdr60_hr/2013/071/';
sdir = '/asl/data/cris/ccast/sdr60/2013/238/';
flist = dir(fullfile(sdir, 'SDR*.mat'));

% initialize output struct
mlist = struct([]);

% choose an FOR range
% iFOR = 11:20;
iFOR = 15;
nFOR = length(iFOR);
adflag = 1;

% loop on SDR files
for fi = 1 : length(flist);

  % get the filename
  rid = flist(fi).name(5:22);
  stmp = ['SDR_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);
  
  % get the data
  load(sfile)
  [m, nscan] = size(scTime);

  % save results at the user grid
  if fi == 1
    [inst, user] = inst_params('MW', 773.13);
    vband = [user.v1, user.v2];
    iband = interp1(vMW, 1:length(vMW), vband, 'nearest');
    ix =  iband(1) : iband(2);
    vgrid = vMW(ix);
    nchan = length(vgrid);
    bavg = zeros(nchan * 9, 1);
    navg = 0;
  end

  btmp = real(rad2bt(vgrid, rMW(ix, :, iFOR, :)));
  btmp = reshape(btmp, nchan * 9, nscan * nFOR);

  % loop on good scans
  for j = 1 : nscan
    if geo.Asc_Desc_Flag(j) ~= adflag
      continue
    end
    if isempty(find(isnan(btmp(:, j))))
      [bavg, navg] = rec_mean(bavg, navg, btmp(:, j));
    end
  end
  fprintf(1, '.')
end
fprintf(1, '\n')

bavg = reshape(bavg, nchan, 9);

% plot results
if nFOR == 1
 sFOR = sprintf('%d', iFOR);
else
 sFOR = sprintf('%d-%d', iFOR(1), iFOR(end));
end

if adflag == 1
  adstr = 'asc';
else
  adstr = 'des';
end

figure(1); clf
fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

subplot(2,1,1)
plot(vgrid, bavg);
legend(fovnames, 'location', 'southeast')
title(sprintf('MW mean, all FOVs, FOR %s, %s', sFOR, adstr))
xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg - bavg(:,5)*ones(1,9));
legend(fovnames, 'location', 'southeast')
title('all FOVs minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, sprintf('cmp_mean_MW_avg_FOR_%s_%s', sFOR, adstr), 'fig')

figure(2); clf
subplot(2,1,1)
plot(vgrid, bavg(:,[1,3,7,9]) - bavg(:,5)*ones(1,4));
legend('FOV 1', 'FOV 3', 'FOV 7', 'FOV 9', 'location', 'northeast')
title(sprintf('corner FOVs  minus FOV 5, FOR %s, %s', sFOR, adstr))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg(:,[2,4,6,8]) - bavg(:,5)*ones(1,4));
legend('FOV 2', 'FOV 4', 'FOV 6', 'FOV 8', 'location', 'northeast')
title('side FOVs  minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, sprintf('cmp_mean_MW_dif_FOR_%s_%s', sFOR, adstr), 'fig')

