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
	    fprintf('Found HOUSEKEEPING PACKET      (%3d percent complete).\n', floor(100*byte_counter/filelength));
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

% Read Software Version and Inst. Serial Number
sftwr_iSN = fread(fid, 1, 'uint16');

sftvr_b = bitand(sftwr_iSN, sum(2.^[0:3]));
sftvr_a = bitshift(bitand(sftwr_iSN, sum(2.^[4:7])), -4);
sftwr_vrsn = [num2str(sftvr_a) '.' num2str(sftvr_b)];

instrSN = bitshift(sftwr_iSN, -8);        
        
        housekeeping.SPA_P5V_AorB_VMON(:,housekeeping.scan_counter)=8.5832e-5*fread(fid,1,'uint16');   
        housekeeping.SPA_P15V_AorB_VMON(:,housekeeping.scan_counter)= 2.7466e-4*fread(fid,1,'uint16'); 
        housekeeping.SPA_N15V_AorB_VMON(:,housekeeping.scan_counter)=-2.7466e-4*fread(fid,1,'uint16');
        housekeeping.RCV_P6V_RF_VMON(:,housekeeping.scan_counter)=1.0717e-4*fread(fid,1,'uint16');
        housekeeping.RCV_P12V_RF2_VMON(:,housekeeping.scan_counter)=2.12505e-4*fread(fid,1,'uint16');
        housekeeping.RCV_P15V_RF_VMON(:,housekeeping.scan_counter)= 0.70 + 2.5628e-4*fread(fid,1,'uint16');
        housekeeping.RCV_N15V_RF_VMON(:,housekeeping.scan_counter)=-0.70 + -2.5628e-4*fread(fid,1,'uint16');
        housekeeping.RCV_P15V_ANA_VMON(:,housekeeping.scan_counter)= 2.6560e-4*fread(fid,1,'uint16');
        housekeeping.RCV_N15V_ANA_VMON(:,housekeeping.scan_counter)=-2.6560e-4*fread(fid,1,'uint16');
        housekeeping.K_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.KA_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_PRI_PLO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_RED_PLO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_IF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.W_RFE_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.SAW_FILT_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.W_IF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.W_PRI_GDO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.W_RED_GDO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G_PRI_CSO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G_RED_CSO_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G1_IF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G2_IF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.W_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.KKA_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.G_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_SHELF_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.RCVPS_A_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.RCVPS_B_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.OCXO_PRI_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.OCXO_RED_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.DSPA_1553_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.DSPB_1553_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.SPA_PS_A_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.SPA_PS_B_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.DSPA_PROC_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.DSPB_PROC_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        % clear foobar,foobar=fread(fid,1,'uint16');
        % housekeeping.SD_MECH_T_PRT(:,housekeeping.scan_counter)=(1e6*(foobar-399.3371))/(8905947-(1907.3*foobar));
        housekeeping.SD_MECH_T_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.SD_PS_PRT(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.V_PLO_A_LOCK_VMON(:,housekeeping.scan_counter)=2.0399e-4*fread(fid,1,'uint16');
        housekeeping.V_PLO_B_LOCK_VMON(:,housekeeping.scan_counter)=2.0399e-4*fread(fid,1,'uint16');
        % read gamma1 and gamma0
        housekeeping.HK_2WREST1_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.HK_2WREST2_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.GND_4W_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.GND_2W_AorB(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.VD_REF_AorB_mod1(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_REF_AorB_mod2(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_REF_AorB_mod3(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_REF_AorB_mod4(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_GND_AorB_mod1(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_GND_AorB_mod2(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_GND_AorB_mod3(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        housekeeping.VD_GND_AorB_mod4(:,housekeeping.scan_counter)=6.8666e-5*fread(fid,1,'uint16');
        
        % housekeeping.SD_P5V_VMON(:,housekeeping.scan_counter)=5008/fread(fid,1,'uint16');
        % housekeeping.SD_P12V_VMON_unconverted(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        % housekeeping.SD_N12V_VMON_unconverted(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        
        % There are 1,3,2 on purpose
        SD_Count1 = fread(fid,1,'uint16');
        SD_Count3 = fread(fid,1,'uint16');
        SD_Count2 = fread(fid,1,'uint16');
        housekeeping.SD_P5V_VMON(:, housekeeping.scan_counter)=5008/SD_Count1;
        housekeeping.SD_P12V_VMON(:,housekeeping.scan_counter)=(((4.284*SD_Count3) - (45.08657*SD_Count2))/SD_Count1) + 43.30089;
        housekeeping.SD_N12V_VMON(:,housekeeping.scan_counter)=((63.096*SD_Count2)/SD_Count1) - 60.6212;
        
        housekeeping.MAIN_MOTOR_CUR(:,housekeeping.scan_counter)= -0.3888 + 0.021777*fread(fid,1,'int16');
        housekeeping.COMP_MOTOR_CUR(:,housekeeping.scan_counter)= -0.3888 + 0.021777*fread(fid,1,'int16');
        housekeeping.RESOLVER_VMON(:,housekeeping.scan_counter)=0.008817*fread(fid,1,'int16');
        housekeeping.SD_MAIN_MOTOR_VEL(:,housekeeping.scan_counter)=0.0625*fread(fid,1,'int16');
        housekeeping.SD_COMP_MOTOR_VEL(:,housekeeping.scan_counter)=0.0625*fread(fid,1,'int16');
        housekeeping.SD_MAIN_LOOP_ERROR(:,housekeeping.scan_counter)=0.005493*fread(fid,1,'int16');
        housekeeping.SD_MAIN_LOOP_INT_ERROR(:,housekeeping.scan_counter)=0.005493*fread(fid,1,'int16');
        housekeeping.SD_MAIN_LOOP_VEL_ERROR(:,housekeeping.scan_counter)=0.0625*fread(fid,1,'int16');
        housekeeping.SD_COMP_LOOP_ERROR(:,housekeeping.scan_counter)=0.0625*fread(fid,1,'int16');
        housekeeping.SD_MAIN_MOTOR_REQ_VOLTAGE(:,housekeeping.scan_counter)=5.49e-4*fread(fid,1,'int16');
        housekeeping.SD_COMP_MOTOR_REQ_VOLTAGE(:,housekeeping.scan_counter)=5.49e-4*fread(fid,1,'int16');
        housekeeping.SD_FEED_FORWARD_VOLTAGE(:,housekeeping.scan_counter)=458752/fread(fid,1,'int16');
        housekeeping.COMP_MOTOR_POS(:,housekeeping.scan_counter)=5.493e-3*fread(fid,1,'int16');
        housekeeping.SD_MOTOR_ERRORS(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.INSTRUMENT_MODE(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
        housekeeping.ERROR_STATUS(:,housekeeping.scan_counter)=fread(fid,1,'uint16');
      
        if PRINT_INSTRUMENT_MODE
            
          PRINT_INSTRUMENT_MODE = 0;
          
          if bitget(housekeeping.INSTRUMENT_MODE(1),2)
              fprintf('SAW Filter side B detected.\n');
          else
              fprintf('SAW Filter side A detected.\n');
          end
          if bitget(housekeeping.INSTRUMENT_MODE(1),3)
              fprintf('SPA side B detected.\n');
          else
              fprintf('SPA side A detected.\n');
          end
          
    % Determine redundancy configuration from instrument_mode
    foo = bitget(housekeeping.INSTRUMENT_MODE(1),2:3);
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
fprintf('EDU Redundancy Configuration = %d\n',RC)
display(['EDU RC 1 = PFM RC 6'; 'EDU RC 2 = PFM RC 5';'EDU RC 3 = PFM RC 2'; 'EDU RC 4 = PFM RC 1'])
clear foo
      end  
