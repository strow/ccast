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
% LEOandA data
LEOandA.day = zeros(1,ceil(NUM_SPOTS/96/3));
LEOandA.msec_of_day = zeros(1,ceil(NUM_SPOTS/96/3));
LEOandA.usec_of_msec = zeros(1,ceil(NUM_SPOTS/96/3));
LEOandA.scan_counter = 0;
if 1,
        LEOandA.SPA_P5V_AorB_VMON = zeros(1,ceil(NUM_SPOTS/96/3));   
        LEOandA.SPA_P15V_AorB_VMON= zeros(1,ceil(NUM_SPOTS/96/3)); 
        LEOandA.SPA_N15V_AorB_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_P6V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_P12V_RF2_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_P15V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_N15V_RF_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_P15V_ANA_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCV_P15V_ANA_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.K_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.KA_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_PRI_PLO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_RED_PLO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.W_RFE_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SAW_FILT_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.W_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.W_PRI_GDO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.W_RED_GDO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.G_PRI_CSO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.G_RED_CSO_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.G1_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.G2_IF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.W_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.KKA_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.G_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_SHELF_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCVPS_A_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RCVPS_B_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.OCXO_PRI_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.OCXO_RED_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.DSPA_1553_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.DSPB_1553_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SPA_PS_A_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SPA_PS_B_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.DSPA_PROC_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.DSPB_PROC_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MECH_TEMP = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_PS_PRT = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_PLO_A_LOCK_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.V_PLO_B_LOCK_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.HK_2WREST1_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.HK_2WREST2_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.GND_4W_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.GND_2W_AorB = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_REF_AorB_mod1 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_REF_AorB_mod2 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_REF_AorB_mod3 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_REF_AorB_mod4 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_GND_AorB_mod1 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_GND_AorB_mod2 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_GND_AorB_mod3 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.VD_GND_AorB_mod4 = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_P5V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_P12V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_N12V_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.MAIN_MOTOR_CUR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.COMP_MOTOR_CUR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.RESOLVER_VMON = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MAIN_MOTOR_VEL = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_COMP_MOTOR_VEL = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MAIN_LOOP_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MAIN_LOOP_INT_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MAIN_LOOP_VEL_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_COMP_LOOP_ERROR = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MAIN_MOTOR_REQ_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_COMP_MOTOR_REQ_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_FEED_FORWARD_VOLTAGE = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.COMP_MOTOR_POS = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.SD_MOTOR_ERRORS = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.INSTRUMENT_MODE = zeros(1,ceil(NUM_SPOTS/96/3));
        LEOandA.ERROR_STATUS = zeros(1,ceil(NUM_SPOTS/96/3));
end