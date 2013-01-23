
% browse hi res data, compare with FOV 5

% specify file, FOR, scan, and plot file ID
% sfile = '/home/motteler/cris/data/2012/054/SDR_d20120223_t0033314.mat';
sfile = '/home/motteler/cris/data/2012/054/SDR_d20120223_t1505265.mat';
iFOR = 15;
scan = 58;
fstr = '2';

% get the data
load(sfile)
[m, nscan] = size(scTime);

% for scan = 2 : 4 : nscan

% rid for plot name
rtmp = rid;
rtmp(10) = ' ';

% size from interpolation
npts = length(vSW);

% show results at the user grid
[inst, user] = inst_params('SW', 773.13);
vband = [user.v1, user.v2];
iband = interp1(vSW, 1:npts, vband, 'nearest');
ix =  iband(1) : iband(2);
vgrid = vSW(ix);

fovbt = real(rad2bt(vgrid, rSW(ix, :, iFOR, scan)));

fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

figure(1); clf
subplot(2,1,1)
plot(vgrid, fovbt);
legend(fovnames, 'location', 'southeast')
title(['band 3, ', rtmp])
xlabel('wavenumber')
ylabel('BT, K')
grid

subplot(2,1,2)
plot(vgrid, fovbt - fovbt(:,5)*ones(1,9));
legend(fovnames, 'location', 'southeast')
title('all FOVs minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid

saveas(gcf, ['SW_sample_',fstr], 'fig')

% scan
% pause

% end

