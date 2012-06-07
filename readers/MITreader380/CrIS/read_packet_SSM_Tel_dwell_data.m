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

function read_packet_SSM_Tel_dwell_data

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
       
packet_counter.SSM_Tel_dwell = packet_counter.SSM_Tel_dwell + 1;     
L=(header.packet_length-8)/2;% length is 5th word to end

if data.read.HK_Tel_dwell==1
    
first_word=fread(fid,1,'uint16=>uint16');
PCD_app_FSW_ver=bitshift(bitand(first_word, uint16(hex2dec('FFE0')) ),-5);
Inst_ID = bitand(first_word, uint16(hex2dec('001F')) );    
buf=fread(fid,4,'uint16=>uint16');
    MaskL=uint16(hex2dec('FF00'));
    MaskR=uint16(hex2dec('00FF'));  
    address(1)=single(bitand(buf(1),MaskR));
    address(2)=single(bitand(buf(1),MaskL)/256);
    address(3)=single(bitand(buf(2),MaskR));
    address(4)=single(bitand(buf(2),MaskL)/256);
    address(5)=single(bitand(buf(3),MaskR));
    address(6)=single(bitand(buf(3),MaskL)/256);
    address(7)=single(bitand(buf(4),MaskR));
    L=L-8;% 5 read already,3 at end
    % 7 x 80 samples
    if(~(L==560));disp('ssm_Tel_dwell packet is wrong lenght');return;end
    sample=get_14bit_integer(fid,L)';
    mask=uint16(2^14-1);
    b=single(bitand(fread(fid,3,'uint16=>uint16'),mask));
    status_spare=b(1);      
    status_flag=b(2);
    error_flag=b(3);
    
% database SSM_Tel_Dwell
%     mym(['replace INTO ssm_dwell_data(time,status_flag,error_flag,address,sample) VALUES ("{Sn}","{Si}","{Si}","{M}","{M}")'],...
%     fix(timeval*1.e10),status_flag,error_flag,address,sample);
 
    data.SSM_Tel_dwell.Itime=timeval;
    data.SSM_Tel_Dwell.address=address;
    data.SSM_Tel_dwell.sample=sample;  
    data.SSM_Tel_dwell.status_spare=status_spare;      
    data.SSM_Tel_dwell.status_flag=status_flag;
    data.SSM_Tel_dwell.error_flag=error_flag;

else
    dummy=fread(fid,L,'uint16');
end

if VERBOSE
v=datevec(timeval);
fprintf('Found PACKET %d (%x hex) sec=  %12.6f .\n', header.apid, header.apid,v(5)*60+v(6));
end  
        
function a=get_14bit_integer(fid,L)
        mask=uint16(2^14-1);
        buf =(bitand(fread(fid, L, '*uint16'),mask));
        a=single(buf);
        idx=find(a>8192);
        a(idx)=a(idx)-16384;
        
       