%
% NAME
%   scipack - process science packet data
%
% SYNOPSIS
%   [sci, eng] = scipack(d1, eng1)
%
% INPUTS
%   d1   - output structure from MIT reader
%   eng1 - previous eng packet
%
% OUTPUTS
%   sci  - calculated and saved sci packet data
%   eng  - up to date eng packet
%
% DISCUSSION
%   the prev eng packet is passed in because some RDR reads may 
%   not include any eng data
%

function [sci, eng] = scipack(d1, eng1)

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% field names for eng packet cleanup.  These are igm time fields
% added by the MIT reader, not part of the actual eng packet data
ftmp = ['LWES';'MWES';'SWES';'LWIT';'MWIT';'SWIT';'LWSP';'MWSP';'SWSP'];

% if we have good eng (4-min) data remove non eng packet fields 
% and convert time back to IET
if d1.packet.read_four_min_packet && ~d1.packet.error
  eng = rmfield(d1.packet, ftmp);
  eng.four_min_eng.time = eng.four_min_eng.time * mwt;
else
  eng = eng1;
end

% if no eng data just return, the temp functions below need this
if isempty(eng)
  sci = struct([]);
  return
end

nsci = ztail(d1.data.sci.Temp.time);
sci = struct();
sci.time = mwt * d1.data.sci.Temp.time(1:nsci);
sci = soa2aos(sci);

% hack the current MIT reader structure to guarantee it contains a
% valid eng packet for Dave T's procedures
d1.packet = eng;

% Compute ICT temps
ict_temps = ICT_countsToK(d1.data.sci.Temp, ...
                          d1.packet.TempCoeffs, ...
                          nsci);

% Compute other instr temps
instr_temps = calc_instrument_temps(d1.data.sci.Temp.Temp, ...
                                    d1.packet.TempCoeffs, ...
                                    nsci);

% Create array of structures
sci = soa2aos(ict_temps, sci);
sci = soa2aos(instr_temps, sci);

% keep sci sorted by time
[t, ix] = sort([sci.time]);
sci = sci(ix);

