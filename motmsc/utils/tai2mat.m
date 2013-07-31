%
% take AIRS TAI to matlab serial date numbers
%

function sdn = tai2mat(tai)

spd = 86400;    % seconds per day

sdn = datenum('1 Jan 2000') + tai / spd;

