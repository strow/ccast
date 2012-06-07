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

% Science data
science_data.day = zeros(1,NUM_SPOTS);
science_data.msec_of_day = zeros(1,NUM_SPOTS);
science_data.usec_of_msec = zeros(1,NUM_SPOTS);
science_data.scan_angle_degrees = zeros(1,NUM_SPOTS);
science_data.error_status_flags = zeros(1,NUM_SPOTS);
science_data.radiometric_counts = zeros(22,NUM_SPOTS);
science_data.pacseq = zeros(1,NUM_SPOTS);
science_data.seqnum = zeros(1,NUM_SPOTS);
science_data.scan_counter = 0;

% Science data orig (used in cleanup_science_packets)
science_data_orig.day = [];
science_data_orig.msec_of_day = [];
science_data_orig.usec_of_msec = [];
science_data_orig.scan_angle_degrees = [];
science_data_orig.error_status_flags = [];
science_data_orig.radiometric_counts = [];
science_data_orig.pacseq = [];
science_data_orig.seqnum = [];
science_data_orig.scan_counter = 0;

% Science data irreg (used in cleanup_science_packets)
science_data_irreg.day = [];
science_data_irreg.msec_of_day = [];
science_data_irreg.usec_of_msec = [];
science_data_irreg.scan_angle_degrees = [];
science_data_irreg.error_status_flags = [];
science_data_irreg.radiometric_counts = [];
science_data_irreg.pacseq = [];
science_data_irreg.seqnum = [];
science_data_irreg.scan_counter = 0;