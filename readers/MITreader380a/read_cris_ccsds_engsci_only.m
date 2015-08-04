%
% NAME
%   read_cris_ccsds -- read a CrIS CCSDS packet file
%
% SYNOPSIS
%   DATA = read_cris_ccsds(saveFilename, btrimFile)
%
% INPUTS
%   saveFilename  - CCSDS packet file
%   btrimFile     - optional named bit trim cache
%   
% OUTPUT
%   DATA   - CCSDS packet data
%
% DISCUSSION
%   This is Dan's v380 reader modified to work with his general
%   purpose interferogram unpacker bit_unpack_all.c and to cache
%   the current bit trim mask, and further stripped down to just
%   the ccsds reader.
%
%   btrimFile should be the full filename, including extension.
%   Watch out for other files with the same name on the current
%   search path
%
% AUTHOR
%   Dan Mooney, post v380 mods by H. Motteler
%
% COPYRIGHT
%  (c) Copyright 2004 Massachusetts Institute of Technology
%
%  In no event shall M.I.T. be liable to any party for direct, 
%  indirect, special, incidental, or consequential damages arising
%  out of the use of this software and its documentation, even if
%  M.I.T. has been advised of the possibility of such damage.
%          
%  M.I.T. specifically disclaims any warranties including, but not
%  limited to, the implied warranties of merchantability, fitness
%  for a particular purpose, and non-infringement.
%
%  The software is provided on an "as is" basis and M.I.T. has no
%  obligation to provide maintenance, support, updates, enhancements,
%  or modifications.

function DATA = read_cris_ccsds_engsci_only(saveFilename);

global fid  VERBOSE timeval idata qdata data ...
packet_counter packet header sweep_direction FOR diagint

DATA = struct();

% Add CrIS directory to the Matlab Path
stmp = mfilename('fullpath');
[pathbase, fname] = fileparts(stmp);
pathcris = fullfile(pathbase, 'CrIS');
addpath(pathbase, pathcris);

apid_counts = zeros(1,1403);
header.apid = 0;
num_packets = 0;
is_not_eof = 1;
timeval = 0;

initialize_packet_structures;

% set the initial bit trim mask

fid = fopen(saveFilename, 'rb', 'b');
if fid < 0
    error('Unable to open saveFile')
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

% save current bit trim struct
DATA.data  = data;
DATA.packet = packet;
DATA.FOR = FOR;
DATA.diag = diagint;
DATA.packet_counter=packet_counter;
DATA.apid_counts=apid_counts;

end
