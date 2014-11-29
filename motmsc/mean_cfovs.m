%
% mean_cfovs - compare ccast FOV means over a set of files
%
% specify a directory and find the mean brightness temp for each FOV
% over all files, for specific FORs.  compare the mean values with a
% selected reference FOV.   works for both regular and high res data.  
%

addpath ./utils
addpath ../source

%-----------------
% test parameters
%-----------------
band = 'SW';
res = 'hires2';  % lowres, hires1, hires2
sFOR = 15:16;    % fields of regard, 1-30
adflag = 1;      % ascending/descending flag
iref = 5;        % index of reference FOV

% path to SDR year
% syear = '/asl/data/cris/ccast/sdr60/2013';
  syear = '/asl/data/cris/ccast/sdr60_hr_new/2013';
% syear = '/asl/data/cris/ccast/sdr60_hr_c2/2013';

% SDR days of the year
% sdays = 71;         % high res test 1
  sdays = 239 : 240;  % high res test 2
% sdays = 238;
% sdays = 64 : 77;
% sdays = 60 : 62;

% get user grid 
opts = struct;
opts.resmode = res;
[inst, user] = inst_params(band, 773.13, opts);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1)' * user.dv;

% option to set test subinterval
  tv1 = user.v1; tv2 = user.v2;
% tv1 = 672; tv2 = 705;
% tv1 = user.v1+10; tv2 = user.v2-10;

% loop initialization
nFOR = numel(sFOR);
bm = zeros(nchan * 9, 1);
bw = zeros(nchan * 9, 1);
bn = 0;

%------------------------
% loop on days and files 
%------------------------
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = rLW; vtmp = vLW(:);
      case 'MW', rtmp = rMW; vtmp = vMW(:);
      case 'SW', rtmp = rSW; vtmp = vSW(:);
    end

    % keep the standard user grid
    [m, n, k, nscan] = size(rtmp);
    [ix, jx] = seq_match(vgrid, vtmp);
    if ~isclose(vgrid, vtmp(jx))
      error('frequency grid mismatch')
    end

    % get BT, reshape for moving averages
    rtmp = rtmp(jx, :, sFOR, :);
    btmp = real(rad2bt(vgrid, rtmp));
    btmp = reshape(btmp, nchan * 9, nscan * nFOR);

    % loop on good scans
    for j = 1 : nscan
      if geo.Asc_Desc_Flag(j) ~= adflag
        continue
      end
      for i = 1 : nFOR
        k = nFOR * (j - 1) + i;
        if L1a_err(i, j)
          continue
        end
        if ~isempty(find(isnan(btmp(:, k))))
          continue
        end
%       if ~isempty(find(btmp(:, k) < 210))
%         continue
%       end
        [bm, bw, bn] = rec_var(bm, bw, bn, btmp(:, k));
      end
    end
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

% reshape mean and std
bv = bw ./ (bn - 1);
bs = sqrt(bv);
bstd = reshape(bs, nchan, 9);
bavg = reshape(bm, nchan, 9);

% set test subinterval
if tv1 > vgrid(1)
  ix = find(tv1 <= vgrid & vgrid <= tv2);
  vgrid = vgrid(ix);
  bavg = bavg(ix, :);
  bstd = bstd(ix, :);
end

% print some test stats
fprintf(1, 'residuals by FOV\n')
fprintf(1, '%8.4f', rmscol(bavg - bavg(:,iref)*ones(1,9)))
fprintf(1, '\nref FOV %d, [%d, %d], %s\n', iref, tv1, tv2, syear)

% save the data
% clear btmp rtmp geo rLW rMW rSW
% s1 = fileparts(syear); [s1, s2] = fileparts(s1); s1 = s2(7:end);
% save(sprintf('%s_%s_FOV%d_tv1_%d', band, s1, iref, tv1))
% return

%--------------
% plot results
%--------------

% plot file suffix
[t1, yr] = fileparts(syear); 
[t1, t2] = fileparts(t1);
t2 = t2(6:end);
fsuf = sprintf('%s_%s%s', yr, seq2str(sdays), t2);

% plot title suffix
t3 = strrep(t2, '_', ' ');
tsuf = sprintf('%s %s%s', yr, seq2str(sdays), t3);

figure(1); clf
subplot(2,1,1)
plot(vgrid, bavg);
legend(fovnames, 'location', 'southeast')
title(sprintf('ccast %s mean, all FOVs, test %s', band, tsuf))
xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg - bavg(:,iref)*ones(1,9));
% ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend(fovnames, 'location', 'southeast')
title(sprintf('all FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
saveas(gcf, sprintf('ccast_%s_avg_%s', band, fsuf), 'fig')

figure(2); clf
subplot(2,1,1)
plot(vgrid, bavg(:,[1,3,7,9]) - bavg(:,iref)*ones(1,4));
% ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 1', 'FOV 3', 'FOV 7', 'FOV 9', 'location', 'northeast')
title(sprintf('ccast %s corner FOVs minus FOV %d, test %s', band, iref, tsuf))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg(:,[2,4,6,8]) - bavg(:,iref)*ones(1,4));
% ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 2', 'FOV 4', 'FOV 6', 'FOV 8', 'location', 'northeast')
title(sprintf('side FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
saveas(gcf, sprintf('ccast_%s_dif_%s', band, fsuf), 'fig')

figure(3); clf
subplot(2,1,1)
plot(vgrid, bstd);
legend(fovnames, 'location', 'southeast')
title(sprintf('ccast %s std, all FOVs, test %s', band, tsuf))
xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bstd - bstd(:,iref)*ones(1,9));
% ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend(fovnames, 'location', 'southeast')
title(sprintf('all FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
saveas(gcf, sprintf('ccast_%s_std_%s', band, fsuf), 'fig')

