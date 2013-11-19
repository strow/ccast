%        (c) Copyright 2004 Massachusetts Institute of Technology
%
%        In no event shall M.I.T. be liable to any party for direct, 
%        indirect, special, incidental, or consequential damages arising
%        out of the use of this software and its documentation, even if
%        M.I.T. has been advised of the possibility of such damage.
%        
%        M.I.T. specifically disclaims any warranties including, but not
%        limited to, the implied warranties of merchantability, fitness
%        for a particular purpose, and non-infringement.
%
%        The software is provided on an "as is" basis and M.I.T. has no
%        obligation to provide maintenance, support, updates, enhancements,
%        or modifications.   
% Thermal Telemetry
thm.day          = zeros(1, ceil(NUM_SPOTS/96/3));
thm.msec_of_day  = zeros(1, ceil(NUM_SPOTS/96/3));
thm.usec_of_msec = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TMXPATCPIFT = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TPYPATCPIFT = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATBPT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATBPT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATGRXT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATGRXT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATSDMT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATSDMT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATVRXT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATVRXT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATTBNCHT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATTBNCHT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHOP1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHOP2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHSV1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHSV2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHMD1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHMD2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHST1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHST2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHPW1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHPW2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHDB1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOPHDB2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOT1 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.TATCPOT2 = zeros(1, ceil(NUM_SPOTS/96/3));
thm.scan_counter = 0;
