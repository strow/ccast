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
% Calibration Test Equipment data
cte.day = zeros(1,ceil(NUM_SPOTS/96/3));
cte.msec_of_day = zeros(1,ceil(NUM_SPOTS/96/3));
cte.usec_of_msec = zeros(1,ceil(NUM_SPOTS/96/3));
cte.KAV_VAR = zeros(12,ceil(NUM_SPOTS/96/3));
cte.WG_VAR = zeros(10,ceil(NUM_SPOTS/96/3));
cte.KAV_FIX = zeros(11,ceil(NUM_SPOTS/96/3));
cte.WG_FIX = zeros(10,ceil(NUM_SPOTS/96/3));
cte.COLD_PLATE = zeros(8,ceil(NUM_SPOTS/96/3));
cte.pacseq=zeros(1,ceil(NUM_SPOTS/96/3));
cte.scan_counter = 0;

