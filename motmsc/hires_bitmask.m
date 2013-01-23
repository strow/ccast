
function [mask, bmax, bmin] = hires_bitmask(band)

switch upper(band)
  case 'LW'
    mask = ones(866,1) * NaN;
    mask(1:30)     = 12;
    mask(31:137)   = 13;
    mask(138:298)  = 12;
    mask(299:352)  = 13;
    mask(353:406)  = 13;
    mask(407:459)  = 18;
    mask(460:514)  = 13;
    mask(515:567)  = 13;
    mask(568:728)  = 12;
    mask(729:835)  = 13;
    mask(836:866)  = 12;
  case 'MW'
    mask = ones(1039,1) * NaN;
    mask(1:263)    = 17;
    mask(264:410)  = 17;
    mask(411:617)  = 18;
    mask(618:764)  = 17;
    mask(765:1039) = 17;
  case 'SW'
    mask = ones(799,1) * NaN;
    mask(1:166)    = 22;
    mask(167:305)  = 22;
    mask(306:494)  = 23;
    mask(495:637)  = 22;
    mask(638:799)  = 22;
  otherwise
     error(sprintf('bad band parameter %s', band))
end

bmax = 2.^(mask-1)-1;
bmin = -2.^(mask-1);

