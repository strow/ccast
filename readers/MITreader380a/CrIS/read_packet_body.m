function read_packet_body

% function packet_index
%_10/24/04
%__________________________________________________________________________
%
% (c) Copyright 2004 Massachusetts Institute of Technology
% 
% In no event shall MIT Lincoln Laboratory be liable to any party for direct, indirect,
% special, incidental, or consequential damages arising out of the use of this software
% and its documentation, even if MIT Lincoln Laboratory has been advised of the possibility
% of such damage. MIT Lincoln Laboratory specifically disclaims any warranties including,
% but not limited to, the implied warranties of merchantability, fitness for a particular
% purpose, and non-infringement.
% 
% The software is provided on an "as is" basis and MIT Lincoln Laboratory has no obligation
% to provide maintenance, support, updates, enhancements, or modifications.  
%__________________________________________________________________________
%
% All data passed in global variables with the following global statement.
% This statement must be placed in the analysis software to gain access to the read data.
% All % low level packet reader functions store data into this data structure.

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint
%
% GLOBAL VARIABLES:
% 
% fid - file id for CrIS data file fread calls
% 
% VERBOSE - diagnostic write enable
%
% timeval - time for currrent packet (stored in all_packets and packet)
%
% idata - normal mode real interferogram data
%         idata.LWES(1:866,FOV packet_counter.LWES(FOV))
%         same for LWES replaced by LWIT, LWSP, MWES, MWIT, MWSP, SWES,
%         SWIT, SWSP
%
% qdata - normal mode imaginary interferogram data
%         qdata.LWES(1:866,FOV, packet_counter.LWES(FOV))**
%
% data  - large matlab data structure.
%
% packet_counter - counts packets in each band and FOV
%
% packet - stores time, and FOV
%         i.e packet.LWES.time(packet_counter.LWES(FOV))=timeval**;
%         and many other things
%
% header - header information for current packet
%         header.apid = bitand(first_word, APID_MASK);
%         header.packet_sequence =  bitshift(bitand(second_word, PACKET_SEQUENCE_MASK),-14);
%         header.sequence_number =  bitand(second_word, SEQUENCE_NUMBER_MASK);
%         header.packet_length = fread(fid,1,'uint16');
%         header.time=timeval;
%
% sweep_direction - 1 or 0 by FOV and packet type and number
%         sweep_direction.LWES(FOV,packet_counter.LWES(FOV))
%         same for LWES replaced by LWIT, LWSP, MWES, MWIT, MWSP, SWES,
%         SWIT, SWSP
%
% FOR -  FOR.LWES(FOV,Packet_counter.LWES(FOV)
%
% diag - diagnostic data
%         diag.lw
%         diag.mw
%         diag.sw
%
%         ** same for LWES replaced by LWIT, LWSP, MWES, MWIT, MWSP, SWES,
%         SWIT, SWSP
%____________________
 
packet_not_decoded=0;
packet.error=0;

switch header.apid

case num2cell([1280,1281,1282,1283,1284,1285,1286,1287]);% 1/10 sec housekeeping
      if data.read.HK
          read_packet_HK;
      else
          read_packet_to_end
      end

case 1288  % LEO & A telemetry
      read_packet_LEOandA;

case 1289  % 8-sec Sci/Cal 
      read_packet_eight_sec_science_data; 
      
case 1290  % 4-min eng tel
        if data.eng_4min_On==1
        read_packet_four_min_eng_data_rev11;
        packet.read_four_min_packet=1;
        end  
               
case 1291; read_packet_HK_Tel_dwell_data;  % HK Telemetry Dweill packet          
case 1292; read_packet_SSM_Tel_dwell_data; % SSM Telemetry Dwell            
case 1293; read_packet_IM_Tel_dwell_data;  % IM Telemetry Dwell  

otherwise
      packet_not_decoded=1;
end

if packet_not_decoded==1 && data.read.interferograms==1;% if packet not decoded try to read interferograms    
        packet_not_decoded=0; % presume it will be decoded
        switch header.apid % switch 2
        %----------------------------------
        % RDR (Diagnostic) interferograms  
        case 1294; read_packet_LWDIA_data;% LW Diagnostic RDR
        case 1295; read_packet_MWDIA_data;% MW Diagnostic RDR
        case 1296; read_packet_SWDIA_data;% SW Diagnostic RDR
        %------------------------------------------
        %  EARTH SCENE (ES) 1315-1341
           % Earth Scene decimated interferograms   
        case {1315,1316,1317,1318,1319,1320,1321,1322,1323};read_packet_LWES_data % LW Interferogram SCN
        case {1324,1325,1326,1327,1328,1329,1330,1331,1332};read_packet_MWES_data % MW Interferogram SCN
        case {1333,1334,1335,1336,1337,1338,1339,1340,1341};read_packet_SWES_data % SW Interferogram SCN
             %------------------------------------------  
        % SPACE (SP)        1342-1369
            % Deep Space decimated interferograms  
        case {1342,1343,1344,1345,1346,1347,1348,1349,1350}; read_packet_LWSP_data % LW Interferogram SCN
        case {1351,1352,1353,1354,1355,1356,1357,1358,1359}; read_packet_MWSP_data % MW Interferogram SCN
        case {1360,1361,1362,1363,1364,1365,1366,1367,1368}; read_packet_SWSP_data % SW Interferogram SCN         
         %------------------------------------------  
        % INTERNAL TARGET(IT) 1370-1395
        case {1369,1370,1371,1372,1373,1374,1375,1376,1377}; read_packet_LWIT_data % LW Interferogram ICT
        case {1378,1379,1380,1381,1382,1383,1384,1385,1386}; read_packet_MWIT_data % MW Interferogram ICT
        case {1387,1388,1389,1390,1391,1392,1393,1394,1395}; read_packet_SWIT_data % SW Interferogram ICT
        % -------------------------------------------
        otherwise
        packet_not_decoded=1; % it was not an interferogram packet
        end% end 
end  % end try to read interferograms'
           
% if the packet is still not decoded it is not a CrIS packet packet
if packet_not_decoded==1
    read_packet_to_end;
    timeval=timeval; % use last valid timeval since we can't read  this packet.
end




   