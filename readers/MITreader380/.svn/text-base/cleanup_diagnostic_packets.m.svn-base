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
diag_data.day(:,(diag_data.scan_counter+1):end)          = [];
diag_data.msec_of_day(:,(diag_data.scan_counter+1):end)  = [];
diag_data.usec_of_msec(:,(diag_data.scan_counter+1):end) = [];

diag_data.start_of_scan.day(:,(diag_data.scan_counter+1):end)          = [];
diag_data.start_of_scan.msec_of_day(:,(diag_data.scan_counter+1):end)  = [];
diag_data.start_of_scan.usec_of_msec(:,(diag_data.scan_counter+1):end) = [];

diag_data.scan_sync.day(:,(diag_data.scan_counter+1):end)          = [];
diag_data.scan_sync.msec_of_day(:,(diag_data.scan_counter+1):end)  = [];
diag_data.scan_sync.usec_of_msec(:,(diag_data.scan_counter+1):end) = [];

for i = 1:148
    eval(['diag_data.KAV_Test_Counts_' num2str(i) '(:,(diag_data.scan_counter+1):end) = [];']);
    eval(['diag_data.WG_Test_Counts_'  num2str(i) '(:,(diag_data.scan_counter+1):end) = [];']);
end
