%          (c) Copyright 2004 Massachusetts Institute of Technology
%
%          In no event shall M.I.T. be liable to any party for direct, 
%          indirect, special, incidental, or consequential damages arising
%          out of the use of this software and its documentation, even if
%          M.I.T. has been advised of the possibility of such damage.
%          
%          M.I.T. specifically disclaims any warranties including, but not
%          limited to, the implied warranties of merchantability, fitness
%          for a particular purpose, and non-infringement.
%
%          The software is provided on an "as is" basis and M.I.T. has no
%          obligation to provide maintenance, support, updates, enhancements,
%          or modifications.   
      second_word = fread(fid,1,'uint16');
      header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
      header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
      header.packet_length = fread(fid,1,'uint16');	
      
      %if header.packet_length < 700
      
	  packet_id = 10;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	    fprintf('Found ENGINEERING H&S PACKET (%d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
        end    
      end        
      engineering_h_and_s.scan_counter = engineering_h_and_s.scan_counter + 1;
      % read the UTC time codes
      [engineering_h_and_s.day(engineering_h_and_s.scan_counter), engineering_h_and_s.msec_of_day(engineering_h_and_s.scan_counter), engineering_h_and_s.usec_of_msec(engineering_h_and_s.scan_counter)] = read_utc(fid);

      if 1
        % skip ahead to gamma0
        fread(fid,25,'uint16');
        %fread(fid,43,'uint16');
        engineering_h_and_s.W_SHELF_PRT(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        engineering_h_and_s.KKA_SHELF_PRT(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        engineering_h_and_s.G_SHELF_PRT(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        engineering_h_and_s.V_SHELF_PRT(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        fread(fid,12,'uint16');
        % read gamma0 (packet 44)
        engineering_h_and_s.HK_2WREST1_AorB(engineering_h_and_s.scan_counter) = 9.155e-4*fread(fid,1,'uint16')+1970;
        engineering_h_and_s.HK_2WREST2_AorB(engineering_h_and_s.scan_counter) = 9.155e-4*fread(fid,1,'uint16')+1970;
        engineering_h_and_s.GND_4W_AorB(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        engineering_h_and_s.GND_2W_AorB(engineering_h_and_s.scan_counter) = fread(fid,1,'uint16');
        fread(fid,24,'uint16');
      else
        fread(fid,header.packet_length-7,'uint8');
        engineering_h_and_s.GND_4W_AorB = 0;
      end
      
