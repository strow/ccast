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
LEOandA.day(:,(LEOandA.scan_counter+1):end) = [];
LEOandA.msec_of_day(:,(LEOandA.scan_counter+1):end) = [];
LEOandA.usec_of_msec(:,(LEOandA.scan_counter+1):end) = [];
if 1,
        LEOandA.SPA_P5V_AorB_VMON(:,(LEOandA.scan_counter+1):end) = [];   
        LEOandA.SPA_P15V_AorB_VMON(:,(LEOandA.scan_counter+1):end) = []; 
        LEOandA.SPA_N15V_AorB_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_P6V_RF_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_P12V_RF2_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_P15V_RF_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_N15V_RF_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_P15V_ANA_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCV_P15V_ANA_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.K_RFE_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.KA_RFE_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_RFE_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_PRI_PLO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_RED_PLO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_IF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.W_RFE_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SAW_FILT_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.W_IF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.W_PRI_GDO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.W_RED_GDO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.G_PRI_CSO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.G_RED_CSO_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.G1_IF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.G2_IF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.W_SHELF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.KKA_SHELF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.G_SHELF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_SHELF_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCVPS_A_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RCVPS_B_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.OCXO_PRI_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.OCXO_RED_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.DSPA_1553_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.DSPB_1553_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SPA_PS_A_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SPA_PS_B_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.DSPA_PROC_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.DSPB_PROC_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MECH_TEMP(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_PS_PRT(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_PLO_A_LOCK_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.V_PLO_B_LOCK_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.HK_2WREST1_AorB(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.HK_2WREST2_AorB(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.GND_4W_AorB(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.GND_2W_AorB(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_REF_AorB_mod1(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_REF_AorB_mod2(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_REF_AorB_mod3(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_REF_AorB_mod4(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_GND_AorB_mod1(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_GND_AorB_mod2(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_GND_AorB_mod3(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.VD_GND_AorB_mod4(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_P5V_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_P12V_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_N12V_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.MAIN_MOTOR_CUR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.COMP_MOTOR_CUR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.RESOLVER_VMON(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MAIN_MOTOR_VEL(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_COMP_MOTOR_VEL(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MAIN_LOOP_ERROR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MAIN_LOOP_INT_ERROR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MAIN_LOOP_VEL_ERROR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_COMP_LOOP_ERROR(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MAIN_MOTOR_REQ_VOLTAGE(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_COMP_MOTOR_REQ_VOLTAGE(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_FEED_FORWARD_VOLTAGE(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.COMP_MOTOR_POS(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.SD_MOTOR_ERRORS(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.INSTRUMENT_MODE(:,(LEOandA.scan_counter+1):end) = [];
        LEOandA.ERROR_STATUS(:,(LEOandA.scan_counter+1):end) = [];
end