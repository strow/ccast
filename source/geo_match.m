%
% NAME
%   geo_match - match GCRSO and RDR scans
%
% SYNOPSIS
%   geo_out = geo_match(geo_in, swTime)
%
% INPUTS
%   geo_in   - geo struct from do_allgeo
%   swTime   - 34 x nscan, rad count time
%
% OUTPUTS
%   geo_out  - geo struct subset match for swTime
%
% DISCUSSION
%
%   RDR and GCRSO FOR time fields are matched and this pairing is
%   used to match RDR and GCRSO scans.  Selected GCRSO fields are
%   then copied to the RDR scan timeline, which is also the bcast
%   SDR timeline.
%
%   if the residual difference between swTime and geo_out.FORTime 
%   is greater than 1 ms, this is reported in a warning message
%
%   geo_match take into account the 3 Jul 2012 RDR 1 second time
%   shift
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

% 18 char filler for missing gid 
gfill = 'xxxxxxxxxxxxxxxxxx';

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

mt0 = datenum('1-jan-1958');  % IET base time
mt1 = datenum('1-jan-2012');  % CrIS data start
mt2 = datenum('4-jul-2012');  % RDR 1 sec shift

t1 = mwt * (mt1 - mt0);  % IET time for CrIS start
t2 = mwt * (mt2 - mt0);  % IET time for RDR 1 sec shift

% set the RDR offset from SDR time, in ms
tx = min(swTime(:));  
if t1 <= tx && tx < t2
  dtRDR = 1817 + 4 * 8000;
else
  dtRDR = 2817 + 4 * 8000;
end

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

geo_out.Asc_Desc_Flag    = ones(nscan2, 1) * NaN;
geo_out.Orbit_Number     = ones(nscan2, 1) * NaN;
geo_out.Granule_ID  = char(ones(nscan2, 1) * double(gfill(1:16)));
geo_out.Orbit_Start_Time = ones(nscan2, 1) * NaN;

geo_out.sdr_gid = char(ones(nscan2, 1) * double(gfill));
geo_out.sdr_ind = ones(nscan2, 1) * NaN;

%-------------------
% geo time and index
%-------------------
g1 = double(geo_in.FORTime) / 1000;
g1 = g1(:);

% sort and drop duplicates
[g2, i2] = unique(g1);

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
  fprintf(1, 'geo_match: no matching geo values found\n')
  return
end

% keep the valid matchups, after dropping NaNs
ir = ir(ix);   % index (in g1) of valid r2 matches with g2
gr = g1(ir);   % valid g1 matches with r2
r2 = r2(ix);   % valid r2 matches with g1
j2 = j2(ix);   % index of r2 in r1, r2 = r1(j2) + dtRDR

% isequal(gr, g1(ir))
% isequal(r2, r1(j2) + dtRDR)

% only keep matches within 1 ms
ix = find(abs(gr - r2) <= 1);
if isempty(ix)
  fprintf(1, 'geo_match: no matching geo values within 1 ms\n')
  return
end

% keep the matchups within 1 ms
i3 = ir(ix);   % index (in g1) of close r2 matches with g2
g3 = gr(ix);   % close g1 matches with r2
r3 = r2(ix);   % close r2 matches with g1
j3 = j2(ix);   % index of r3 in r1, r3 = r1(j3) + dtRDR

% verify that i3 and j3 are what we want--linear indices (into the
% original arrays) of the final matched RDR and geo data
% isequal(g3, g1(i3))
% isequal(r3, r1(j3) + dtRDR)

%------------------------------------------------
% get scan indices for input and output selection
%------------------------------------------------

% note that we are matching scans/columns here rather than linear
% indices as above.  it's possible to have a situation where the
% scanorder output is the concatenation of two partial scans, e.g.
% ES 1-10 from scan k and 21-30 from scan k+1, but that should be
% rare and is flagged with a time-gap warning.

[grow, gcol] = ind2sub([30, nscan1], i3);
[rrow, rcol] = ind2sub([30, nscan2], j3);

ix = find([diff(rcol); 0<1]);  % drop duplicate column indices
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

geo_out.Asc_Desc_Flag(rind)    = geo_in.Asc_Desc_Flag(sind);
geo_out.Orbit_Number(rind)     = geo_in.Orbit_Number(sind);
geo_out.Granule_ID(rind,:)     = geo_in.Granule_ID(sind,:);
geo_out.Orbit_Start_Time(rind) = geo_in.Orbit_Start_Time(sind);

geo_out.sdr_gid(rind,:) = geo_in.sdr_gid(sind,:);
geo_out.sdr_ind(rind)   = geo_in.sdr_ind(sind);

%------------------
% time sanity check
%------------------
tmp1 = geo_out.FORTime / 1000;
tmp2 = swTime(1:30, :) + dtRDR;
% plot(tmp1(:) - tmp2(:))

% max difference between 
dtout = max(abs(tmp1(:) - tmp2(:)));

% report residual differences between swTime and geo_out.FORTime
% that are greater than 1 ms.  This should be rare but can happen
% (if there are gaps in the timeline) because we match by FOR but
% copy by column.
if dtout > 1
  fprintf(1, 'geo_match: time residual %.4g ms is too large\n', dtout)
% keyboard
end

