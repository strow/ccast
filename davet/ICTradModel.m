
function B = ICTradModel(band,wn,T_ICT,T_CRIS,ICT_Param,eFlag,eICT,ssmFlag,ssmOffset)

%
% function B = ICTradModel(band,wn,T_ICT,T_CRIS,ICT_Param,eFlag,eICT,ssmFlag,ssmOffset)
%
% Compute CrIS FM1 ICT predicted radiance.
%
%
% Inputs:
%
%    band:    CrIS spectral band: 'lw', 'mw', or 'sw'
%
%    wn:      vector of wavenumbers (can be sensor or user wavenumbers depending on usage) (Nchan x 1)
%             with Nchan = 864 (lw), 528 (mw), 200 (sw)
%
%    T_ICT:   scalar ICT temperature (K) (1x1)
%
%    T_CRIS:  A scan-line's worth of various CrIS instrument temperatures produced from 
%             calc_instrument_temps.m and converted into an array of structures.  
%             i.e.  t_cris contains scalar values for OMA_structure_input_1, OMA_structure_input_2, 
%             OMA_structure_input, SSM_scan_mirror, beamsplitter_1, and SSM_scan_mirror_baffle.
%
%  ICT_Param: A structure of 4 minute engineering packet parameters as read by the MIT LL RDR 
%             reader and contained in d1.packet.ICT_Param
%
%    eFlag:   Flag determining source of ICT cavity emissivity: 1: pulled from 4-min-eng packet info, 
%             or 0: input as eICT (see next input var)
%
%    eICT:    vector of ICT cavity emissivity (Nchan x 1).  Only used if eFlag=0.
%
%    ssmFlag  Flag determining source of SSM Baffle temperature offset(s): 1: pulled from 4-min-eng 
%             packet info (with modeled orbital dependence), or 0: input as ssmOffset (see next 
%             input var)
%
%    ssmOffset:  Scalar temperature offset (K) to SSM Baffle temperature.  Only used if ssmFlag=0.
%                (In TVAC was -0.5K for PQL, -1.5K for MN, -2.1K for PQH, and -3.2K for special 
%                PQH ICT emis test)

% Outputs:
%
%    B:        Structure of predicted ICT radiance variables:
%
%
% History:
%
%    17/2/2009:	JKT updated model to prescription in "CrIS FM1 ICT Effective Emissivity Retreival and Sensitivity Analysis"
%		- hardcoded view factors (4 minute engineering packets inconsistent with report)
%		- moved Scan Baffle Temperature offset to input arguement
%
%    3/13/2009: ICTradModelTVAC3_dct.m changed view factors to be equal to values given in 
% 		IR15565_Step112_ ICT_Emissivity_Retrieval_10262008.xls and made T_notch an input
% 		
%    4/06/2009: JKT, modded ICTradModelTVAC3.m code to match ccast_ICTradModelTVAC3_dct.m version emailed on 3/17/2009
%
%    7 Nov 2011: DCT: renamed to ICTradModel.m and made numerous edits regarding input format and options for ICT emissivity and SSM Baffle offset temps.
%
% The radiometric model contains radiance contributions from 
%
% 	1.  ICT emission 
%	and Reflected ICT Radiance Originating from the external environment
%	2.  SSM baffle
%	3.  OMA Housing
%	4.  ICT Baffle
%	5.  Beamsplitter (split into warm and cold view contributions)
%

