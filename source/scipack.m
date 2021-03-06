%
% NAME
%   scipack - process science packet data
%
% SYNOPSIS
%   [sci, eng] = scipack(d1, engp)
%
% INPUTS
%   d1    - output from MIT reader
%   engp  - previous eng packet
%
% OUTPUTS
%   sci   - selected sci packet data
%   eng   - up-to-date full eng packet
%
% DISCUSSION
%   the prev eng packet is passed in because some RDR reads may not
%   include any eng data
%
%   sci.time and eng.four_min_eng.time are returned as UTC ms since
%   1958, as used by checkRDR.  sci.dnum is matlab datenums for the
%   same times
%

function [sci, eng] = scipack(d1, engp)

% ms/day, to convert UTC 1958 datenums to ms
mwt = 8.64e7;

% field names for eng packet cleanup.  These are igm time fields
% added by the MIT reader, not part of the actual eng packet data
fdel = ['LWES';'MWES';'SWES';'LWIT';'MWIT';'SWIT';'LWSP';'MWSP';'SWSP'];

% if we have good eng (4-min) data, remove non eng fields and
% convert time to UTC ms since 1958
if d1.packet.read_four_min_packet && ~d1.packet.error
  eng = rmfield(d1.packet, fdel);
  eng.four_min_eng.time = eng.four_min_eng.time * mwt;
else
  eng = engp;
end

% initialize sci to empty
sci = [];

% quit if no eng data
if isempty(eng)
  return
end

% quit if no sci data
nsci = ztail(d1.data.sci.Temp.time);
if isempty(nsci) || nsci == 0
  return
end

% return selected sci values
sci = struct;
sci.time = mwt * d1.data.sci.Temp.time(1:nsci);
sci = soa2aos(sci);

% Compute ICT temps
ict_temps = ICT_countsToK(d1.data.sci.Temp, eng.TempCoeffs, nsci);

% Compute other instr temps
instr_temps = ...
    calc_instrument_temps(d1.data.sci.Temp.Temp, eng.TempCoeffs, nsci);

% Create array of structures
sci = soa2aos(ict_temps, sci);
sci = soa2aos(instr_temps, sci);

% keep sci sorted by time
[t, ix] = sort([sci.time]);
sci = sci(ix);

