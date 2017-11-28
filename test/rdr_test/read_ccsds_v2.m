%
% MIT readers stripped down to basic CCSDS packet parser
%
% the code here is mostly from v380, but the flow is taken from 
% a much earlier 2008 version that I called 5a at the time
%

% MIT hooks
addpath ../MITreader380a/CrIS

global fid VERBOSE timeval idata qdata data ...
       packet_counter packet header sweep_direction FOR diagint

initialize_packet_structures

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

  bx = bit_fields([11,1,1,3], first_word);
  if ~(apid == bx(1) && Secondary_header_flag == bx(2) && Version == bx(4)), keyboard, end

  second_word = fread(fid,1,'uint16=>uint16');
  sequence_flags =  bitshift(bitand(second_word, PACKET_SEQUENCE_FLAGS_MASK),-14);
  sequence_number =  bitand(second_word, PACKET_SEQUENCE_COUNT_MASK);
   
  bx = bit_fields([14,2], second_word);
  if ~(sequence_number == bx(1) && sequence_flags == bx(2)), keyboard, end

  third_word = fread(fid,1,'uint16');
  packet_length=third_word + 1; % number of bytes in the rest of the packet.

% fprintf(1, 'version %d, type x, sec_head_flag %d, APID %d\n', ...
%         Version, Secondary_header_flag, apid); 

% fprintf(1, 'seq_flags %d, seq_count %d, length %d\n', ...
%         sequence_flags, sequence_number, packet_length);

  if Secondary_header_flag
    time_words=fread(fid,4,'uint16');
    packet_length = packet_length - 8;
    days=time_words(1);
    msec_of_day=(time_words(2)*2^16+time_words(3));
    usec_of_msec=time_words(4);
    seconds=(msec_of_day+ usec_of_msec*1.e-3)*1.e-3;
    timeval=datenum([0,0,days,0,0,seconds]);
%   fprintf(1, 'day %d, ms %d, us %d\n', days, msec_of_day, usec_of_msec)
%   fprintf(1, '%s\n', datestr(timeval+715146));
  end

% keyboard

  % save header info in the MIT structs
  header.apid = apid;
  header.packet_sequence = sequence_flags;
  header.sequence_number = sequence_number;
  header.packet_length = packet_length;
  header.days = days;
  header.msec_of_day = msec_of_day;
  header.usec_of_msec = usec_of_msec;
  header.time = timeval;
  
  if apid == 1290
    read_packet_four_min_eng_data_rev11
    packet.read_four_min_packet = 1;
  elseif apid == 1289
    read_packet_eight_sec_science_data
  else
    % read the rest of the packet
    tx = fread(fid, packet_length, 'uint8');
  end

  j = j + 1;
end

fclose(fid);

fprintf(1, '%d packets read\n', j);


