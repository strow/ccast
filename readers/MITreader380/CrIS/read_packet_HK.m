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

function read_packet_HK

% (c) Copyright 2004 Massachusetts Institute of Technology

% Read HK packet 

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
    
% only here if apid=500-507 hex i.e.1280-1287
HK_id=header.apid-1279;
if(HK_id<8)
packet_counter.HK(HK_id)=packet_counter.HK(HK_id)+1;
data.HK_time(HK_id,packet_counter.HK(HK_id))=header.time;
L=(header.packet_length-8)/2 ;% convert to 16 bit words
data.HK(HK_id,packet_counter.HK(HK_id),1:42)=fread(fid,L,'uint16=>uint16')';
elseif(HK_id==8)
packet_counter.HK(HK_id)=packet_counter.HK(HK_id)+1;
data.HK_time(HK_id,packet_counter.HK(HK_id))=header.time;
% L=(header.packet_length-8)/2 ;% 661 16 bit words
data.HK(HK_id,packet_counter.HK(HK_id),1:42)=fread(fid,42,'uint16=>uint16')';
% read another 661-42=619 words
data.HK8(packet_counter.HK(HK_id),1:619)=fread(fid,619,'uint16=>uint16')';
end

if VERBOSE
fprintf('Found PACKET %d (%x hex).\n', header.apid, header.apid);
end  