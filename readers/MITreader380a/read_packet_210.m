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
      
	  packet_id = 8;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	      fprintf('Found SCIENCE PACKET           (%3d percent complete). %d', floor(100*byte_counter/filelength), header.sequence_number);
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
          end    
      end        
      science_data.scan_counter = science_data.scan_counter + 1;
      science_data.pacseq(science_data.scan_counter) = header.packet_sequence;
      science_data.seqnum(science_data.scan_counter) = header.sequence_number;
      
      % read the UTC time codes
      [science_data.day(science_data.scan_counter), science_data.msec_of_day(science_data.scan_counter), science_data.usec_of_msec(science_data.scan_counter)] = read_utc(fid);
      
      % read scan angle counts
      DEG_PER_COUNT = 360/(2^16-1);
% PFM had a resolver count adjustment of 91
      science_data.scan_angle_degrees(science_data.scan_counter) = (fread(fid,1,'uint16')-91) * DEG_PER_COUNT;

      % read error status flags
      science_data.error_status_flags(science_data.scan_counter) = fread(fid,1,'uint16');

      % read radiometric counts
      science_data.radiometric_counts(:, science_data.scan_counter) = fread(fid,22,'uint16'); 
      %eval(['packet_length' num2str(packet_id) ' = unique([packet_length' num2str(packet_id) ' header.packet_length+7]);']);
      %else
        %byte_counter = byte_counter + 6;
        %fprintf('Bad byte count (ID = %x):  %d.\n', header.apid, header.packet_length);
        %GOOD_PACKETS = 0;
      %end
      
      % Check for Stare data
      if NO_STARE_FLAG && science_data.scan_counter > 1
          if science_data.scan_angle_degrees(science_data.scan_counter) == science_data.scan_angle_degrees(science_data.scan_counter - 1)
              NO_STARE_FLAG = 0;
              fprintf('Stare Data Found\n');
          end
      end
      
      % Check for non-contigious packet sequence numbers
      %if ~MISSING_SEQNUM && science_data.scan_counter > 1
      if science_data.scan_counter > 1,
          prev_seqnum = science_data.seqnum(science_data.scan_counter - 1);
          this_seqnum = science_data.seqnum(science_data.scan_counter);
          expected = prev_seqnum + 1;
          if expected > 16383
              expected = expected - 16383;
          end
          if this_seqnum > expected
              MISSING_SEQNUM = MISSING_SEQNUM + 1;
              missing_packets = [missing_packets science_data.scan_counter];
              fprintf('MISSING Sequence Number: %d\n', science_data.scan_counter);
          end
      end
      
      if VERBOSE
          fprintf(' %f\n', science_data.scan_angle_degrees(science_data.scan_counter));
      end
