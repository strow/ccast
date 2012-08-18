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

function [DATA META] = read_cris_hdf5_rdr(h5Filename, saveFilename)

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

DATA = struct();

% Add CrIS directory to the Matlab Path
s = mfilename('fullpath');
[pathstr, ~, ~] = fileparts(s);
addpath(pathstr, [pathstr filesep 'CrIS'], '-begin');
clear s pathstr

% Set the Save filename
if exist('saveFilename','var') ~= 1 || isempty(saveFilename),
    saveFilename = tempname;
    deleteTemp = 1;
else
    deleteTemp = 0;
end

% Extract the Raw Application Packets from the hdf5 file
saveFilename = extract_hdf5_rdr(h5Filename, saveFilename);
if isempty(saveFilename),
    return
end

apid_counts = zeros(1,1403);
header.apid = 0;
num_packets = 0;
is_not_eof = 1;
timeval = 0;

initialize_packet_structures;
fid = fopen(saveFilename, 'rb', 'b');
if fid < 0
    disp 'Unable to open saveFile'
    return
end

err = read_packet_headers;
while err==0
    read_packet_body;
    num_packets = num_packets + 1;
    apid_counts(header.apid+1) = apid_counts(header.apid+1) + 1;
    if VERBOSE
        fprintf('%s  %6.0f  %6.0f \n', datestr(timeval), header.apid, header.Secondary_header_flag);
    end
    err = read_packet_headers;
    if header.apid<0 || header.apid>1403 ;disp('invalid apid');return;end
end

% read spacecraft diary data

frewind(fid)
err = read_packet_headers;
while err==0
    if header.apid==11
    read_packet_spacecraft_diary
    else
        read_packet_to_end
    end
    num_packets = num_packets + 1;
    apid_counts(header.apid+1) = apid_counts(header.apid+1) + 1;
 
    err = read_packet_headers;
        if header.apid<0 || header.apid>1403 ;
        disp('invalid apid');
        return;
        end
end
idx=find(apid_counts>0);[idx'-1,apid_counts(idx)'];

% Delete the temp save file
if deleteTemp,
    delete(saveFilename);
end

DATA.idata = idata;
DATA.qdata = qdata;
DATA.data  = data;
DATA.packet = packet;
DATA.FOR = FOR;
DATA.diag = diagint;
DATA.packet_counter=packet_counter;
DATA.apid_counts=apid_counts;
DATA.diary_data=diary_data;
DATA.ESflags=data.ESflags;
DATA.ITflags=data.ITflags;
DATA.SPflags=data.SPflags;
DATA.sweep_dir = sweep_direction;

[hdf5_data META filetype] = read_npp_hdf5_tdr_sdr_rsdr_geo(h5Filename);

end
