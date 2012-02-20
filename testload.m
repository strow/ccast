
% load selected MIT and NGAS records 
% edit as needed for index or time substring

% specify by time substring
rid = 'd20100906_t1705597';  % Dave's file

% specify by index
% uncomment rid assignment below to use index
% ri = 20;

% path to H5 RDR data 
dsrc  = '/asl/data/cris/rdr_proxy/hdf/2010/249';

% path to MIT matlab RDR data
dmit = '/asl/data/cris/rdr_proxy/mat/2010/249';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% path to NGAS matlab RDR data
dngs = '/asl/data/cris/rdr_proxy/ng/2010/249';

% NGAS matlab filename and fov index for tests
% bngs = 'IGMB1F1Packet_000.mat';
bngs = 'EngineeringPacket_000.mat';
% bngs = 'SciencePacket_000.mat';

% MIT matlab RDR data file
% rid = lmit(ri).name(5:22);
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

% NGAS matlab RDR data file
rngs = ['RMAT_', rid];
fngs = [dngs, '/', rngs, '/', bngs];

% load the NGAS data, defines structure PacketDataArray
load(fngs)

