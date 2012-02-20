
% SDR and RDR matchup test
%
% this version starts with an RDR file, finds a matching SDR file
% and then the geo file, and gives start times and spans for the RDR
% and geo files

% addpath /asl/matlab/aslutil/
% addpath /asl/matlab/cris/readers/
addpath /asl/matlab/cris/utils

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% source for RDR, SDR, and geo files
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% select RDR mat file from timestamp in filename
% these need to be chosen from an interval with SDR data 
% rid = 'd20100906_t1306010';
% rid = 'd20100906_t1314010';
% rid = 'd20100906_t1322009';   % geo filename time is very close
  rid = 'd20100906_t1346008';
% rid = 'd20100906_t1354007';
% rid = 'd20100906_t1402007';

% RDR MIT matlab data directory
rsrc = '/asl/data/cris/mott/2010/09/06mit';
rlist = dir(sprintf('%s/RDR*.mat', rsrc));
nrfile = length(rlist);

% load the MIT data, defines structures d1 and m1
rmit = ['RDR_', rid, '.mat'];
fmit = [rsrc, '/', rmit];
load(fmit)

% SDR file list
slist = dir(sprintf('%s/SCRIS_npp*.h5', dsrc));
nsfile = length(slist);

% geo file list
glist = dir(sprintf('%s/GCRSO_npp*.h5', dsrc));
ngfile = length(glist);

% integer time the from RDR filename (** wrong **)
rtime = str2num(rid(12:18));

% search the sdr file times for the closest match
for si = 1 : nsfile
  sid = slist(si).name(11:28);

  % integer time from the sdr filename (** wrong **)
  stime = str2num(sid(12:18));  

  if stime >= rtime
    break
  end  
end

% read the SDR file
sfile = [dsrc,'/',slist(si).name];
[prof, pattr] = readsdr_rtp(sfile);

% find matching geo filename
for gi = 1 : ngfile
  gid = glist(gi).name(11:28);
  gtime = str2num(gid(12:18));
  if isequal(gid,sid)
    break
  end
end
if gtime ~= stime
  error('no matching geo file')
end

% read the geo data directly
gfile = [dsrc,'/',glist(gi).name];
geo = readsdr_rawgeo(gfile);

% geo units appear to be microseconds since 1 jan 1958
tgeo = geo.FORTime(:) / 1000;
ngeo = length(tgeo);

% mit time units are days since 1 jan 1958
tmit = d1.packet.LWES.time(:,5) * mwt;
nmit = length(tmit);

% get start times in seconds
smit = tmit(1) / 1000;
sgeo = tgeo(1) / 1000;

% compare file spans in seconds
dtmit = (tmit(nmit) - tmit(1)) / 1000;
dtgeo = (tgeo(ngeo) - tgeo(1)) / 1000;

% compare file start times in seconds
dtint = (tgeo(1) - tmit(1)) / 1000;
dtext = (stime - rtime) / 10;

fprintf(1, 'RDR file start %.3f sec\n', smit); ...
fprintf(1, 'geo file start %.3f sec\n', sgeo); ...
fprintf(1, 'RDR file span %.3f sec\n', dtmit); ...
fprintf(1, 'geo file span %.3f sec\n', dtgeo); ...
fprintf(1, 'geo - RDR start time %.3f sec\n', dtint); ...
fprintf(1, 'geo - RDR fname time %.3f sec\n', dtext)

% Choose a geo time, find corresponding RDR time

% this should be FOR 15 from geo data
% geo_t0 = double(geo.FORTime(5,1)) / 1000;
% geo_t0 = double(geo.FORTime(15,2)) / 1000;
geo_t0 = double(geo.FORTime(1,1)) / 1000;

% try this
% geo_t0 = geo_t0 - 2000 % subtract 2 seconds
% geo_t0 = geo_t0 + 6000 % add 6 seconds

% compare with RDR time and FOR
t1 = d1.packet.LWES.time(:,5) * mwt;  % RDR time (same as tmit)
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
fprintf(1, 'SDR index = %3d, sid = %s\n', si, sid)
fprintf(1, 'RDR index = %3d, rid = %s\n', NaN, rid)

fprintf(1, 'obs lat %f, lon %f\n', prof.rlat(5), prof.rlon(5))

sdr_frq = cris_id_to_freq(1:700,0);
sdr_rad = prof.robs1(1:700, 5);

plot(sdr_frq, sdr_rad)
title('CrIS fov 5 radiance from SDR')
grid

save sdr_obs sdr_frq sdr_rad



