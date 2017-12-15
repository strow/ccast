
function bittrim_update

global packet

for b = 1 : 3
   packet.BitTrimIndex(:, b)         = packet.BitTrimMask.Band(b).Index;
   packet.BitTrimBitsRetained(:, b)  = packet.BitTrimMask.Band(b).StopBit ...
                                     - packet.BitTrimMask.Band(b).StartBit + 1;
end
packet.BitTrimNpts = max(packet.BitTrimIndex);

