%
% take UTC 58 to matlab date numbers
%

function dn = utc2mat(utc58)

dn =  datenum('1 Jan 1958') + utc58 / (24 * 60 * 60);

