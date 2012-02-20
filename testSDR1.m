
% SDR and RDR matchup test
% this version starts witn an SDR file

addpath /asl/matlab/aslutil/
addpath /asl/matlab/cris/readers/
addpath /asl/matlab/cris/utils

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% test data source
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% SDR file list
slist = dir(sprintf('%s/SCRIS_npp*.h5', dsrc));
nsfile = length(slist);

% geo file list
glist = dir(sprintf('%s/GCRSO_npp*.h5', dsrc));
ngfile = length(glist);

% MIT matlab RDR data directory
rsrc = '/asl/data/cris/mott/2010/09/06mit';
rlist = dir(sprintf('%s/RDR*.mat', rsrc));
nrfile = length(rlist);

% choose SDR file by index
si = 42;

% date and time from filename
sid = slist(si).name(11:28);
stime = str2num(sid(12:18));

% read the SDR file
sfile = [dsrc,'/',slist(si).name];
[prof, pattr] = readsdr_rtp(sfile);

% find matching geo filename
for i = 1 : ngfile
  gid = glist(i).name(11:28);
  gtime = str2num(gid(12:18));
  if isequal(gid,sid)
    break
  end
end
if gtime ~= stime
  error('no matching geo file')
end

% read the geo data directly
gfile = [dsrc,'/',glist(i).name];
geo = readsdr_rawgeo(gfile);

% find a matching RDR file 
for ri = 1 : nrfile

  % MIT matlab RDR data file
  rid = rlist(ri).name(5:22);
  rtime = str2num(rid(12:18));

  if rtime >= stime
    break
  end
end
ri = ri - 1;
rid = rlist(ri).name(5:22);
rtime = str2num(rid(12:18));

% load the MIT data, defines structures d1 and m1
rmit = ['RDR_', rid, '.mat'];
fmit = [rsrc, '/', rmit];
load(fmit)

% geo units appear to be microseconds since 1 jan 1958
tgeo = geo.FORTime(:) / 1000;
ngeo = length(tgeo);

% mit time units are days since 1 jan 1958
tmit = d1.packet.LWES.time(:,5) * mwt;
nmit = length(tmit);

% compare start times in seconds
smit = tmit(1) / 1000;
sgeo = tgeo(1) / 1000;

dtmit = (tmit(nmit) - tmit(1)) / 1000;
dtgeo = (tgeo(ngeo) - tgeo(1)) / 1000;

dtint = (tgeo(1) - tmit(1)) / 1000;
dtext = stime - rtime;

fprintf(1, 'RDR file start %.3f\n', smit); ...
fprintf(1, 'geo file start %.3f\n', sgeo); ...
fprintf(1, 'RDR file span %.3f\n', dtmit); ...
fprintf(1, 'geo file span %.3f\n', dtgeo); ...
fprintf(1, 'geo - RDR start time %.3f\n', dtint); ...
fprintf(1, 'geo - RDR fname time %.3f\n', dtext)

% Choose a geo time, find corresponding RDR time

% this should be FOR 15 from geo data
% geo_t0 = double(geo.FORTime(5,1)) / 1000;
geo_t0 = double(geo.FORTime(1,1)) / 1000;

% try this
% geo_t0 = geo_t0 - 2000 % subtract 2 seconds
% geo_t0 = geo_t0 + 6000 % add 6 seconds

% compare with RDR time and FOR
t1 = d1.packet.LWES.time(:,5) * mwt;  % RDR time
t2 = d1.FOR.LWES(5,:);                % RDR FOR
t3 = min(abs(t1 - geo_t0));
ix = find(abs(t1 - geo_t0) == t3);    % RDR index of match
iy = interp1(t1, 1:length(t1), geo_t0, 'nearest')
if ix ~= iy
  fprintf(1, 'error: ix and iy differ\n')
end

% this is the RDR FOR corresponding to geo_t0
t2(iy)

% matchup info
%  SDR: si, sid
%  RDR: ri, rid
fprintf(1, 'SDR index = %3d, time = %s\n', si, sid)
fprintf(1, 'RDR index = %3d, time = %s\n', ri, rid)

prof.rlat(5)
prof.rlon(5)

sdr_frq = cris_id_to_freq(1:700,0);
sdr_rad = prof.robs1(1:700, 5);

plot(sdr_frq, sdr_rad)
title('CrIS fov 5 radiance from SDR')
grid

save sdr_obs sdr_frq sdr_rad



