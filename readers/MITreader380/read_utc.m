function [day, msec_of_day, usec_of_msec] = read_utc(fid)
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

day = fread(fid,1,'uint16');
msec_of_day = fread(fid,1,'uint16')*2^16 + fread(fid,1,'uint16');
usec_of_msec = fread(fid,1,'uint16');
