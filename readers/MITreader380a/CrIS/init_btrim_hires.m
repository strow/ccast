
function [BitTrimBitsRetained, BitTrimIndex, BitTrimNpts] = init_btrim_hires

BitTrimBitsRetained = ...
  [ 11    10     8
    13    11     9
    12    12     8
    13    16     9
    18    12    10
    13    11    15
    12    10    10
    13     2     9
    11     2     8
     2     2     9
     2     2     8
     2     2     2
     2     2     2
     2     2     2
     2     2     2
     2     2     2 ];

BitTrimIndex = ...
 [  50   116    90
    91   316   144
   375   509   239
   421   543   320
   445   736   375
   491   936   424
   775  1052   479
   816  1052   560
   866  1052   655
   866  1052   709
   866  1052   799
   866  1052   799
   866  1052   799
   866  1052   799
   866  1052   799
   866  1052   799 ];

BitTrimNpts = max(BitTrimIndex);

