%read_packet_spacecraft_diary\

% rememaining paclet length=65-8=57 bytes
packet_counter.diary_data = packet_counter.diary_data + 1;
diary_data.pacseq(packet_counter.diary_data) = header.packet_sequence;
diary_data.seqnum(packet_counter.diary_data) = header.sequence_number;

% store the UTC time codes read in read_headers
diary_data.day(packet_counter.diary_data)=header.days;
diary_data.msec_of_day(packet_counter.diary_data)=header.msec_of_day;
diary_data.usec_of_msec(packet_counter.diary_data)=header.usec_of_msec;

% (1 byte)
diary_data.spacecraft_id(packet_counter.diary_data) = fread(fid,1,'uint8');

% read the Ephemeris Valid Time (8 bytes)
[diary_data.ephemeris_day(packet_counter.diary_data), ...
    diary_data.ephemeris_msec_of_day(packet_counter.diary_data), ...
    diary_data.ephemeris_usec_of_msec(packet_counter.diary_data)] = read_utc(fid);

% Ephemeris Position (12 bytes)
diary_data.position_x(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.position_y(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.position_z(packet_counter.diary_data) = fread(fid,1,'float32');

% Ephemeris Velocity (12 bytes)
diary_data.velocity_x(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.velocity_y(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.velocity_z(packet_counter.diary_data) = fread(fid,1,'float32');

% read the Attitude Valid Time(8 bytes)
[diary_data.attitude_day(packet_counter.diary_data), ...
    diary_data.attitude_msec_of_day(packet_counter.diary_data), ...
    diary_data.attitude_usec_of_msec(packet_counter.diary_data)] = read_utc(fid);

% Control Frame Attitude (16 bytes)
diary_data.CFA_Q1(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.CFA_Q2(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.CFA_Q3(packet_counter.diary_data) = fread(fid,1,'float32');
diary_data.CFA_Q4(packet_counter.diary_data) = fread(fid,1,'float32');

