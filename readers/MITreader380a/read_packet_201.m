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
	    fprintf('Found LEO&A PACKET             (%3d percent complete).\n', floor(100*byte_counter/filelength));
      else
          progress = floor(100*byte_counter/filelength);
          if PROGRESS_COUNTER(progress+1)
              PROGRESS_COUNTER(progress+1) = 0;
              fprintf('%d percent complete.\n', progress);
          end    
      end        
	  LEOandA.scan_counter = LEOandA.scan_counter + 1;
      % The LEOandA packets don't have UTC time codes
      % see footnote 1 on page 2 of Report 12115D
      
% Read Software Version and Inst. Serial Number
sftwr_iSN = fread(fid, 1, 'uint16');

sftvr_b = bitand(sftwr_iSN, sum(2.^[0:3]));
sftvr_a = bitshift(bitand(sftwr_iSN, sum(2.^[4:7])), -4);
sftwr_vrsn = [num2str(sftvr_a) '.' num2str(sftvr_b)];

instrSN = bitshift(sftwr_iSN, -8);
        
        LEOandA.SPA_P5V_AorB_VMON(:,LEOandA.scan_counter) = 8.5832e-5*fread(fid,1,'uint16');   
        LEOandA.SPA_P15V_AorB_VMON(:,LEOandA.scan_counter)= 2.7466e-4*fread(fid,1,'uint16'); 
        LEOandA.SPA_N15V_AorB_VMON(:,LEOandA.scan_counter)=-2.7466e-4*fread(fid,1,'uint16');
        LEOandA.RCV_P6V_RF_VMON(:,LEOandA.scan_counter)   = 1.0717e-4*fread(fid,1,'uint16');
        LEOandA.RCV_P12V_RF2_VMON(:,LEOandA.scan_counter) = 2.12505e-4*fread(fid,1,'uint16');
        LEOandA.RCV_P15V_RF_VMON(:,LEOandA.scan_counter)  =  0.7 +  2.5628e-4*fread(fid,1,'uint16');
        LEOandA.RCV_N15V_RF_VMON(:,LEOandA.scan_counter)  = -0.7 + -2.5628e-4*fread(fid,1,'uint16');
        LEOandA.RCV_P15V_ANA_VMON(:,LEOandA.scan_counter) = 2.6560e-4*fread(fid,1,'uint16');
        LEOandA.RCV_N15V_ANA_VMON(:,LEOandA.scan_counter) =-2.6560e-4*fread(fid,1,'uint16');
        LEOandA.K_RFE_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.KA_RFE_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_RFE_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_PRI_PLO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_RED_PLO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_IF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.W_RFE_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.SAW_FILT_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.W_IF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.W_PRI_GDO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.W_RED_GDO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.G_PRI_CSO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.G_RED_CSO_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.G1_IF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.G2_IF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.W_SHELF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.KKA_SHELF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.G_SHELF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_SHELF_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.RCVPS_A_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.RCVPS_B_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.OCXO_PRI_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.OCXO_RED_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.DSPA_1553_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.DSPB_1553_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.SPA_PS_A_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.SPA_PS_B_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.DSPA_PROC_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.DSPB_PROC_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.SD_MECH_T_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.SD_PS_PRT(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.V_PLO_A_LOCK_VMON(:,LEOandA.scan_counter) = 2.0399e-4*fread(fid,1,'uint16');
        LEOandA.V_PLO_B_LOCK_VMON(:,LEOandA.scan_counter) = 2.0399e-4*fread(fid,1,'uint16');
        % read gamma1 and gamma0
        LEOandA.HK_2WREST1_AorB(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.HK_2WREST2_AorB(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.GND_4W_AorB(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.GND_2W_AorB(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.VD_REF_AorB_mod1(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_REF_AorB_mod2(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_REF_AorB_mod3(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_REF_AorB_mod4(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_GND_AorB_mod1(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_GND_AorB_mod2(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_GND_AorB_mod3(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        LEOandA.VD_GND_AorB_mod4(:,LEOandA.scan_counter)=6.8666e-5*fread(fid,1,'uint16');

        % There are 1,3,2 on purpose
        SD_Count1 = fread(fid,1,'uint16');
        SD_Count3 = fread(fid,1,'uint16');
        SD_Count2 = fread(fid,1,'uint16');
        LEOandA.SD_P5V_VMON(:,LEOandA.scan_counter)=5008/SD_Count1;
        LEOandA.SD_P12V_VMON(:,LEOandA.scan_counter)=(((4.284*SD_Count3) - (45.08657*SD_Count2))/SD_Count1) + 43.30089;
        LEOandA.SD_N12V_VMON(:,LEOandA.scan_counter)=((63.096*SD_Count2)/SD_Count1) - 60.6212;

        LEOandA.MAIN_MOTOR_CUR(:,LEOandA.scan_counter)= -0.3888 + 0.021777*fread(fid,1,'int16');
        LEOandA.COMP_MOTOR_CUR(:,LEOandA.scan_counter)= -0.3888 + 0.021777*fread(fid,1,'int16');
        LEOandA.RESOLVER_VMON(:,LEOandA.scan_counter)=0.008817*fread(fid,1,'int16');
        LEOandA.SD_MAIN_MOTOR_VEL(:,LEOandA.scan_counter)=0.0625*fread(fid,1,'int16');
        LEOandA.SD_COMP_MOTOR_VEL(:,LEOandA.scan_counter)=0.0625*fread(fid,1,'int16');
        LEOandA.SD_MAIN_LOOP_ERROR(:,LEOandA.scan_counter)=0.005493*fread(fid,1,'int16');
        LEOandA.SD_MAIN_LOOP_INT_ERROR(:,LEOandA.scan_counter)=0.005493*fread(fid,1,'int16');
        LEOandA.SD_MAIN_LOOP_VEL_ERROR(:,LEOandA.scan_counter)=0.0625*fread(fid,1,'int16');
        LEOandA.SD_COMP_LOOP_ERROR(:,LEOandA.scan_counter)=0.0625*fread(fid,1,'int16');
        LEOandA.SD_MAIN_MOTOR_REQ_VOLTAGE(:,LEOandA.scan_counter)=5.49e-4*fread(fid,1,'int16');
        LEOandA.SD_COMP_MOTOR_REQ_VOLTAGE(:,LEOandA.scan_counter)=5.49e-4*fread(fid,1,'int16');
        LEOandA.SD_FEED_FORWARD_VOLTAGE(:,LEOandA.scan_counter)=458752/fread(fid,1,'int16');
        LEOandA.COMP_MOTOR_POS(:,LEOandA.scan_counter)=5.493e-3*fread(fid,1,'int16');
        LEOandA.SD_MOTOR_ERRORS(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.INSTRUMENT_MODE(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
        LEOandA.ERROR_STATUS(:,LEOandA.scan_counter)=fread(fid,1,'uint16');
          
if PRINT_INSTRUMENT_MODE,
    PRINT_INSTRUMENT_MODE = 0;
    if bitget(LEOandA.INSTRUMENT_MODE(1),2)
        fprintf('SAW Filter side B detected.\n');
    else
        fprintf('SAW Filter side A detected.\n');
    end
    if bitget(LEOandA.INSTRUMENT_MODE(1),3)
        fprintf('SPA side B detected.\n');
    else
        fprintf('SPA side A detected.\n');
    end
          
    % Determine redundancy configuration from instrument_mode
    foo = bitget(LEOandA.INSTRUMENT_MODE(1),2:3);
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
    fprintf('Redundancy Configuration = %d\n (EDU numbering) \n',RC)
    display(['EDU RC 1 = PFM RC 6'; 'EDU RC 2 = PFM RC 5';'EDU RC 3 = PFM RC 2'; 'EDU RC 4 = PFM RC 1'])
end
      
      
      
