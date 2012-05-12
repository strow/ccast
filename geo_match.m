%
% NAME
%   geo_match - match SDR geo data to RDR scanorder output
%
% SYNOPSIS
%   geo_out = geo_match(geo_in, swTime)
%
% INPUTS
%   geo_in   - geo struct from do_allgeo
%   swTime   - 34 x nscan, rad count times
%
% OUTPUTS
%   geo_out  - geo struct subset match for swTime
%
% DISCUSSION
%   the geo fields from the GCRSO_npp*.h5 for N scans are
%                   FORTime: [30xN int64]
%                    Height: [9x30xN single]
%                  Latitude: [9x30xN single]
%                 Longitude: [9x30xN single]
%                   MidTime: [Nx1 int64]
%                  PadByte1: [Nx1 uint8]
%            QF1_CRISSDRGEO: [Nx1 uint8]
%                SCAttitude: [3xN single]
%                SCPosition: [3xN single]
%                SCVelocity: [3xN single]
%     SatelliteAzimuthAngle: [9x30xN single]
%            SatelliteRange: [9x30xN single]
%      SatelliteZenithAngle: [9x30xN single]
%         SolarAzimuthAngle: [9x30xN single]
%          SolarZenithAngle: [9x30xN single]
%                 StartTime: [Nx1 int64]
%
% AUTHOR
%   H. Motteler, 2 May 2012
%

function geo_out = geo_match(geo_in, swTime)

[m1, nscan1] = size(geo_in.FORTime);
[m2, nscan2] = size(swTime);

if m1 ~= 30 || m2 ~= 34
  error('bad input size')
end

% RDR offset from SDR time, in ms
dtRDR = 1817;

%-------------------
% initialize outputs
%-------------------
geo_out.FORTime               = ones(30, nscan2) * NaN;
geo_out.Height                = ones(9, 30, nscan2) * NaN;
geo_out.Latitude              = ones(9, 30, nscan2) * NaN;
geo_out.Longitude             = ones(9, 30, nscan2) * NaN;
geo_out.MidTime               = ones(nscan2, 1) * NaN;
geo_out.PadByte1              = ones(nscan2, 1) * NaN;
geo_out.QF1_CRISSDRGEO        = ones(nscan2, 1) * NaN;
geo_out.SCAttitude            = ones(3, nscan2) * NaN;
geo_out.SCPosition            = ones(3, nscan2) * NaN;
geo_out.SCVelocity            = ones(3, nscan2) * NaN;
geo_out.SatelliteAzimuthAngle = ones(9, 30, nscan2) * NaN;
geo_out.SatelliteRange        = ones(9, 30, nscan2) * NaN;
geo_out.SatelliteZenithAngle  = ones(9, 30, nscan2) * NaN;
geo_out.SolarAzimuthAngle     = ones(9, 30, nscan2) * NaN;
geo_out.SolarZenithAngle      = ones(9, 30, nscan2) * NaN;
geo_out.StartTime             = ones(nscan2, 1) * NaN;

%-------------------
% geo time and index
%-------------------
g1 = double(geo_in.FORTime) / 1000;
g1 = g1(:);
i1 = (1 : length(g1))';

% sort and drop duplicates
[g2, ix] = unique(g1);
i2 = i1(ix);

% drop obvious bad values
ix = find(g2 > 1e12);
g2 = g2(ix);   % valid geo times
i2 = i2(ix);   % index of g2 in g1, g2 = g1(i2)

% isequal(g2, g1(i2))

%-------------------
% RDR time and index
%-------------------
r1 = swTime(1:30, :);
r1 = r1(:);
j1 = (1 : length(r1))';

% drop bad values, NaNs in the RDR data
iok = find(~isnan(r1));
r2 = r1(iok);   % valid RDR times 
j2 = j1(iok);   % index of r2 in r1, r2 = r1(j2)

% isequal(r2, r1(j2))

% add the RDR time offset
r2 = r2 + dtRDR;

