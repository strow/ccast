
% geo tests

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% select mat files from timestamp in RDR filenames
rid  = 'd20100906_t0706030';
% rid  = 'd20100906_t0330042';
% rid  = 'd20100906_t0610033';

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

dlist = dir(sprintf('%s/GCRSO_npp*.h5', dsrc));
dind = 40; % chosen by hand to match rid from above

gfile = [dsrc,'/',dlist(dind).name];

addpath /asl/matlab/aslutil/

geo = readsdr_rawgeo(gfile);

% geo units appear to be microseconds since 1 jan 1958
tgeo = geo.FORTime(:) / 1000;

% mit units are days since 1 jan 1958
tmit = d1.packet.LWES.time(:,5) * mwt;

dmit = (tmit(1800) - tmit(1)) / 1000

dgeo = (tgeo(1800) - tgeo(1)) / 1000

(tmit(1) - tgeo(1)) / 1000