% MIT LL Reader, v27 engPacket:
% d1.packet.ICT_Param
% d1.packet.ICT_Param.Band(1).ICT.EffEmissivity.Pts, 0.9999        LW ICT cavity emissivity [864x1]
% d1.packet.ICT_Param.Band(2).ICT.EffEmissivity.Pts, 0.9999        MW ICT cavity emissivity [528x1]
% d1.packet.ICT_Param.Band(3).ICT.EffEmissivity.Pts, 0.9999        SW ICT cavity emissivity [200x1]
% d1.packet.ICT_Param.Band(1).Emissivity.ScanMirrorPts, 0.0080     LW Scan Mirror emissiviy
% d1.packet.ICT_Param.Band(1).Emissivity.ScanBafflePts, 1          LW Scan Mirror Baffle emissivity
% d1.packet.ICT_Param.Band(1).Emissivity.HousingPts, 1             LW Housing emissivity
% d1.packet.ICT_Param.Band(1).Emissivity.ICT_BafflePts, 1          LW ICT Baffle emissivity
% d1.packet.ICT_Param.Band(1).Emissivity.EarthPts, 0.9800          LW Earth (notch) emissivity
% d1.packet.ICT_Param.Band(2).Emissivity.ScanMirrorPts, 0.0100     MW Scan Mirror emissiviy
% d1.packet.ICT_Param.Band(2).Emissivity.ScanBafflePts, 1          MW Scan Mirror Baffle emissivity
% d1.packet.ICT_Param.Band(2).Emissivity.HousingPts, 1             MW Housing emissivity
% d1.packet.ICT_Param.Band(2).Emissivity.ICT_BafflePts, 1          MW ICT Baffle emissivity
% d1.packet.ICT_Param.Band(2).Emissivity.EarthPts, 0.9800          MW Earth (notch) emissivity
% d1.packet.ICT_Param.Band(3).Emissivity.ScanMirrorPts, 0.0130     SW Scan Mirror emissiviy
% d1.packet.ICT_Param.Band(3).Emissivity.ScanBafflePts, 1          SW Scan Mirror Baffle emissivity
% d1.packet.ICT_Param.Band(3).Emissivity.HousingPts, 1             SW Housing emissivity
% d1.packet.ICT_Param.Band(3).Emissivity.ICT_BafflePts, 1          SW ICT Baffle emissivity
% d1.packet.ICT_Param.Band(3).Emissivity.EarthPts, 0.9800          SW Earth (notch) emissivity
% d1.packet.ICT_Param.View_Factor.BeamSplitterWarm, 0.0860         View factor for warm portion of bs
% d1.packet.ICT_Param.View_Factor.BeamSplitterCold, 0.0080         View factor for cold portion of bs
% d1.packet.ICT_Param.View_Factor.ScanBaffle, 0.5080               View factor for scan mirror baffle
% d1.packet.ICT_Param.View_Factor.ICTBaffle, 0.1750                View factor for ICT baffle
% d1.packet.ICT_Param.View_Factor.OMAandFrame, 0.2140              View factor for OMA and Frame
% d1.packet.ICT_Param.View_Factor.OMA, 0.0590                      View factor for OMA (not used)
% d1.packet.ICT_Param.View_Factor.Frame, 0.1450                    View factor for Frame
% d1.packet.ICT_Param.View_Factor.Other, 0.0100                    View factor for Other
% d1.packet.ICT_Param.View_Factor.Space, 0.0090                    View factor for Space
% d1.packet.ICT_Param.Earth_Temperature, 288   
% d1.packet.ICT_Param.Scan_Baffle_Temp_Orbit                       SSM Baffle Temperature offset vs orbit time
% d1.packet.ICT_Param.Orbital_Period

% Spectral band
switch upper(band)
case 'LW'
  iband = 1;
case 'MW'
  iband = 2;
case 'SW'
  iband = 3;
end

% ICT emissivity
if eFlag == 1        % Pull from 4-min-eng packet;
  e_ICT = ICT_Param.Band(iband).ICT.EffEmissivity.Pts;
  % Note that if using the sensor wavenumber grid that these emissivity curves should be 
  % shifted to sensor grid (not implemented)

elseif eFlag == 0;   % user input
  e_ICT = eICT;

end

% SSM Baffle Offset
if ssmFlag == 1   % Pull offsets from 4-min-eng-packet and interpolate to this time in the orbit.

  % IF we have geolocation information, this could be implemented more robustly.  Currently uses a 
  % hard-coded North pole crossing time and the orbital period to compute the "orbit time".  Could/should 
  % be changed to compute the latest North pole crossing time using the TLE and nagivation sw.

  % north_pole_dnum = datenum(2011,11,11,6,23,13.4);   % this was obtained from running Fred' code "when" for the north pole. DCT 11-Nov-2011
  % north_pole_dnum = datenum(2011,11,20,11,48,53.6);   % this was obtained from running Fred' code "when" for the north pole. DCT 21-Nov-2011
  north_pole_dnum = datenum(2011,11,30,22,16,56.5);   % this was obtained from running Fred' code "when" for the north pole. DCT 01-Dec-2011

  %  orbit_period = ICT.Param.Orbital_Period;
  %  orbit_period = 6084.8727;   % From running when for NP crossing times, DCT 21-Nov-2011.  Orbit altitude is 835.9 km
  %  orbit_period = 6089.8000;   % From running when for NP crossing times, DCT 01-Dec-2011.  Orbit altitude is 840.7 km
  %  It is more accurate to compute the orbit period directly from the #-of-orbits-per-day, which is contained directly in the
  %  TLE files:
  orbits_per_day = 14.1956987;   % From NPP TLE generated on http:flo.ssec.wisc.edu/orbnav/ on 01-Dec-2011 with Epoch of TLE params: 30-Nov-2011
  seconds_per_day = 24*60*60;
  orbit_period = seconds_per_day/orbits_per_day;

  % CHECK ABOVE vs. ICT_Param.Orbital_Period when have real data with updated Eng.Packet (v32), and use ICT_Param value if ok.

  % Now compute the "orbit_time" - seconds since last North Pole crossing:
  orbit_time = mod((north_pole_dnum - T_CRIS.dnum)*seconds_per_day,orbit_period);

  % Orbit time values corresponding to the SSM Baffle Temp offset taken from the ATBD.  
  % I've added another (last) point at orbit_period.
  orbit_time_vector = [0 288.6 577.1 865.7 1154.3 1442.9 1731.4 2020 2308.6 2597.1 2885.7 3174.3 ...
                        3462.9 3751.4 4040 4328.6 4617.1 4905.7 5194.3 5482.9 5771.4 orbit_period];

  % Offset values from 4-min-eng packet.  I've repeated the first point again as the last point.
  Offsets = [ICT_Param.Scan_Baffle_Temp_Orbit ; ICT_Param.Scan_Baffle_Temp_Orbit(1)];

  T_ScanBaffleCorrection = interp1(orbit_time_vector,Offsets,orbit_time,'spline');

