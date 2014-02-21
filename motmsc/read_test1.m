% 
% misc MIT reader tests
% cut and paste as needed 
%

% this is needed clear persistent globals
clear all

% regular res sample
% f1 = '/asl/data/cris/rdr60/hdf/2013/225/RCRIS-RNSCA_npp_d20130813_t0736579_e0744578_b09292_c20130813134522204791_noaa_ops.h5';
% f1 = '/asl/data/cris/rdr60/hdf/2013/020/RCRIS-RNSCA_npp_d20130120_t0812383_e0820383_b06384_c20130120142103778225_noaa_ops.h5';

% high res v1 sample
% f1 = '/asl/data/cris/rdr60/hdf/2013/071/RCRIS-RNSCA_npp_d20130312_t2013411_e2021411_b07114_c20130313022159445397_noaa_ops.h5';
  f1 = '/asl/data/cris/rdr60/hdf/2013/071/RCRIS-RNSCA_npp_d20130312_t2157406_e2205405_b07115_c20130313040600483416_noaa_ops.h5';

% high res v2 sample (won't work with old reader)
% f1 = '/asl/data/cris/rdr60/hires/2013/239/RCRIS-RNSCA_npp_d20130827_t2238594_e2246593_b09499_c20130828044725882955_noaa_ops.h5';
% f1 = '/asl/data/cris/rdr60/hires/2013/240/RCRIS-RNSCA_npp_d20130828_t0350576_e0358576_b09502_c20130828095921068505_noaa_ops.h5';

% old reader
addpath /home/motteler/cris/ccast/readers/MITreader380
which read_cris_hdf5_rdr
rdrpak = 'rdrpak.dat';
[d1, m1] = read_cris_hdf5_rdr(f1, 'rdrpak.dat')
delete(rdrpak)

% modified reader
addpath /home/motteler/cris/ccast/readers/MITreader380a
which read_cris_hdf5_rdr
rdrpak = 'rdrpak.dat';
% [d2, m2] = read_cris_hdf5_rdr(f1, 'rdrpak.dat', 'btrim_hires1.mat')
[d2, m2] = read_cris_hdf5_rdr(f1, 'rdrpak.dat')
delete(rdrpak)

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

