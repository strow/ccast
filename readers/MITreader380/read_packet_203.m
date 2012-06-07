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
%          or modifications.         second_word = fread(fid,1,'uint16');
      second_word = fread(fid,1,'uint16');
      header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
      header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
      header.packet_length = fread(fid,1,'uint16');
      %if header.packet_length < 700
      
	  packet_id = 4;
	  packet_counter(packet_id) = packet_counter(packet_id) + 1;
	  byte_counter = byte_counter + header.packet_length+7;
      if VERBOSE
          disp('----------------------------------------------------------------------');
	      fprintf('Found CALIBRATION PACKET       (%3d percent complete). %d\n', floor(100*byte_counter/filelength), header.sequence_number);
          fprintf('Packet Length = %d\n', header.packet_length);
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
          end    
      end        
      cal_data.scan_counter = cal_data.scan_counter + 1;
      cal_data.pacseq(cal_data.scan_counter) = header.packet_sequence;
      cal_data.seqnum(cal_data.scan_counter) = header.sequence_number;

      % read the UTC time codes
      [cal_data.day(cal_data.scan_counter), cal_data.msec_of_day(cal_data.scan_counter), cal_data.usec_of_msec(cal_data.scan_counter)] = read_utc(fid);
      
      if VERBOSE
          fprintf('day: %d  msec: %d  usec: %d\n', cal_data.day(cal_data.scan_counter), cal_data.msec_of_day(cal_data.scan_counter), cal_data.usec_of_msec(cal_data.scan_counter));
      end

      cal_data.PAM_resistance_KAV(:, cal_data.scan_counter) = 2300 + 0.006 * fread(fid,1,'uint16');
      cal_data.PAM_resistance_WG(:, cal_data.scan_counter) = 2300 + 0.006 * fread(fid,1,'uint16');
      for y=1:8,
      cal_data.PRT_4W_KAV_R0(y, cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.PRT_4W_KAV_alpha(y, cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.PRT_4W_KAV_delta(y, cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.PRT_4W_KAV_beta(y, cal_data.scan_counter) = -2 + 6e-5 * fread(fid,1,'uint16');
      end
      for z=1:7,
      cal_data.PRT_4W_WG_R0(z, cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.PRT_4W_WG_alpha(z, cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.PRT_4W_WG_delta(z, cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.PRT_4W_WG_beta(z, cal_data.scan_counter) = -2 + 6e-5 * fread(fid,1,'uint16');
      end
      cal_data.cal_target_offset_K(:, cal_data.scan_counter) = -7.5e-6 * fread(fid,1,'uint16');
      cal_data.cal_target_offset_A(:, cal_data.scan_counter) = -7.5e-6 * fread(fid,1,'uint16');
      cal_data.cal_target_offset_V(:, cal_data.scan_counter) = -7.5e-6 * fread(fid,1,'uint16');
      cal_data.cal_target_offset_W(:, cal_data.scan_counter) = -7.5e-6 * fread(fid,1,'uint16');
      cal_data.cal_target_offset_G(:, cal_data.scan_counter) = -7.5e-6 * fread(fid,1,'uint16');
      cal_data.cold_cal_offset_K(:, cal_data.scan_counter) = 1.5e-5 * fread(fid,1,'uint16');
      cal_data.cold_cal_offset_A(:, cal_data.scan_counter) = 1.5e-5 * fread(fid,1,'uint16');
      cal_data.cold_cal_offset_V(:, cal_data.scan_counter) = 1.5e-5 * fread(fid,1,'uint16');
      cal_data.cold_cal_offset_W(:, cal_data.scan_counter) = 1.5e-5 * fread(fid,1,'uint16');
      cal_data.cold_cal_offset_G(:, cal_data.scan_counter) = 1.5e-5 * fread(fid,1,'uint16');
      cal_data.quadratic_coefficient(:, cal_data.scan_counter) = -0.13 + 4e-6 * fread(fid,22,'uint16');
      fread(fid,45,'uint16'); % throw Alignment variables away
      cal_data.K_SHELF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.K_SHELF_PRT_alpha(:,cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.K_SHELF_PRT_delta(:,cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.K_SHELF_PRT_RC(:,cal_data.scan_counter) = 0.0003 * fread(fid,1,'uint16');
      cal_data.V_SHELF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.V_SHELF_PRT_alpha(:,cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.V_SHELF_PRT_delta(:,cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.V_SHELF_PRT_RC(:,cal_data.scan_counter) = 0.0003 * fread(fid,1,'uint16');
      cal_data.W_SHELF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.W_SHELF_PRT_alpha(:,cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.W_SHELF_PRT_delta(:,cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.W_SHELF_PRT_RC(:,cal_data.scan_counter) = 0.0003 * fread(fid,1,'uint16');
      cal_data.G_SHELF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.G_SHELF_PRT_alpha(:,cal_data.scan_counter) = 0.002 + 5e-8 * fread(fid,1,'uint16');
      cal_data.G_SHELF_PRT_delta(:,cal_data.scan_counter) = 5e-5 * fread(fid,1,'uint16');
      cal_data.G_SHELF_PRT_RC(:,cal_data.scan_counter) = 0.0003 * fread(fid,1,'uint16');
	  cal_data.K_RFE_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.K_RFE_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.KA_RFE_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.KA_RFE_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.V_RFE_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.V_RFE_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.V_PRI_PLO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.V_PRI_PLO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.V_RED_PLO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.V_RED_PLO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.V_IF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.V_IF_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.W_RFE_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.W_RFE_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SAW_FILT_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SAW_FILT_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.W_IF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.W_IF_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.W_PRI_GDO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.W_PRI_GDO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.W_RED_GDO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.W_RED_GDO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.G_PRI_CSO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.G_PRI_CSO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.G_RED_CSO_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.G_RED_CSO_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.G1_IF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.G1_IF_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.G2_IF_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.G2_IF_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.RCVPS_A_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.RCVPS_A_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.RCVPS_B_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.RCVPS_B_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.OCXO_PRI_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.OCXO_PRI_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.OCXO_RED_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.OCXO_RED_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.DSPA_1553_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.DSPA_1553_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.DSPB_1553_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.DSPB_1553_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SPA_PS_A_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SPA_PS_A_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SPA_PS_B_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SPA_PS_B_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.DSPA_PROC_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.DSPA_PROC_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.DSPB_PROC_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.DSPB_PROC_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SD_MECH_T_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SD_MECH_T_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SD_PS_A_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SD_PS_A_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.SD_PS_B_PRT_R0(:,cal_data.scan_counter) = 1900 + 0.003 * fread(fid,1,'uint16');
      cal_data.SD_PS_B_PRT_A1(:,cal_data.scan_counter) = 3e-6*fread(fid,1,'uint16');
      cal_data.MUXREST1_A(:,cal_data.scan_counter) = 1900 + 0.003*fread(fid,1,'uint16');
      cal_data.MUXREST2_A(:,cal_data.scan_counter) = 1900 + 0.003*fread(fid,1,'uint16');
      cal_data.MUXREST1_B(:,cal_data.scan_counter) = 1900 + 0.003*fread(fid,1,'uint16');
      cal_data.MUXREST2_B(:,cal_data.scan_counter) = 1900 + 0.003*fread(fid,1,'uint16');

      %eval(['packet_length' num2str(packet_id) ' = unique([packet_length' num2str(packet_id) ' header.packet_length+7]);']);
      %else
        %byte_counter = byte_counter + 6;
        %fprintf('Bad byte count (ID = %x):  %d.\n', header.apid, header.packet_length);
        %GOOD_PACKETS = 0;
      %end
