
% quick look at SDR data

% sfile = '/home/motteler/cris/data/2012/054/SDR_d20120223_t0033314.mat';
% iFOR = 15;
% scan = 41;

sfile = '../../data/2013/071/SDR_d20130312_t1733420.mat';
iFOR = 15;
scan = 41;

load(sfile)

% rid for plot name
rtmp = rid;
rtmp(10) = ' ';

% size from interpolation
npts = length(vSW);

% get user grid
[inst, user] = inst_params('SW', 773.13);

% set grid to official band spec
bfrq = [user.v1, user.v2];

bind = interp1(vSW, 1:npts, bfrq, 'nearest');

ix =  bind(1) : bind(2);

fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

plot(vSW(ix), real(rad2bt(vSW(ix), rSW(ix, :, iFOR, scan))))
legend(fovnames, 'location', 'best')

title(['band 3, ', rtmp])
xlabel('channel freq, 1/cm')
ylabel('BT, K')
grid
zoom on

saveas(gcf, 'SW_sample', 'fig')

