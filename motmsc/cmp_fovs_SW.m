%
% cmp_fovs - find a FOR with similar FOVs and compare them
%
% this should work for both regular and high res data but so far
% has only been tested with high res.  The call to inst_params is
% only to get the user grid endpoints, and so doesn't really need
% to be the high res version.

% specify SDR mat file
% sfile = '../../data/2012/054/SDR_d20120223_t1505265.mat';
% sfile = '../../data/2013/071/SDR_d20130312_t1709422.mat';
  sfile = '../../data/2013/071/SDR_d20130312_t1741420.mat';

% get the data
load(sfile)
[m, nscan] = size(scTime);

% show results at the user grid
[inst, user] = inst_params('SW', 773.13);
vband = [user.v1, user.v2];
iband = interp1(vSW, 1:length(vSW), vband, 'nearest');
ix =  iband(1) : iband(2);
vgrid = vSW(ix);

% search for FORs with similar FOVs
dmin = 1e6;
for i = 11 : 20
  for j = 1 : nscan
    fovbt = real(rad2bt(vgrid, rSW(ix, :, i, j)));
    t1 = max(rmscol(fovbt - fovbt(:,5) * ones(1,9)));
    if t1 < dmin
      dmin = t1;
      dij = [i,j];
    end
  end
end
i = dij(1);
j = dij(2);
dmin
dij

% plot results
rtmp = rid;
rtmp(10) = ' ';
fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

figure(1); clf
subplot(2,1,1)
fovbt = real(rad2bt(vgrid, rSW(ix, :, i, j)));
plot(vgrid, fovbt);
legend(fovnames, 'location', 'southeast')
title(['SW, all FOVs, ', rtmp])
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

saveas(gcf, ['SW_',rid], 'fig')

