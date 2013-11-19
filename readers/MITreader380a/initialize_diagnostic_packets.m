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
% Diagnostic Data
diag_data.day          = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.msec_of_day  = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.usec_of_msec = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.scan_counter = 0;

diag_data.start_of_scan.day          = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.start_of_scan.msec_of_day  = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.start_of_scan.usec_of_msec = zeros(1, ceil(NUM_SPOTS/96/3));

diag_data.scan_sync.day          = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.scan_sync.msec_of_day  = zeros(1, ceil(NUM_SPOTS/96/3));
diag_data.scan_sync.usec_of_msec = zeros(1, ceil(NUM_SPOTS/96/3));

for i = 1:148
    eval(['diag_data.KAV_Test_Counts_' num2str(i) ' = zeros(1, ceil(NUM_SPOTS/96/3));']);
    eval(['diag_data.WG_Test_Counts_'  num2str(i) ' = zeros(1, ceil(NUM_SPOTS/96/3));']);
end