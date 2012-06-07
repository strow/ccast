
% geo test 2
% 
% There appear to be at least 4 time units here
%   - filename time: seconds/100?  from start of day?
%   - MIT RDR time: days since 1 jan 1958
%   - NGAS RDR time: milliseconds since 1 jan 1958
%   - GEO time: microseconds since 1 jan 1958 (official IET time)
%
% Geo time start for the 60 swath files are 480 seconds apart and
% Filename times for the 60 swath files are 48000 units apart, so
% the filename units probably seconds/100.

addpath /asl/matlab/aslutil/

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% select mat files from timestamp in RDR filenames
% rid = 'd20100906_t0330042';  % MIT ES FOR starts at 1
% rid = 'd20100906_t0706030';  % fi=41, first ES FOR=30
% rid = 'd20100906_t0747388';  % fi=47, first ES FOR=14 **mismatch**
% rid = 'd20100906_t0834025';  % fi=55, first ES FOR=12
% rid = 'd20100906_t0850024';  % fi=57, first ES FOR=12
  rid = 'd20100906_t1034019';  % fi=75, first ES FOR=9

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

% get corresponding geo data 

glist = dir(sprintf('%s/GCRSO_npp*.h5', dsrc));
ngfile = length(glist);
gtime = zeros(ngfile, 1);

% integer time the from RDR filename
rtime = str2num(rid(12:18));

% search the geo file times for the closest match
for i = 1 : ngfile
  gid = glist(i).name(11:28);

  % integer time from the geo filename
  gtime(i) = str2num(gid(12:18));

  if gtime(i) >= rtime
    break
  end  
end

gfile = [dsrc,'/',glist(i).name];

geo = readsdr_rawgeo(gfile);

% geo units appear to be microseconds since 1 jan 1958
tgeo = geo.FORTime(:) / 1000;
ngeo = length(tgeo);

% mit units are days since 1 jan 1958
tmit = d1.packet.LWES.time(:,5) * mwt;
nmit = length(tmit);

% compare times in seconds
smit = tmit(1) / 1000;
sgeo = tgeo(1) / 1000;

dmit = (tmit(nmit) - tmit(1)) / 1000;
dgeo = (tgeo(ngeo) - tgeo(1)) / 1000;

dint = (tgeo(1) - tmit(1)) / 1000;
dext = gtime(i) - rtime;

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

