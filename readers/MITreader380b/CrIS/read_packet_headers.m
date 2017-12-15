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

function err=read_packet_headers

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
  
% Set up some constants
is_not_eof=0;  
% PACKET_SEQUENCE_FLAGS_MASK = uint16(hex2dec('C000'));
% PACKET_SEQUENCE_COUNT_MASK = uint16(hex2dec('3FFF'));
PACKET_SEQUENCE_FLAGS_MASK = uint16(49152);
PACKET_SEQUENCE_COUNT_MASK = uint16(16383);
% VERSION_MASK = uint16(hex2dec('E000'));
% TYPE_INDICATOR_MASK = uint16(hex2dec('1000'));
% SECONDARY_HEADER_FLAG_MASK = uint16(hex2dec('0800'));
% APID_MASK = uint16(hex2dec('07FF'));
SECONDARY_HEADER_FLAG_MASK = uint16(2048);
APID_MASK = uint16(2047);

% PRIMARY HEADER
err=0;
first_word = fread(fid,1,'uint16=>uint16');
   if feof(fid), err=01; return; end
%  if feof(fid);disp('read_packet_primary_header: eof reading first header first word');err=01;return;end
%  Version=bitshift(bitand(first_word,VERSION_MASK),-13);
%  Type_indicator=bitshift(first_word,TYPE_INDICATOR_MASK,-12);
   Secondary_header_flag=bitshift(bitand(first_word,SECONDARY_HEADER_FLAG_MASK),-11);
   header.apid = bitand(first_word, APID_MASK);
   
second_word = fread(fid,1,'uint16=>uint16');
   if feof(fid);disp('read_packet_primary_header: eof reading first header second word');err=02;return;end
   header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_FLAGS_MASK),-14);
   header.sequence_number =  bitand(second_word, PACKET_SEQUENCE_COUNT_MASK);
   
third_word = fread(fid,1,'uint16')+1; % one added to correct hard coding 
   header.packet_length=third_word; % number of bytes in the rest of the packet.
   
if feof(fid);disp('read_packet_primary_header: eof reading first header third word');err=03;return;end 

% SECONDARY HEADER

header.time=timeval;
header.Secondary_header_flag=Secondary_header_flag;
if Secondary_header_flag
    time_words=fread(fid,4,'uint16');
    if ~feof(fid)
    header.days=time_words(1);
    header.msec_of_day=(time_words(2)*2^16+time_words(3));
    header.usec_of_msec=time_words(4);
    seconds=(header.msec_of_day+ header.usec_of_msec*1.e-3)*1.e-3;
%   timeval=datenum(0,0,header.days,0,0,seconds);
    timeval = header.days + seconds / 86400;
    header.time=timeval;
    else
    disp('read_packet_headers: error reading Secondary header');err=4;return;   
    end
end

    if VERBOSE
       disp(['Read_packet_headers for APID =',num2str(header.apid),' ',num2str(header.packet_length),' ',num2str(header.packet_sequence),' ',num2str(header.sequence_number)])
    end