% -----------------------
% match RDR and geo times
% -----------------------
ir = interp1(g2, i2, r2, 'nearest');

ix = find(~isnan(ir));
if isempty(ix)
  fprintf(1, 'geo_match: no matching RDR values found\n')
  return
end

% keep the valid matchups, after dropping NaNs
ir = ir(ix);
gr = g1(ir);
r2 = r2(ix);
j2 = j2(ix);

% only keep matches within 1 ms
ix = find(abs(gr - r2) <= 1);
if isempty(ix)
  fprintf(1, 'geo_match: no matching RDR values within 1 ms\n')
  return
end

% keep the matchups within 1 ms
g3 = gr(ix);
i3 = ir(ix);
r3 = r2(ix);
j3 = j2(ix);

%------------------------------------------------
% get scan indices for input and output selection
%------------------------------------------------

% note that we are matching scans/columns here rather than linear
% indices as above.  it's possible to have a situation where the
% scanorder output is the concatenation of two partial scans, e.g.
% ES 1-10 from scan k and 21-30 from scan k+1, but that should be
% very rare, and is flagged with a time-gap warning.  In that case
% we return a column match with scan k+1.

[grow, gcol] = ind2sub([30, nscan1], i3);
[rrow, rcol] = ind2sub([30, nscan2], j3);

ix = find([diff(rcol); 0<1]);  % index of changes in rcol
rind = rcol(ix);   % output array columns
sind = gcol(ix);   % input array columns

%------------------------------
% copy selected scans to output
%------------------------------
geo_out.FORTime(:,rind)      = double(geo_in.FORTime(:,sind));
geo_out.Height(:,:,rind)     = double(geo_in.Height(:,:,sind));
geo_out.Latitude(:,:,rind)   = double(geo_in.Latitude(:,:,sind));
geo_out.Longitude(:,:,rind)  = double(geo_in.Longitude(:,:,sind));
geo_out.MidTime(rind)        = double(geo_in.MidTime(sind));
geo_out.PadByte1(rind)       = double(geo_in.PadByte1(sind));
geo_out.QF1_CRISSDRGEO(rind) = double(geo_in.QF1_CRISSDRGEO(sind));
geo_out.SCAttitude(:,rind)   = double(geo_in.SCAttitude(:,sind));
geo_out.SCPosition(:,rind)   = double(geo_in.SCPosition(:,sind));
geo_out.SCVelocity(:,rind)   = double(geo_in.SCVelocity(:,sind));
geo_out.SatelliteAzimuthAngle(:,:,rind) = double(geo_in.SatelliteAzimuthAngle(:,:,sind));
geo_out.SatelliteRange(:,:,rind)        = double(geo_in.SatelliteRange(:,:,sind));
geo_out.SatelliteZenithAngle(:,:,rind)  = double(geo_in.SatelliteZenithAngle(:,:,sind));
geo_out.SolarAzimuthAngle(:,:,rind)     = double(geo_in.SolarAzimuthAngle(:,:,sind));
geo_out.SolarZenithAngle(:,:,rind)      = double(geo_in.SolarZenithAngle(:,:,sind));
geo_out.StartTime(rind)      = double(geo_in.StartTime(sind));

% tmp1 = ones(30, nscan2) * NaN;
% tmp1(:, rind) = double(geo_in.FORTime(:, sind)) / 1000;

%------------------
% time sanity check
%------------------

tmp1 = geo_out.FORTime / 1000;
tmp2 = swTime(1:30, :) + dtRDR;
% plot(tmp1(:) - tmp2(:))

% max difference between swTime and geo_out.FORTime
dtout = max(abs(tmp1(:) - tmp2(:)));

% max internal time difference with linear index matchup
dtint = max(abs(g3 - r3));

% these are very small time differences, but track them for now
if dtout > 0.002 || dtint > 0.002
  fprintf(1, 'geo_match: max dt out %.4g ms, int %.4g ms\n', dtout, dtint);
end

% this is still only a 1 ms error, but for now check it out
if max(dtout) > 1
  keyboard
end

