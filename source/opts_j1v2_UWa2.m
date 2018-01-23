%
% SDR_options -- wrapper to process L1a to SDR data
%
% SYNOPSIS
%   SDR_options(doy, year)
%
% INPUTS
%   day   - integer day of year
%   year  - integer year, default is 2013
%
% DISCUSSION
%   wrapper script to set paths, files, and options for L1a_to_SDR,
%   to process ccast L1a to SDR files.  It can be edited as needed
%   to change options and paths.
%

function SDR_options(doy, year)

% search paths
addpath ../source
addpath ../davet
addpath ../motmsc/time

%-------------------
% data path options
%-------------------

cvers = 'j01';  % CrIS version
nscanSC = 45;   % scans per file

% data home directories
Lhome = '/asl/data/cris/ccast';  % L1a data
Shome = '/asl/data/cris/ccast/j1v2_UWa2';  % SDR data

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
unix(['mkdir -p ', Sfull]);

%-------------------------------
% calibration algorithm options
%-------------------------------

opts = struct;            % initialize opts
opts.cal_fun = 'c7';      % calibration algorithm
opts.cvers = cvers;       % current active CrIS
opts.inst_res = 'hires4'; % j1 extended res mode
opts.user_res = 'hires';  % high resolution user grid
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1
opts.resamp = 4;          % resampling algorithm
opts.neonWL = 703.44835;  % override eng Neon value

% high-res SA inverse files
opts.LW_sfile = '../inst_data/SAinv_j1v2_LW.mat';
opts.MW_sfile = '../inst_data/SAinv_j1v2_MW.mat';
opts.SW_sfile = '../inst_data/SAinv_j1v2_SW.mat';

% time-domain FIR filter 
opts.NF_file = '../inst_data/FIR_19_Mar_2012.txt';

% NEdN principal component filter
opts.nedn_filt = '../inst_data/nedn_filt_HR.mat';

if 10 <= doy && doy <= 17
  % use Harris v113 values
  d1 = load('../inst_data/harris_v113')
  opts.VinstLW = d1.VinstLW; 
  opts.VinstMW = d1.VinstMW; 
  opts.VinstSW = d1.VinstSW;
  opts.cpLW = d1.cpLW;
  opts.cpMW = d1.cpMW;
  opts.cpSW = d1.cpSW;
end

% new UW a2 values
a2tmp = [
    0.0189   -0.0027    0.0012
    0.0232    0.0018   -0.0015
    0.0198   -0.0032   -0.0008
    0.0173   -0.0022    0.0024
    0.0310   -0.0009    0.0001
    0.0113   -0.0008    0.0008
    0.0108   -0.0028   -0.0025
    0.0209   -0.0044   -0.0005
    0.0107    0.1451    0.0048
];
opts.a2LW = a2tmp(:, 1)';
opts.a2MW = a2tmp(:, 2)';

%---------------------------------
% take ccast L1a to L1b/SDR files
%---------------------------------

% check that we have some data
if isempty(flist)
  fprintf(1, 'SDR_options: empty L1a file list\n')
  fprintf(1, fullfile(Lfull, s1))
  return
end

% profile clear
% profile on

L1a_to_SDR(flist, Sfull, opts)

% profile report

