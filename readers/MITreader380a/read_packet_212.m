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
      
	  packet_id = 9;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	    fprintf('Found ENGINEERING HC PACKET    (%3d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
        end    
      end        
      hotcal.scan_counter = hotcal.scan_counter + 1;
      
      % read the UTC time codes
      [hotcal.day(hotcal.scan_counter), hotcal.msec_of_day(hotcal.scan_counter), hotcal.usec_of_msec(hotcal.scan_counter)] = read_utc(fid);

      hotcal.KAV_WL_4WPRT(:, hotcal.scan_counter) = fread(fid,8,'uint16');
      hotcal.KAV_WL_4WRES(:, hotcal.scan_counter) = fread(fid,1,'uint16');
      hotcal.WG_WL_4WPRT(:, hotcal.scan_counter) = fread(fid,7,'uint16');
      hotcal.WG_WL_4WRES(:, hotcal.scan_counter) = fread(fid,1,'uint16');

      
      %eval(['packet_length' num2str(packet_id) ' = unique([packet_length' num2str(packet_id) ' header.packet_length+7]);']);
      %else
        %byte_counter = byte_counter + 6;
        %fprintf('Bad byte count (ID = %x):  %d.\n', header.apid, header.packet_length);
        %GOOD_PACKETS = 0;
      %end
