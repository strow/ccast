%
% take CrIS IET time to matlab date numbers
%

function dn = iet2mat(iet)

dn = tai2mat(iet * 1e-6);

