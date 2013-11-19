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
cal_data.day(:,(cal_data.scan_counter+1):end) = [];
cal_data.msec_of_day(:,(cal_data.scan_counter+1):end) = [];
cal_data.usec_of_msec(:,(cal_data.scan_counter+1):end) = [];
cal_data.PAM_resistance_KAV(:,(cal_data.scan_counter+1):end) = [];
cal_data.PAM_resistance_WG(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_KAV_R0(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_KAV_alpha(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_KAV_delta(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_KAV_beta(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_WG_R0(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_WG_alpha(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_WG_delta(:,(cal_data.scan_counter+1):end) = [];
cal_data.PRT_4W_WG_beta(:,(cal_data.scan_counter+1):end) = [];
cal_data.cal_target_offset_K(:,(cal_data.scan_counter+1):end) = [];
cal_data.cal_target_offset_A(:,(cal_data.scan_counter+1):end) = [];
cal_data.cal_target_offset_V(:,(cal_data.scan_counter+1):end) = [];
cal_data.cal_target_offset_W(:,(cal_data.scan_counter+1):end) = [];
cal_data.cal_target_offset_G(:,(cal_data.scan_counter+1):end) = [];
cal_data.cold_cal_offset_K(:,(cal_data.scan_counter+1):end) = [];
cal_data.cold_cal_offset_A(:,(cal_data.scan_counter+1):end) = [];
cal_data.cold_cal_offset_V(:,(cal_data.scan_counter+1):end) = [];
cal_data.cold_cal_offset_W(:,(cal_data.scan_counter+1):end) = [];
cal_data.cold_cal_offset_G(:,(cal_data.scan_counter+1):end) = [];
cal_data.quadratic_coefficient(:,(cal_data.scan_counter+1):end) = [];
