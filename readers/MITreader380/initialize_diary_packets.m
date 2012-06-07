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
% Spacecraft Attitude & Ephemeris Data
diary_data.day          = zeros(1);
diary_data.msec_of_day  = zeros(1);
diary_data.usec_of_msec = zeros(1);

diary_data.spacecraft_id = zeros(1);

diary_data.ephemeris_day          = zeros(1);
diary_data.ephemeris_msec_of_day  = zeros(1);
diary_data.ephemeris_usec_of_msec = zeros(1);

diary_data.position_x = zeros(1);
diary_data.position_y = zeros(1);
diary_data.position_z = zeros(1);

diary_data.velocity_x = zeros(1);
diary_data.velocity_y = zeros(1);
diary_data.velocity_z = zeros(1);

diary_data.attitude_day          = zeros(1);
diary_data.attitude_msec_of_day  = zeros(1);
diary_data.attitude_usec_of_msec = zeros(1);

diary_data.CFA_Q1 = zeros(1);
diary_data.CFA_Q2 = zeros(1);
diary_data.CFA_Q3 = zeros(1);
diary_data.CFA_Q4 = zeros(1);

diary_data.scan_counter = 0;