
% plot time from selected files from MIT reader

% select mat files from timestamp in RDR filenames
% rid  = 'd20100906_t0706030'; % time OK
% rid  = 'd20100906_t0330042'; % time OK
% rid  = 'd20100906_t0610033'; % time OK
% rid = 'd20100906_t0522036';  % garbage near the end
rid = 'd20100906_t0523396';  % time varies with FOV

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

% time plot setup
t0 = min(min(d1.packet.LWES.time(:)),min(d1.packet.LWIT.time(:)))
fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

% plot ES time
fnum=1; figure(fnum); clf;
set(gcf, 'DefaultAxesLineStyleOrder', '-|-.')
[m,n] = size(d1.packet.LWES.time);
plot(1:m, d1.packet.LWES.time-t0)
xlabel('index')
ylabel('time')
rid(10) = '-';
title(sprintf('LWES.time for file %s', rid))
legend(fovnames,'Location','northwest')
grid; zoom on
saveas(gcf, 'LWES_time', 'fig')

% plot IT time
fnum=2; figure(fnum); clf;
set(gcf, 'DefaultAxesLineStyleOrder', '-|-.')
[m,n] = size(d1.packet.LWIT.time);
plot(1:m, d1.packet.LWIT.time-t0)
xlabel('index')
ylabel('time')
rid(10) = '-';
title(sprintf('LWIT.time for file %s', rid))
legend(fovnames,'Location','northwest')
grid; zoom on
saveas(gcf, 'LWIT_time', 'fig')

