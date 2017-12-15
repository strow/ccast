%
% nextGeo - read successive GCRSO files
%
% mainly just a wrapper for read_GCRSO
%
% gi is the file index pointer
%   gi = 0, initial or done, geoTime is empty
%   1 <= gi <= n, geoTime valid, file gi is in the buffer
%
% output geoTime is geo.FORTime extended with SP and IT times
%
% scan times
% 200 200 ...  200  200  200 200 200  200  200 200 200  200  200  200
% ES1 ES2 ... ES29 ES30 slew SP1 SP2 slew slew IT1 IT2 slew slew slew
%  1   2        29   30   31  32  33   34   35  36  37   38   39   40
%
% sweep times in ms
%   tx = (0:39) * 200;
%   tES = tx(1:30);
%   tSP = tx(32:33);
%   tIT = tx(36:37);

function [geo, geoTime, timeOK, gi] = nextGeo(gdir, glist, gi)

% time offsets for calibration looks
tcal = [400, 600, 1200, 1400] * 1e3;

% crude time range checks
tmin = 1.7e15;  % 14-Nov-2011
tmax = 2.4e15;  % 19-Jan-2034

% initialize outputs
geo = struct([]);
geoTime = [];
timeOK = [];

% % use fake times for tests
%   gi = gi + 1;
%   if gi > length(glist), 
%     gi = 0;
%   else
%     t0 = dnum2iet(datenum('1 jan 2017 12:00:00'));
% %   t0 = t0 + 2 * 8e6;   % 2 scans
%     [geoTime, timeOK] = fakeTime(t0, 60, gi, 0);
%   end
%   return

% loop on file indices
gi = gi + 1;
no_data = true;
while no_data && gi <= length(glist)

  % read the next geo file
  gid = glist(gi).name(11:28);  
  fprintf(1, 'nextGeo: reading geo index %d file %s\n', gi, gid)
  gfile = fullfile(gdir, glist(gi).name); 
  try 
    geo = read_GCRSO(gfile);
  catch
    fprintf(1, 'nextGeo: error reading %s\n', gfile)
    fprintf(1, 'continuing with the next file...\n')
    gi = gi + 1;
    continue
  end

  % we got someting
  no_data = false;

  % geoTime extends geo.FORTime ES times with IT and SP times
  [~, nscanGeo] = size(geo.FORTime);
  tx = double(geo.FORTime);
  ty = tx(30, :) + tcal' * ones(1, nscanGeo);
  geoTime = [tx; ty];
  geoTime = geoTime(:);

  % basic time QC
  timeOK = ~isnan(geoTime) & tmin <= geoTime & geoTime <= tmax;

end

% wrap file index pointer to zero
if gi > length(glist), gi = 0; end

