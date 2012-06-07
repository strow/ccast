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
      
	  packet_id = 14;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
	    fprintf('Found CTE PACKET    (%d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
        end    
      end        
      cte.scan_counter = cte.scan_counter + 1;
      cte.pacseq(cte.scan_counter)=header.sequence_number;
      % read the UTC time codes
      [cte.day(cte.scan_counter), cte.msec_of_day(cte.scan_counter), cte.usec_of_msec(cte.scan_counter)] = read_utc(fid);

      KAV_VAR = fread(fid,4*12,'uint16');
      fid2 = fopen('foo.bin','wb','l');
      for j = 1:12
          for i = 4:-1:1
              fwrite(fid2,KAV_VAR(i+(j-1)*4), 'uint16');
          end
      end
      fclose(fid2);
      fid2 = fopen('foo.bin','rb','l');
      cte.KAV_VAR(:, cte.scan_counter) = fread(fid2,12,'double');
      fclose(fid2);
      
      WG_VAR = fread(fid,4*10,'uint16');
      fid2 = fopen('foo.bin','wb','l');
      for j = 1:10
          for i = 4:-1:1
              fwrite(fid2,WG_VAR(i+(j-1)*4), 'uint16');
          end
      end
      fclose(fid2);
      fid2 = fopen('foo.bin','rb','l');
      cte.WG_VAR(:, cte.scan_counter) = fread(fid2,10,'double');
      fclose(fid2);
     
      KAV_FIX = fread(fid,4*11,'uint16');
      fid2 = fopen('foo.bin','wb','l');
      for j = 1:11
          for i = 4:-1:1
              fwrite(fid2,KAV_FIX(i+(j-1)*4), 'uint16');
          end
      end
      fclose(fid2);
      fid2 = fopen('foo.bin','rb','l');
      cte.KAV_FIX(:, cte.scan_counter) = fread(fid2,11,'double');
      fclose(fid2);
      
      WG_FIX = fread(fid,4*10,'uint16');
      fid2 = fopen('foo.bin','wb','l');
      for j = 1:10
          for i = 4:-1:1
              fwrite(fid2,WG_FIX(i+(j-1)*4), 'uint16');
          end
      end
      fclose(fid2);
      fid2 = fopen('foo.bin','rb','l');
      cte.WG_FIX(:, cte.scan_counter) = fread(fid2,10,'double');
      fclose(fid2);
     
      COLD_PLATE = fread(fid,4*8,'uint16');
      fid2 = fopen('foo.bin','wb','l');
      for j = 1:8
          for i = 4:-1:1
              fwrite(fid2,COLD_PLATE(i+(j-1)*4), 'uint16');
          end
      end
      fclose(fid2);
      fid2 = fopen('foo.bin','rb','l');
      cte.COLD_PLATE(:, cte.scan_counter) = fread(fid2,8,'double');
      fclose(fid2);
     
    