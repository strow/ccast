%
% geo test 3
% 
% There appear to be at least 4 time units here
%   - filename time: probably HHMMSS.S
%   - MIT RDR time: days since 1 jan 1958
%   - NGAS RDR time: milliseconds since 1 jan 1958
%   - GEO time: microseconds since 1 jan 1958 (official IET time)
%

addpath /home/motteler/cris/rdr2spec4/asl

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% path to RDR h5 data
rsrc = '/asl/data/cris/rdr_proxy/hdf/2010/249';

% path to SDR and geo h5 data
gsrc = '/asl/data/cris/sdr4/hdf/2010/249';

% select an RDR file by date and time substring
% rid = 'd20100906_t0330042';  % first ES FOR =  1
% rid = 'd20100906_t0706030';  % first ES FOR = 30
% rid = 'd20100906_t0747388';  % first ES FOR = 14
  rid = 'd20100906_t0834025';  % first ES FOR = 12
% rid = 'd20100906_t0850024';  % first ES FOR = 12
% rid = 'd20100906_t1034019';  % first ES FOR =  9

% path to MIT RDR matlab data
dmit = '/asl/data/cris/rdr_proxy/mat/2010/249';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

% list all the geo files for this date
glist = dir(sprintf('%s/GCRSO_npp*.h5', gsrc));
ngfile = length(glist);

% integer time from RDR filename
rtime = str2num(rid(12:18));

% search the geo filename times for the closest match
for i = 1 : ngfile
  gid = glist(i).name(11:28);

  % integer time from the geo filename
  gtime = str2num(gid(12:18));

  if gtime >= rtime
    break
  end  
end

% read the selected geo file
gfile = [gsrc,'/',glist(i).name];
geo = readsdr_rawgeo(gfile);

% convert geo units to ms since 1 jan 1958
tgeo = geo.FORTime(:) / 1000;
ngeo = length(tgeo);

% convert MIT units to ms since 1 jan 1958
tmit = d1.packet.LWES.time(:,5) * mwt;
nmit = length(tmit);

% compare times in seconds
smit = tmit(1) / 1000;
sgeo = tgeo(1) / 1000;

dmit = (tmit(nmit) - tmit(1)) / 1000;
dgeo = (tgeo(ngeo) - tgeo(1)) / 1000;

dint = (tgeo(1) - tmit(1)) / 1000;
dext = gtime - rtime;

fprintf(1, 'RDR file start %.3f\n', smit); ...
fprintf(1, 'geo file start %.3f\n', sgeo); ...
fprintf(1, 'RDR file span %.3f\n', dmit); ...
fprintf(1, 'geo file span %.3f\n', dgeo); ...
fprintf(1, 'geo - RDR start time %.3f\n', dint); ...
fprintf(1, 'geo - RDR fname time %.3f\n', dext)

% this should be FOR 1 from geo data
% geo_t0 = double(geo.FORTime(1)) / 1000;

% this should be FOR 15 from geo data
geo_t0 = double(geo.FORTime(15,2)) / 1000;

% compare with RDR time and FOR
t1 = d1.packet.LWES.time(:,5) * mwt;
t2 = d1.FOR.LWES(5,:);
t3 = min(abs(t1 - geo_t0));
ix = find(abs(t1 - geo_t0) == t3);
iy = interp1(t1, 1:length(t1), geo_t0, 'nearest')
if ix ~= iy
  fprintf(1, 'error: ix and iy differ\n')
end

% this is the RDR FOR corresponding to geo_t0
t2(iy)

