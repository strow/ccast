%
%        (c) Copyright 2004 Massachusetts Institute of Technology
%
%        In no event shall M.I.T. be liable to any party for direct, 
%        indirect, special, incidental, or consequential damages arising
%        out of the use of this software and its documentation, even if
%        M.I.T. has been advised of the possibility of such damage.
%          
%        M.I.T. specifically disclaims any warranties including, but not
%        limited to, the implied warranties of merchantability, fitness
%        for a particular purpose, and non-infringement.
%
%        The software is provided on an "as is" basis and M.I.T. has no
%        obligation to provide maintenance, support, updates, enhancements,
%        or modifications.

function read_packet_SWIT_data
% Read SWIT DSP packet 
% (c) Copyright 2004 Massachusetts Institute of Technology

global fid VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

FOV = header.apid-1386;
packet_counter.SWIT(FOV) = packet_counter.SWIT(FOV) + 1;
packet.SWIT.time(packet_counter.SWIT(FOV),FOV)=timeval;

% PCE application FSW Version and Instrument ID
first_word = fread(fid, 1 , 'uint16=>uint16');
% PCD_app_FSW_ver=bitshift(bitand(first_word, uint16(hex2dec('FFE0')) ),-5);
% Inst_ID = bitand(first_word, uint16(hex2dec('001F')) );

% Scan information
% scan_direction_mask=uint16(hex2dec('0300'))
% FOV_mask=uint16(hex2dec('FC00'))
scan_direction_mask=uint16(768);
FOV_mask=uint16(64512);
scan_information = fread(fid, 1, 'uint16=>uint16');
sweep_direction.SWIT(FOV, packet_counter.SWIT(FOV)) = bitshift( bitand(scan_information, scan_direction_mask ), -8);
FOR.SWIT(FOV,packet_counter.SWIT(FOV)) = bitshift( bitand(scan_information, FOV_mask ),-10);
header.FOR=FOR.SWIT(FOV,packet_counter.SWIT(FOV));

band=3;
data.ITflags.Scan_Status_Flags(band,FOV, packet_counter.SWIT(FOV))=bitshift(bitand(fread(fid,1,'uint16=>uint16'),  uint16(65408)),-7);% uint16(hex2dec('ff80'))  
data.ITflags.Impulse_Noise_Count(band,FOV, packet_counter.SWIT(FOV))=bitshift(bitand(fread(fid,1,'uint16=>uint16'),  uint16(1023)),-6); % uint16(hex2dec('03ff'))
data.ITflags.ZPD_Amplitude(band,FOV, packet_counter.SWIT(FOV))=bitand(fread(fid,1,'uint16=>uint16'), uint16(1023)); % uint16(  hex2dec('03ff')  )
data.ITflags.ZPD_Location(band,FOV, packet_counter.SWIT(FOV))=single(fread(fid,1,'uint16=>uint16'));
data.ITflags.Number_of_Convert_Pulses(band,FOV, packet_counter.SWIT(FOV))=single(fread(fid,1,'uint16=>uint16'));
data.ITflags.Filter_Status_Upper_Register(band,FOV, packet_counter.SWIT(FOV))=fread(fid,1,'uint16=>uint16');
data.ITflags.Filter_Status_Lower_Register(band,FOV, packet_counter.SWIT(FOV))=fread(fid,1,'uint16=>uint16');
data.ITflags.Num_I_Words_After_Bit_Trimming(band,FOV, packet_counter.SWIT(FOV))=fread(fid,1,'uint16=>uint16');
% fread(fid,8,'uint16');

% idata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
% idata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW(idata_packed);       
% qdata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
% qdata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW(qdata_packed);

if header.packet_length==496
idata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
idata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW496(idata_packed);
qdata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
qdata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW496(qdata_packed);
elseif header.packet_length==596
idata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
idata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW596(idata_packed);
qdata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
qdata.SWIT(1:202,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW596(qdata_packed);
elseif header.packet_length==3272       
idata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
idata.SWIT(1:799,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW3272(idata_packed);
qdata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
qdata.SWIT(1:799,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW3272(qdata_packed);
elseif header.packet_length==4472       
idata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
idata.SWIT(1:799,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW4472(idata_packed);
qdata_packed = fread(fid,(header.packet_length-28)/4,'uint16');
qdata.SWIT(1:799,FOV,packet_counter.SWIT(FOV)) = bit_unpack_SW4472(qdata_packed);
else
    disp(['packet_length = ', num2str(header.packet_length),', NO BIT_UNPACK AVAIABLE FOR SW'])
end

if VERBOSE
v=datevec(timeval);
fprintf('Found PACKET %d (%x hex) sec=  %12.6f .\n', header.apid, header.apid,v(5)*60+v(6));
end  