% 
% misc MIT reader tests
% cut and paste as needed 
%

% regular res sample
f1 = '/asl/data/cris/rdr60/hdf/2013/225/RCRIS-RNSCA_npp_d20130813_t0736579_e0744578_b09292_c20130813134522204791_noaa_ops.h5'

% old reader
addpath /home/motteler/cris/MITreader380
[d1, m1] = read_cris_hdf5_rdr(f1)

% modified reader
addpath /home/motteler/cris/MITreader380a
[d2, m2] = read_cris_hdf5_rdr(f1)

% check reader versions
~isfield(d1.packet, 'BitTrimNpts')
isfield(d2.packet, 'BitTrimNpts')

% compare reader results
isequal(d1.idata, d2.idata)
isequal(d1.qdata, d2.qdata)

return

% ----------------------------------------
% get bit trim values for bit_unpack_all.c
% ----------------------------------------

% addpath /home/motteler/cris/MITreader380a
% addpath /home/motteler/cris/MITreader380

% high res sample data
% f1 = '/asl/ftp/incoming/CRIS/RCRIS-RNSCA_npp_d20130827_t2326591_e2334591_b09500_c20130828053522424990_noaa_ops.h5'

% regular res sample
f1 = '/asl/data/cris/rdr60/hdf/2013/225/RCRIS-RNSCA_npp_d20130813_t0736579_e0744578_b09292_c20130813134522204791_noaa_ops.h5'

[d1, m1] = read_cris_hdf5_rdr(f1)

BitTrimMask = d1.packet.BitTrimMask;

for band = 1 : 3

  BitTrimIndex(:,band) = BitTrimMask.Band(band).Index;

  BitTrimBitsRetained(:,band) = BitTrimMask.Band(band).StopBit - BitTrimMask.Band(band).StartBit+1;
end

whos BitTrimIndex BitTrimBitsRetained 

return

% -----------------------------
% high res explicit assignments
% -----------------------------

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
     [    50         116          90
          91         316         144
         375         509         239
         421         543         320
         445         736         375
         491         936         424
         775        1052         479
         816        1052         560
         866        1052         655
         866        1052         709
         866        1052         799
         866        1052         799
         866        1052         799
         866        1052         799
         866        1052         799
         866        1052         799 ];

