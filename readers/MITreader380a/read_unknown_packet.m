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
second_word = fread(fid,1,'uint16');
header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
header.packet_length = fread(fid,1,'uint16');	  
if VERBOSE
    fprintf('**** Unknown packet ID (code 1): %d (%x hex), packet length = %d ****\n', header.apid, header.apid, header.packet_length);
end
num_errors = num_errors + 1;
GOOD_PACKETS = 0;
byte_counter = byte_counter + header.packet_length+7;
fread(fid,header.packet_length+1,'uint8');	

unknown_packets = unique([unknown_packets header.apid]);
