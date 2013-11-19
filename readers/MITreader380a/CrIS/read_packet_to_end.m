%
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

function read_packet_to_end

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
       
if header.Secondary_header_flag == 1
fread(fid,header.packet_length-8,'uint8');
else
fread(fid,header.packet_length,'uint8');
end
