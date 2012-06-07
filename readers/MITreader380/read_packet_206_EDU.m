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
      
	  packet_id = 7;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	    fprintf('Found HOUSEKEEPING PACKET      (%d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
        end    
      end        

      housekeeping.scan_counter = housekeeping.scan_counter + 1;

      % read the UTC time codes
      [housekeeping.day(housekeeping.scan_counter), housekeeping.msec_of_day(housekeeping.scan_counter), housekeeping.usec_of_msec(housekeeping.scan_counter)] = read_utc(fid);

     
      if 1
        % skip to pertinent housekeeping PRTs
        fread(fid,10,'uint16');
        % grab some housekeeping PRTs
        housekeeping.K_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.KA_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_PRI_PLO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_RED_PLO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_IF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        % skip a few for now
        fread(fid,9,'uint16');
        % grab the shelf PRTs
        housekeeping.W_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.KKA_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        % skip a few more
        fread(fid,12,'uint16');
        % read gamma0
        housekeeping.HK_2WREST1_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.HK_2WREST2_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.GND_4W_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.GND_2W_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        % skip the rest
        fread(fid,24,'uint16');
      else
        fread(fid,header.packet_length-7,'uint8');
        fprintf('%d\n',header.packet_length-7);
        housekeeping.GND_4W_AorB = 0;
      end
      
