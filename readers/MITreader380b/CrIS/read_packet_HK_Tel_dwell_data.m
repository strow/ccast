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

function read_packet_HK_Tel_dwell_data

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

packet_counter.HK_Tel_dwell = packet_counter.HK_Tel_dwell + 1;
L=(header.packet_length-8)/2;% 16 bit words remaining after 8 time bytes read
if(~(L==487));disp('HK_Tel_dwell packet is wrong length');return;end

if data.read.HK_Tel_dwell==1
     
first_word=fread(fid,1,'uint16=>uint16');
PCD_app_FSW_ver=bitshift(bitand(first_word, uint16(hex2dec('FFE0')) ),-5);
data.HK_Tel_dwell.InstID=single(bitand(first_word,uint16(hex2dec('001F')) ));

address=single(fread(fid,6,'uint16=>uint16'));
sample=get_14bit_integer(fid,L-7)' ;

% store in MySQL database hk_dwell_data
% mym(['replace INTO hk_dwell_data(time,address,sample) VALUES ("{Sn}","{M}","{M}")'],fix(timeval*1.e10),abs(add),sample);

data.HK_Tel_dwell.time=timeval;
data.HK_Tel_Dwell.address=address;
data.HK_Tel_dwell.sample=sample;  

else
dummy=fread(fid,L,'uint16');
end
             
if VERBOSE
v=datevec(timeval);
fprintf('Found PACKET %d (%x hex) sec=  %12.6f .\n', header.apid, header.apid, v(5)*60+v(6));
end 

function a=get_14bit_integer(fid,L)
        mask=uint16(2^14-1);
        buf =(bitand(fread(fid, L, '*uint16'),mask));
        a=single(buf);
        idx=find(a>8192);
        a(idx)=a(idx)-16384;
        
        