%
% MIT readers stripped down to basic CCSDS packet parser
%
% the code here is mostly from v380, but the flow is taken from 
% a much earlier 2008 version that I called 5a at the time
%

cfile = input('ccsds file > ', 's')

fid = fopen(cfile, 'rb','b')
if fid == -1
  error(sprintf('can''t open %s', cfile))
end

% from read_packet_headers.m 
PACKET_SEQUENCE_FLAGS_MASK = uint16(49152);
PACKET_SEQUENCE_COUNT_MASK = uint16(16383);
VERSION_MASK = uint16(hex2dec('E000'));
SECONDARY_HEADER_FLAG_MASK = uint16(2048);
APID_MASK = uint16(2047);

j = 0;
while 1;

  first_word = fread(fid,1,'uint16=>uint16');
  if feof(fid), disp('end of input file'), break, end
  Version=bitshift(bitand(first_word,VERSION_MASK),-13);
  Secondary_header_flag=bitshift(bitand(first_word,SECONDARY_HEADER_FLAG_MASK),-11);
  apid = bitand(first_word, APID_MASK);

  second_word = fread(fid,1,'uint16=>uint16');
  sequence_flags =  bitshift(bitand(second_word, PACKET_SEQUENCE_FLAGS_MASK),-14);
  sequence_number =  bitand(second_word, PACKET_SEQUENCE_COUNT_MASK);
   
  third_word = fread(fid,1,'uint16');
  packet_length=third_word + 1; % number of bytes in the rest of the packet.

  fprintf(1, 'version %d, type x, sec_head_flag %d, APID %d\n', ...
          Version, Secondary_header_flag, apid); 

  fprintf(1, 'seq_flags %d, seq_count %d, length %d\n', ...
          sequence_flags, sequence_number, packet_length);

  if Secondary_header_flag
    time_words=fread(fid,4,'uint16');
    packet_length = packet_length - 8;
    day=time_words(1);
    msec_of_day=(time_words(2)*2^16+time_words(3));
    usec_of_msec=time_words(4);
    seconds=(msec_of_day+ usec_of_msec*1.e-3)*1.e-3;
    timeval=datenum([0,0,days,0,0,seconds]);
    fprintf(1, 'day %d, ms %d, us %d\n', day, msec_of_day, usec_of_msec)
%   fprintf(1, '%s\n', datestr(timeval+715146));
  end

  tx = fread(fid, packet_length, 'uint8');

  j = j + 1;
end

fclose(fid);

fprintf(1, '%d packets read\n', j);


