
function [BitTrimBitsRetained, BitTrimIndex, BitTrimNpts] = btrim_lowres

BitTrimBitsRetained = ...
  [ 12    13    10
    13    14    10
    12    17    15
    13    14    10
    13    13    10
    18     2     2
    13     2     2
    13     2     2
    12     2     2
    13     2     2
    12     2     2
     2     2     2
     2     2     2
     2     2     2
     2     2     2
     2     2     2 ];

BitTrimIndex = ...
 [  30   134    42
   137   209    77
   298   315   125
   352   390   161
   406   530   202
   459   530   202
   514   530   202
   567   530   202
   728   530   202
   835   530   202
   866   530   202
   866   530   202
   866   530   202
   866   530   202
   866   530   202
   866   530   202 ];

BitTrimNpts = max(BitTrimIndex);

