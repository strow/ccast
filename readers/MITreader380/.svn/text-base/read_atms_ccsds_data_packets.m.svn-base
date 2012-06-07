%
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

if exist('filename','var')~=1,
    clear instrSN sftwr_vrsn
    [filename, pathname] = uigetfile({'*.LOG;*.log;*.pkt;*.PKT','CCSDS Files (*.log,*.pkt)'},'Select File');
    if isequal(filename, 0)
        disp('User selected Cancel');
        clear filename pathname;
        return;
    end
end
if exist('pathname','var')~=1,
    if exist('DataDir','var')~=1, 
        error('Must have a DataDir variable (path name to the filename variable, e.g., ''C:\\directory\'' )')
    end
    pathname=DataDir;
end
fid = fopen([pathname, filename]);

%filename = [pathname filename];

% How much stuff to print to screen
if exist('VERBOSE','var')~=1,
    VERBOSE = 1;
end
DIAG = 0;

% Determine the size of the file
%fid = fopen(filename);
fseek(fid, 0, 'eof');
filelength = ftell(fid);
fclose(fid);

% Set machineformat based on file extension
if strcmpi(filename(end-3:end), '.log'),
    mf = 'l';
else
    mf = 'b';
end

% Set up some constants
NUM_PACKETS = 16;
APID_MASK = sum(2.^[0:10]);
CHECK_MASK = sum(2.^[11:15]);
PACKET_SEQUENCE_MASK = sum(2.^[14:15]);
SEQUENCE_NUMBER_MASK = sum(2.^[0:13]);
HEATER_MASK = sum(2.^[6:13]);
NUM_SPOTS = ceil(filelength/50); 
GOOD_PACKETS = 1;
PRINT_INSTRUMENT_MODE = 1; % flag to print stuff to the screen once
NO_STARE_FLAG = 1; % flag to indicate packet 218 is absent (use in cleanup_science)
MISSING_SEQNUM = 0; % flag to indicate break(s) in the sequence numbers of science packets
PROGRESS_COUNTER = zeros(1,101);
PROGRESS_COUNTER([11:20:91]) = 1;

% ***************** Determine instrument Serial Number ******************
byte_counter = 0;
bad_byte_counter = 0;
num_errors = 0;
unknown_packets = [];
fid = fopen([pathname,filename],'rb', mf);
while (feof(fid)==0)
    % Read header identification  
    first_word = fread(fid,1,'uint16');
    header.apid = bitand(first_word, APID_MASK);
    if (isempty(header.apid) == 0)
      switch dec2hex(header.apid)
        case '201' % LEO&A
          noUTC=0;
          read_packet_for_SN;
        case {'206','213'}  % housekeeping or Eng. H&S packet
          noUTC=1;
          read_packet_for_SN;
        otherwise
          read_unknown_packet;
      end
      clear noUTC
      % Found Inst. SN, stop looking
      if exist('instrSN','var')==1, break; end
    end
end
fclose(fid);
%**********************************************

% reinitialize some variables 
packet_counter = zeros(NUM_PACKETS,1);
byte_counter = 0;
bad_byte_counter = 0;
num_errors = 0;
unknown_packets = [];
missing_packets = [];
clear c_ind h_ind bad_ind

% instSN not found
if exist('instrSN','var')~=1,
    instrSN = 0;
end

% Open data file for reading (mf binary format)
fid = fopen([pathname,filename],'rb', mf);

% Initial packet structures
initialize_science_packets;
initialize_hotcal_packets;
initialize_calibration_packets;
initialize_housekeeping_packets;
initialize_engineering_h_and_s_packets;
initialize_LEOandA_packets;
initialize_cte_packets;
initialize_thermal_packets;
initialize_diary_packets;
initialize_diagnostic_packets;

apid_counts = zeros(1,1403);

%CAL_COUNT = 0;
if VERBOSE
    disp('************************************************************************');
end

% Read in packets from file
while (feof(fid)==0)
    
  % Read header identification  
  first_word = fread(fid,1,'uint16');
  header.apid = bitand(first_word, APID_MASK);
  apid_counts(header.apid+1)=apid_counts(header.apid+1)+1;

  if (isempty(header.apid) == 0)
      
      % Correct for h5 file values - Mark Tolman 3/16/2011
      if instrSN < 49,
          instrSN = 50;
      end
  
    switch dec2hex(header.apid)
        case '4'  % Bus Thermal Telemetry Packet
            read_packet_0004;
        case 'B'  % Diary packet
            read_packet_00B;
        case '200'  % command status packet
            read_packet_200;
        case '201'  % LEO&A packet
            if instrSN > 49,
                read_packet_201;
            else
                read_packet_201_EDU;
            end
	    case '202'  % Test packet
            read_packet_202;
	    case '203'  % Calibration packet
            read_packet_203;
            %CAL_COUNT = CAL_COUNT + 1;
            %if (CAL_COUNT > 3)
            %    return;
            %end
	    case '204'  % Diagnostic packet
            read_packet_204;
	    case '205'  % Dwell packet
            read_packet_205;
	    case '206'  % Housekeeping packet
            if instrSN > 49,
                read_packet_206;
            else
                read_packet_206_EDU;
            end
	    case '20B'  % Telemetry monitor packet
            read_packet_20B;
	    case '20C'  % Memory dump packet
            read_packet_20C;
	    case '210'  % Science packet
            read_packet_210;
        case '211'  % Ground test packet
            read_packet_211;
	    case '212'  % Engineering - hot cal packet
            read_packet_212;
	    case '213'  % Engineering - health and status packet
            if instrSN > 49,
                read_packet_213;
            else
                read_packet_213_EDU;
            end
	    case '218'  % Science packet
            NO_STARE_FLAG=0;
            read_packet_210;
        case '21C'  % CTE packet
            read_packet_21C;
        case '523'  % CrIS LW Earth Scene
            read_CrIS_ES_packet;
        case '53E'  % CrIS Deep Space
            read_CrIS_ES_packet;
        otherwise
            read_unknown_packet;
    end
  end
end

cleanup_hotcal_packets;
cleanup_calibration_packets;
cleanup_housekeeping_packets;
cleanup_engineering_h_and_s_packets;
cleanup_LEOandA_packets;
cleanup_cte_packets;
cleanup_thermal_packets;
cleanup_diagnostic_packets;
% Do Science Last due to code issues.
cleanup_science_packets;

fclose(fid);
fprintf('Cleaning up extraneous variables.\n')
clear NUM_PACKETS DEG_PER_COUNT PROGRESS_COUNTER
clear APID_MASK CHECK_MASK DIAG NO_STARE_FLAG PACKET_SEQUENCE_MASK PRINT_INSTRUMENT_MODE
clear SEQUENCE_NUMBER_MASK VERBOSE fid first_word progress second_word packet_id
clear y z j i L fid2 test c_ind h_ind
clear mf sftvr_a sftvr_b foobar
clear expected prev_seqnum this_seqnum
fprintf('Data ingestion complete.\n');
idx=find(apid_counts>0);[idx'-1,apid_counts(idx)']
