
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
%        or modifications.   second_word = fread(fid,1,'uint16');
second_word = fread(fid,1,'uint16');
header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
header.packet_length = fread(fid,1,'uint16');

packet_id = 5;
packet_counter(packet_id) = packet_counter(packet_id) + 1;
byte_counter = byte_counter + header.packet_length+7;
if VERBOSE
    fprintf('Found DIAGNOSTIC PACKET        (%3d percent complete).\n', floor(100*byte_counter/filelength));
else
    progress = floor(100*byte_counter/filelength);
    if PROGRESS_COUNTER(progress+1)
        PROGRESS_COUNTER(progress+1) = 0;
        fprintf('%d percent complete.\n', progress);
    end    
end

% Read Start of Scan UCT
diag_data.scan_counter = diag_data.scan_counter + 1;

% read the UTC time codes
[diag_data.day(diag_data.scan_counter), ...
    diag_data.msec_of_day(diag_data.scan_counter), ...
    diag_data.usec_of_msec(diag_data.scan_counter)] = read_utc(fid);

[diag_data.start_of_scan.day(diag_data.scan_counter) ...
    diag_data.start_of_scan.msec_of_day(diag_data.scan_counter) ...
    diag_data.start_of_scan.usec_of_msec(diag_data.scan_counter)] = read_utc(fid);

[diag_data.scan_sync.day(diag_data.scan_counter) ...
    diag_data.scan_sync.msec_of_day(diag_data.scan_counter) ...
    diag_data.scan_sync.usec_of_msec(diag_data.scan_counter)] = read_utc(fid);

for i = 1:148
    eval(['diag_data.KAV_Test_Counts_' num2str(i) '(diag_data.scan_counter) = fread(fid, 1, ''uint16'');']);
    eval(['diag_data.WG_Test_Counts_'  num2str(i) '(diag_data.scan_counter) = fread(fid, 1, ''uint16'');']);
end

