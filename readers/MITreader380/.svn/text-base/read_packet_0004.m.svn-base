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
second_word = fread(fid, 1, 'uint16');
header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK), -14);
header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
header.packet_length = fread(fid, 1, 'uint16');	
      
packet_id = 15;
packet_counter(packet_id) = packet_counter(packet_id) + 1;
byte_counter = byte_counter + header.packet_length+7;
if VERBOSE
    fprintf('Found THM PACKET    (%d percent complete).\n', floor(100*byte_counter/filelength));
else
    progress = floor(100*byte_counter/filelength);
    if PROGRESS_COUNTER(progress+1)
        PROGRESS_COUNTER(progress+1) = 0;
        fprintf('%d percent complete.\n', progress);
    end    
end

thm.scan_counter = thm.scan_counter + 1;
thm.pacseq(thm.scan_counter) = header.sequence_number;

% read the UTC time codes
[thm.day(thm.scan_counter), thm.msec_of_day(thm.scan_counter), thm.usec_of_msec(thm.scan_counter)] = read_utc(fid);

for iT = 14:417
    pkt(iT) = fread(fid, 1, 'uint8');
    
    % Read the TATCPOPHDB uint16 values
    if iT == 267
        fseek(fid, -2, 'cof');
        HDB1 = fread(fid, 1, 'uint16');
    elseif iT == 401
        fseek(fid, -2, 'cof');
        HDB2 = fread(fid, 1, 'uint16');
    elseif iT == 185
        fseek(fid, -2, 'cof');
        CPOT1 = fread(fid, 1, 'int16');
    elseif iT == 319
        fseek(fid, -2, 'cof');
        CPOT2 = fread(fid, 1, 'int16');
    end
end

c = [106.0 -1.1684 5.6621e-3 -1.3003e-5];
thm.TMXPATCPIFT(thm.scan_counter) = convert_to_temp(pkt(47), c);
thm.TPYPATCPIFT(thm.scan_counter) = convert_to_temp(pkt(71), c);

c = [331.61 -9.7619 0.12988 -0.00090054 3.1081e-6 -4.2656e-9];
thm.TATBPT1(thm.scan_counter) = convert_to_temp(pkt(111), c);
thm.TATBPT2(thm.scan_counter) = convert_to_temp(pkt(118), c);
thm.TATGRXT1(thm.scan_counter) = convert_to_temp(pkt(98), c);
thm.TATGRXT2(thm.scan_counter) = convert_to_temp(pkt(104), c);
thm.TATSDMT1(thm.scan_counter) = convert_to_temp(pkt(110), c);
thm.TATSDMT2(thm.scan_counter) = convert_to_temp(pkt(117), c);
thm.TATVRXT1(thm.scan_counter) = convert_to_temp(pkt(138), c);
thm.TATVRXT2(thm.scan_counter) = convert_to_temp(pkt(145), c);
thm.TATTBNCHT1(thm.scan_counter) = convert_to_temp(pkt(124), c);
thm.TATTBNCHT2(thm.scan_counter) = convert_to_temp(pkt(131), c);

c = [155.463 -7.29148 0.211311 -0.00333258 2.53007E-05 -7.40823E-08];
thm.TATCPOPHOP1(thm.scan_counter) = convert_to_temp(pkt(268), c);
thm.TATCPOPHOP2(thm.scan_counter) = convert_to_temp(pkt(402), c);
thm.TATCPOPHSV1(thm.scan_counter) = convert_to_temp(pkt(269), c);
thm.TATCPOPHSV2(thm.scan_counter) = convert_to_temp(pkt(403), c);

thm.TATCPOPHMD1(thm.scan_counter) = ((bitand(pkt(266), (2.^5))) / (2.^5));
thm.TATCPOPHMD2(thm.scan_counter) = ((bitand(pkt(400), (2.^5))) / (2.^5));

thm.TATCPOPHST1(thm.scan_counter) = ((bitand(pkt(267), (2.^6))) / (2.^6));
thm.TATCPOPHST2(thm.scan_counter) = ((bitand(pkt(401), (2.^6))) / (2.^6));

thm.TATCPOPHPW1(thm.scan_counter) = ((bitand(pkt(267), (2.^7))) / (2.^7));
thm.TATCPOPHPW2(thm.scan_counter) = ((bitand(pkt(401), (2.^7))) / (2.^7));

c = [0.0 0.056586691];
%B1 = bitshift(double(pkt(266)),8) + double(pkt(267));
%B2 = bitshift(double(pkt(400)),8) + double(pkt(401));
%bitshift(bitand(B1,HEATER_MASK),-6)
%bitshift(bitand(B2,HEATER_MASK),-6)
thm.TATCPOPHDB1(thm.scan_counter) = convert_to_temp(bitshift(bitand(HDB1,HEATER_MASK),-6), c);
thm.TATCPOPHDB2(thm.scan_counter) = convert_to_temp(bitshift(bitand(HDB2,HEATER_MASK),-6), c);

c = [155.463 -0.455718 8.25433E-04 -8.13619E-07 3.86058E-10 -7.06504E-14];
thm.TATCPOT1(thm.scan_counter) = convert_to_temp(CPOT1, c);
thm.TATCPOT2(thm.scan_counter) = convert_to_temp(CPOT2, c);

clear skip iT pT pkt c;
%clear B1 B2;