elseif ssmFlag == 0    % user input
  T_ScanBaffleCorrection = ssmOffset;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ICT emission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B.emitted = e_ICT .* bt2rad(wn,T_ICT);
B.e_ICT = e_ICT;
B.T_ICT = T_ICT;
B.wn = wn;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reflected term 1: SSM Baffle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e.SSM_Baffle = ICT_Param.Band(iband).Emissivity.ScanBafflePts;  % [1]
r.SSM = 1;				                        % SSM Reflectivity
V.SSM_Baffle = ICT_Param.View_Factor.ScanBaffle;                %[0.5080]
T.SSM_Baffle = T_CRIS.SSM_scan_mirror_baffle + T_ScanBaffleCorrection;
B.SSM_Baffle = e.SSM_Baffle * V.SSM_Baffle .* bt2rad(wn,T.SSM_Baffle);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reflected term 2:  ICT Baffle 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V.ICT_baffle = ICT_Param.View_Factor.ICTBaffle;       % [0.1750]
e.ICT_baffle = ICT_Param.Band(iband).Emissivity.ICT_BafflePts;  % [1] 
T.ICT_baffle = T_ICT;
B.ICT_baffle = e.ICT_baffle * V.ICT_baffle .* bt2rad(wn,T.ICT_baffle);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reflected term 3a,b,c:  OMA, frame, other, Beamsplitter Warm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V.OMA = ICT_Param.View_Factor.OMA + ICT_Param.View_Factor.Other;  % [0.0590 + 0.0100]
e.OMA = ICT_Param.Band(iband).Emissivity.HousingPts;              % [1]
T.OMA = mean(0.5*T_CRIS.OMA_structure_input_1 + 0.5*T_CRIS.OMA_structure_input_2);
B.OMA = e.OMA * r.SSM * V.OMA .* bt2rad(wn,T.OMA);

V.Frame = ICT_Param.View_Factor.Frame;          % [0.1450]
e.Frame = ICT_Param.Band(iband).Emissivity.HousingPts;  % [1]
T.Frame = T.OMA;
B.Frame = e.Frame * r.SSM * V.Frame .* bt2rad(wn,T.Frame);

V.BS_warm = ICT_Param.View_Factor.BeamSplitterWarm;  % [0.0860]
e.BS_warm = 1;
T.BS_warm = T.OMA;
B.BS_warm = e.BS_warm * r.SSM * V.BS_warm .* bt2rad(wn,T.BS_warm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reflected term 4:  Beamsplitter Cold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V.BS_cold = ICT_Param.View_Factor.BeamSplitterCold;    % [0.0080]
B.BS_cold = r.SSM^2 .* 0.5 * V.BS_cold .* bt2rad(wn,T_ICT);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Reflected term 5:  Space/Earth View 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V.Space = ICT_Param.View_Factor.Space;   % [0.0090]
e.Space = ICT_Param.Band(iband).Emissivity.EarthPts;   % [0.9800]
T.Space = ICT_Param.Earth_Temperature;      % [288]
B.Space = V.Space .* e.Space .* bt2rad(wn,T.Space);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% total reflected radiance into ICT cavity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V.SSM_Baffle + V.ICT_baffle + V.OMA + V.Frame + V.BS_warm + V.BS_cold + V.Space

B.reflected = B.SSM_Baffle + B.ICT_baffle + B.OMA + B.Frame + B.BS_warm + B.BS_cold + B.Space;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Total radiance from ICT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

B.total = B.emitted + (1 - e_ICT) .* B.reflected;

B.wn = wn;
B.V = V;
B.e = e;
B.T = T;


