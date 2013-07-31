%
% NAME
%   iet2mat - convert IET time to matlab serial date number
%
% SYNOPSIS
%   sdn = iet2mat(iet)
%
% INPUT
%   iet   - IET time, microseconds since 1 Jan 1958
%
% OUTPUT
%   sdn  - matlab serial date number
%
% DISCUSSION
%  IET is microseconds since 1 Jan 1958.  This is used in CrIS
%  products such as the GCRSO geo data.
%
%  CrIS internal time (from the RDR data) is milliseconds since 
%  1 Jan 1958, and is approximately 35 seconds behind real time.
%  More precisely, (GCRSO time) / 1000 - (RDR time) = 34817
%
% AUTHOR
%  H. Motteler, 1 Jun 2013
%

function sdn = iet2mat(iet)

msd = 8.64e7;   % milliseconds per day 
usd = 8.64e10;  % microseconds per day 

sdn = datenum('1-jan-1958') + iet / usd;

