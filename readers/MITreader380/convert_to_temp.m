%
%      (c) Copyright 2011 Massachusetts Institute of Technology
%
%      In no event shall M.I.T. be liable to any party for direct, 
%      indirect, special, incidental, or consequential damages arising
%      out of the use of this software and its documentation, even if
%      M.I.T. has been advised of the possibility of such damage.
%          
%      M.I.T. specifically disclaims any warranties including, but not
%      limited to, the implied warranties of merchantability, fitness
%      for a particular purpose, and non-infringement.
%
%      The software is provided on an "as is" basis and M.I.T. has no
%      obligation to provide maintenance, support, updates, enhancements,
%      or modifications.
%
% Accepts uint8 count and conversion coefficients, returns deg C.
function temp = convert_to_temp(count, c)

if (exist('c', 'var')==0 || exist('count','var')==0)
    error('Required value missing.');
end

switch length(c)
    case 2
        temp = c(1) + (c(2)*count);
    case 3
        temp = c(1) + (c(2)*count) + (c(3)*(count^2.0));
    case 4
        temp = c(1) + (c(2)*count) + (c(3)*(count^2.0)) ...
            + (c(4)*(count^3.0));
    case 5
        temp = c(1) + (c(2)*count) + (c(3)*(count^2.0)) ...
            + (c(4)*(count^3.0)) + (c(5)*(count^4.0));
    case 6
        temp = c(1) + (c(2)*count) + (c(3)*(count^2.0)) ...
            + (c(4)*(count^3.0)) + (c(5)*(count^4.0)) + (c(6)*(count^5.0));
    otherwise
        error('Unable to calculate temp');
end

end