% 
%  take IET to AIRS TAI
%

function tai = iet2tai(iet)

% seconds between 1 Jan 1958 and 1 Jan 2000
tdif = 15340 * 24 * 3600;

tai = iet * 1e-6 - tdif;

