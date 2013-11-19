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

function read_packet_MWDIA_data
% Read MW Diag packet 
% (c) Copyright 2004 Massachusetts Institute of Technology

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
channel=[99 0 0 0 0 0 0 0 0 ,...
         0 0 9 0 0 0 0 0 0 ,...
         0 5 6 7 8 1 2 3 4 ];               

packet_counter.MWDIA = packet_counter.MWDIA + 1;
packet.MWDIA.time(packet_counter.MWDIA)=timeval;
        
% PCE application FSW Version and Instrument ID
first_word=fread(fid,1,'uint16=>uint16');
% PCD_app_FSW_ver=bitshift(bitand(first_word, uint16(hex2dec('FFE0')) ),-5);
% Inst_ID = bitand(first_word, uint16(hex2dec('001F')) );

% Scan information
scan_information = fread(fid,1,'uint16');
sweep_direction.MWDIA(packet_counter.MWDIA) = bitshift( bitand(scan_information,uint16(hex2dec('0300')) ),-8);
FOR.MWDIA(packet_counter.MWDIA) = bitshift( bitand(scan_information,uint16(hex2dec('FC00')) ),-10);

Scan_Status_Flags=bitshift(bitand(fread(fid,1,'uint16=>uint16'),uint16(hex2dec('ff80'))),-7);
Impulse_Noise_Count=bitshift(bitand(fread(fid,1,'uint16=>uint16'),uint16(hex2dec('03ff'))),-6);
ZPD_Amplitude=bitshift(bitand(fread(fid,1,'uint16=>uint16'),uint16(hex2dec('ffc0'))),-6);
ZPD_Location=single(fread(fid,1,'uint16=>uint16'));
Number_of_Convert_Pulses=single(fread(fid,1,'uint16=>uint16'));
Filter_Status_Upper_Register=fread(fid,1,'uint16=>uint16');
Filter_Status_Lower_Register=fread(fid,1,'uint16=>uint16');
Num_I_Words_After_Bit_Trimming=fread(fid,1,'uint16=>uint16');

Diagnostic_channel_mask=uint16(hex2dec('07C0'));   
channel_idx=bitshift(bitand(Diagnostic_channel_mask,Filter_Status_Upper_Register),-6);
header
disp(['in MWDIA, channel index = ',num2str(channel_idx)])
if channel_idx==0;
    channel_idx=1;
end
data.MW.channel(packet_counter.MWDIA)=channel(channel_idx);
data.MW.mode_bit(packet_counter.MWDIA)=single(bitget(Filter_Status_Upper_Register,11));        

if data.read.diag_intergerograms==1
    diagint.MW.int(:, packet_counter.MWDIA) = fread(fid,(header.packet_length-24)/2,'int16=>int16');
else
    dum=fread(fid,(header.packet_length-24)/2,'int16=>int16');
end
       
if VERBOSE
v=datevec(timeval);
fprintf('Found PACKET %d (%x hex) sec=  %12.6f .\n', header.apid, header.apid,v(5)*60+v(6));
end  
