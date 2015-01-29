%
% take RTP TAI 58 to matlab date numbers
%

function dn = tai2mat(tai58)

dn =  datenum('1 Jan 1958') + tai2utc(tai58) / (24 * 60 * 60);

