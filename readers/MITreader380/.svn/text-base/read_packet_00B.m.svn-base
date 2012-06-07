%        (c) Copyright 2011 Massachusetts Institute of Technology
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

packet_id = 15;
packet_counter(packet_id) = packet_counter(packet_id) + 1;
byte_counter = byte_counter + header.packet_length + 7;
if VERBOSE
    fprintf('Found DIARY PACKET             (%3d percent complete). %d', floor(100*byte_counter/filelength), header.sequence_number);
else
    progress = floor(100*byte_counter/filelength);
    if PROGRESS_COUNTER(progress+1)
        PROGRESS_COUNTER(progress+1) = 0;
        fprintf('%d percent complete.\n', progress);
    end
end
diary_data.scan_counter = diary_data.scan_counter + 1;
diary_data.pacseq(diary_data.scan_counter) = header.packet_sequence;
diary_data.seqnum(diary_data.scan_counter) = header.sequence_number;

% read the UTC time codes
[diary_data.day(diary_data.scan_counter), diary_data.msec_of_day(diary_data.scan_counter), diary_data.usec_of_msec(diary_data.scan_counter)] = read_utc(fid);

diary_data.spacecraft_id(diary_data.scan_counter) = fread(fid,1,'uint8');

% read the Ephemeris Valid Time
[diary_data.ephemeris_day(diary_data.scan_counter), ...
    diary_data.ephemeris_msec_of_day(diary_data.scan_counter), ...
    diary_data.ephemeris_usec_of_msec(diary_data.scan_counter)] = read_utc(fid);

% Ephemeris Position
diary_data.position_x(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.position_y(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.position_z(diary_data.scan_counter) = fread(fid,1,'float32');

% Ephemeris Velocity
diary_data.velocity_x(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.velocity_y(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.velocity_z(diary_data.scan_counter) = fread(fid,1,'float32');

% read the Attitude Valid Time
[diary_data.attitude_day(diary_data.scan_counter), ...
    diary_data.attitude_msec_of_day(diary_data.scan_counter), ...
    diary_data.attitude_usec_of_msec(diary_data.scan_counter)] = read_utc(fid);

% Control Frame Attitude
diary_data.CFA_Q1(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.CFA_Q2(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.CFA_Q3(diary_data.scan_counter) = fread(fid,1,'float32');
diary_data.CFA_Q4(diary_data.scan_counter) = fread(fid,1,'float32');

