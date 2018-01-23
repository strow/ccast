%
% NAME
%   read_cris_hdf5_rdr -- read a CrIS RDR file
%
% SYNOPSIS
%   [DATA META] = read_cris_hdf5_rdr(h5File, packetFile, btrimInit)
%
% INPUTS
%   h5File      - CrIS RDR HDF5 source file
%   packetFile  - CCSDS packet tempporary file
%   btrimInit   - initial bit trim struct or file
%   
% OUTPUTS
%   DATA   - CCSDS packet data
%   META   - H5 metadata
%
% DISCUSSION
%   This is Dan's v380 reader modified to work with his general
%   purpose interferogram unpacker bit_unpack_all.c, and to use
%   an intital bit trim mask
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

function [DATA META] = read_cris_hdf5_rdr(h5File, packetFile, btrimInit)

global fid  VERBOSE timeval idata qdata data ...
  packet_counter packet header sweep_direction FOR diagint

DATA = struct();

% % packet file default filename
% if nargin < 2
%     packetFile = tempname;
%     deleteTemp = 1;
% else
%     deleteTemp = 0;
% end

% Extract the Raw Application Packets from the hdf5 file
packetFile = extract_hdf5_rdr(h5File, packetFile);
if isempty(packetFile),
    fprintf(1, 'read_cris_hdf5_rdr: could not read %s\n', h5File)
    return
end

apid_counts = zeros(1,1403);
header.apid = 0;
num_packets = 0;
is_not_eof = 1;
timeval = 0;

initialize_packet_structures;

% get an initial bit trim mask
if isstruct(btrimInit) && isfield(btrimInit, 'Band')
   packet.BitTrimMask = btrimInit;
elseif isstruct(btrimInit) && isfield(btrimInit, 'BitTrimMask')    
   packet.BitTrimMask = btrimInit.BitTrimMask;
elseif exist(btrimInit) == 2
   d1 = load(btrimFile);
   packet.BitTrimMask = d1.BitTrimMask;
else
   error('bad initial bit trim spec')
end
bittrim_update

fid = fopen(packetFile, 'rb', 'b');
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

if 0
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
  DATA.diary_data=diary_data;
end

% close the packet file
fclose(fid);

% Delete the temp save file
% if deleteTemp,
%     delete(packetFile);
% end

% save current bit trim struct
% BitTrimMask = packet.BitTrimMask;
% save(btrimFile, 'BitTrimMask');

DATA.idata = idata;
DATA.qdata = qdata;
DATA.data  = data;
DATA.packet = packet;
DATA.FOR = FOR;
DATA.diag = diagint;
DATA.packet_counter=packet_counter;
DATA.apid_counts=apid_counts;
% DATA.ESflags=data.ESflags;
% DATA.ITflags=data.ITflags;
% DATA.SPflags=data.SPflags;
DATA.sweep_dir = sweep_direction;

[hdf5_data META filetype] = read_npp_hdf5_tdr_sdr_rsdr_geo(h5File);

end

