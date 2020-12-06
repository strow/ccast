%
% opts_SDR_j1_H4 - wrapper to process ccast L1a to SDR files
%
% SYNOPSIS
%   opts_SDR_j1_H4(year, doy)
%
% INPUTS
%   year  - integer year
%   doy   - integer day of year
%
% DISCUSSION
%   wrapper to set paths, files, and options to process ccast L1a
%   to SDR files.  It can be edited as needed to change options and
%   paths.  Processing is done by L1a_to_SDR.
%
%   updated ICT modeling, new orbital phase calc, UW/eng a2 values
%

function ops_SDR_j1_H4(year, doy)

% search paths
addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath /asl/packages/airs_decon/source

%-------------------
% data path options
%-------------------

cctag = '20d';  % SDR file version
cvers = 'j01';  % CrIS instrument
nscanSC = 45;   % scans per file

% data home directories
Lhome = '/asl/cris/ccast';  % L1a data
Shome = '/asl/cris/ccast';  % SDR data

% L1a and SDR directory names
Ldir = sprintf('L1a%02d_%s_H4', nscanSC, cvers);
Sdir = sprintf('sdr%02d_%s_HR', nscanSC, cvers);

% full L1a and SDR paths
dstr = sprintf('%03d', doy);
ystr = sprintf('%d', year);
Lfull = fullfile(Lhome, Ldir, ystr, dstr);
Sfull = fullfile(Shome, Sdir, ystr, dstr);

% L1a file list
s1 = sprintf('CrIS_L1a_%s_s%02d_*.mat', cvers, nscanSC);
flist = dir(fullfile(Lfull, s1));

% create the output path, if needed
if exist(Sfull) ~= 7, mkdir(Sfull), end

%-------------------------------
% calibration algorithm options
%-------------------------------

opts = struct;            % initialize opts
opts.cctag = cctag;       % SDR file version
opts.cvers = cvers;       % current active CrIS
opts.cal_fun = 'c7';      % calibration algorithm
opts.nlc_alg = 'NPP';     % UW NPP nonlin corr alg
opts.inst_res = 'hires4'; % j1 extended res mode
opts.user_res = 'hires';  % high resolution user grid
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1
opts.resamp = 4;          % resampling algorithm
opts.neonWL = 703.44765;  % current eng Neon
opts.orb_period = 6090;   % orbital period (seconds)

% high-res SA inverse files
opts.LW_sfile = '../inst_data/SAinv_j1v3_LW.mat';
opts.MW_sfile = '../inst_data/SAinv_j1v3_MW.mat';
opts.SW_sfile = '../inst_data/SAinv_j1v3_SW.mat';

% time-domain FIR filter 
opts.NF_file = '../inst_data/FIR_19_Mar_2012.txt';

% override some early mission eng values 
if year == 2018 && 10 <= doy && doy <= 17
  % use Harris v113 values
  d1 = load('../inst_data/harris_v113');
  opts.VinstLW = d1.VinstLW; 
  opts.VinstMW = d1.VinstMW; 
  opts.VinstSW = d1.VinstSW;
  opts.cpLW = d1.cpLW;
  opts.cpMW = d1.cpMW;
  opts.cpSW = d1.cpSW;
end

% current eng a2 values
opts.a2LW = [0.0119 0.0157 0.0152 0.0128 0.0268 0.0110 0.0091 0.0154 0.0079];
opts.a2MW = [0 0 0 0 0 0 0 0 0.0811];

%---------------------------------
% take ccast L1a to L1b/SDR files
%---------------------------------

% check that we have some data
if isempty(flist)
  fprintf(1, 'SDR_options: empty L1a file list\n')
  fprintf(1, fullfile(Lfull, s1))
  return
end

% use L1a for recent N polar crossing time
opts.npole_xing = get_npole_xing(flist);

L1a_to_SDR(flist, Sfull, opts)

