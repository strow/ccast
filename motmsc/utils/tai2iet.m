% 
%  take AIRS TAI to IET
%

function iet = tai2iet(tai)

% seconds between 1 Jan 1958 and 1 Jan 2000
tdif = 15340 * 24 * 3600;

iet = (tai + tdif) * 1e6;

