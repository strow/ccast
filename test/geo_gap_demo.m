%
% demo of scan index shift in NOAA geo granules
%
% The GCRSO geo obs are chugging along with 8 second scans, one scan
% per index step.  Then the scan after 30-Jun-2017 10:31:43 has all
% obs flagged bad and the scan after that continues at the correct
% start time.  So the file has only 59 scans, no gaps in the data,
% and one scan index is flagged bad.
% 
% This shifts the start times for all obs after the bad scan by 8
% seconds, including all subsequent granules.  So the granule frames
% are not strictly regular in time; most are 8 minutes, but sometimes
% one is short, and they continue with the shift.  This is not really
% a problem, and I think NOAA has warned about this.
% 
% This showed up because I can set the new ccast to any granule frame
% size and starting point I want.  I was comparing the ccast and NOAA
% granules, and for around 10 hours they were simulatneous, and then I
% saw the 8-second shift.  This didn't hurt anything since I am doing
% everything by matching obs times, but it did make for a good test.
% 

% scans per file
nscanRDR = 60;  % used for initial file selection
nscanGeo = 60;  % used for initial file selection

gdir = '/asl/data/cris/sdr60/2017/181';
glist = dir2list(gdir, 'GCRSO', nscanGeo);

rdir = '/asl/data/cris/rdr60/2017/181';
rlist = dir2list(rdir, 'RCRIS', nscanRDR);

Gfp = 77

[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
datestr(iet2dnum(geoTime(1))), datestr(iet2dnum(geoTime(end)))
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
datestr(iet2dnum(geoTime(1))), datestr(iet2dnum(geoTime(end)))
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
datestr(iet2dnum(geoTime(1))), datestr(iet2dnum(geoTime(end)))
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
datestr(iet2dnum(geoTime(1))), datestr(iet2dnum(geoTime(end)))

Gfp = 78;  % short file
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);

% plot(geo.FORTime(:,47) - geo.FORTime(1))
plot(geo.FORTime(:,48) - geo.FORTime(1))
% plot(geo.FORTime(:,49) - geo.FORTime(1))

% start times for successive scans.  scan 48 is flagged bad and the
% times simply continue with scan 49
datestr(iet2dnum(geo.FORTime(1,46)))                                      
datestr(iet2dnum(geo.FORTime(1,47)))                                      
datestr(iet2dnum(geo.FORTime(1,49)))
datestr(iet2dnum(geo.FORTime(1,50)))

max(diff(geoTime(geoTimeOK))) / 1e6

