%
% fp_v33a - SPNN focal plane values from Larrabee's v33a
%

function [foax, frad] = fp_v33a(band)

% off-axis angles (listed in row order)
switch upper(band)
  case 'LW'
    foax = [0.02688708 0.01931040 0.02745719 ...
            0.01872599 0.00039304 0.01946177 ...
            0.02669410 0.01898521 0.02720102]';
  case 'MW'  
    foax = [0.02692817  0.01932544  0.02744433 ...
            0.01877022  0.00041968  0.01943880 ...
            0.02670933  0.01897094  0.02714583]';
  case 'SW'  
    foax = [0.02687735  0.01928389  0.02737835 ...
            0.01875077  0.00034464  0.01935134 ...
            0.02671876  0.01895481  0.02709675]';
end

% FOV radius
frad = 0.008403 * ones(9,1);

