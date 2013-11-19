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
%  engineering_h_and_s data
 engineering_h_and_s.day = zeros(1,ceil(NUM_SPOTS/96/3));
 engineering_h_and_s.msec_of_day = zeros(1,ceil(NUM_SPOTS/96/3));
 engineering_h_and_s.usec_of_msec = zeros(1,ceil(NUM_SPOTS/96/3));
 engineering_h_and_s.scan_counter = 0;
if 1,
         engineering_h_and_s.SPA_P5V_AorB_VMON = zeros(1,ceil(NUM_SPOTS/96/3));   
         engineering_h_and_s.SPA_P15V_AorB_VMON= zeros(1,ceil(NUM_SPOTS/96/3)); 
         engineering_h_and_s.SPA_N15V_AorB_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_P6V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_P12V_RF2_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_P15V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_N15V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_P15V_ANA_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCV_P15V_ANA_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.K_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.KA_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_PRI_PLO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_RED_PLO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.W_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SAW_FILT_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.W_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.W_PRI_GDO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.W_RED_GDO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.G_PRI_CSO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.G_RED_CSO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.G1_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.G2_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.W_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.KKA_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.G_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCVPS_A_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RCVPS_B_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.OCXO_PRI_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.OCXO_RED_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.DSPA_1553_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.DSPB_1553_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SPA_PS_A_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SPA_PS_B_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.DSPA_PROC_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.DSPB_PROC_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MECH_T_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_PS_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_PLO_A_LOCK_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.V_PLO_B_LOCK_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.HK_2WREST1_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.HK_2WREST2_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.GND_4W_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.GND_2W_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_REF_AorB_mod1 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_REF_AorB_mod2 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_REF_AorB_mod3 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_REF_AorB_mod4 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_GND_AorB_mod1 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_GND_AorB_mod2 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_GND_AorB_mod3 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.VD_GND_AorB_mod4 = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_P5V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_P12V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_N12V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.MAIN_MOTOR_CUR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.COMP_MOTOR_CUR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.RESOLVER_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MAIN_MOTOR_VEL = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_COMP_MOTOR_VEL = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MAIN_LOOP_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MAIN_LOOP_INT_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MAIN_LOOP_VEL_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_COMP_LOOP_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MAIN_MOTOR_REQ_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_COMP_MOTOR_REQ_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_FEED_FORWARD_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.COMP_MOTOR_POS = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.SD_MOTOR_ERRORS = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.INSTRUMENT_MODE = zeros(1,ceil(NUM_SPOTS/96/3));
         engineering_h_and_s.ERROR_STATUS = zeros(1,ceil(NUM_SPOTS/96/3));

end