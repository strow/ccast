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
      
	  packet_id = 2;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	    fprintf('Found LEO&A PACKET             (%d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
          end    
      end        
	  junk=fread(fid,header.packet_length+1,'uint8');	
      instrSN=junk(2); % grab the instrument serial number
      instrument_mode = junk(end-3);
      if PRINT_INSTRUMENT_MODE
          PRINT_INSTRUMENT_MODE = 0;
          if bitget(instrument_mode,2)
              fprintf('SAW Filter side B detected.\n');
          else
              fprintf('SAW Filter side A detected.\n');
          end
          if bitget(instrument_mode,3)
              fprintf('SPA side B detected.\n');
          else
              fprintf('SPA side A detected.\n');
          end
          % Determine redundancy configuration from instrument_mode
    foo = bitget(instrument_mode,2:3);
    if foo==[0 0]
        RC = 4;
    elseif foo==[0 1]
        RC = 1;
    elseif foo==[1 0]
        RC = 3;
    elseif foo==[1 1]
        RC = 2;
    else
        error('RC doesn''t fit.')
    end
fprintf('Redundancy Configuration = %d\n',RC)
clear foo
      end
      
      
      clear junk
