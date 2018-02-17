%
% opts_j1_HR - wrapper to process ccast L1a to SDR files
%
% SYNOPSIS
%   opts_j1_HR(year, doy)
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

function SDR_options(year, doy)

% search paths
addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath ../motmsc/utils

%-------------------
% data path options
%-------------------

cvers = 'j01';  % CrIS version
nscanSC = 45;   % scans per file

% data home directories
Lhome = '/asl/data/cris/ccast';  % L1a data
Shome = '/asl/data/cris/ccast/test1XX';  % SDR data

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
opts.cvers = cvers;       % current active CrIS
opts.cal_fun = 't1';      % calibration algorithm
opts.nlc_alg = 'NPP';     % UW NPP nonlin corr alg
opts.inst_res = 'hires4'; % j1 extended res mode
opts.user_res = 'hires';  % high resolution user grid
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1
opts.resamp = 4;          % resampling algorithm
opts.neonWL = 703.44765;  % override eng Neon value

% high-res SA inverse files
opts.LW_sfile = '../inst_data/SAinv_j1v3_LW.mat';
opts.MW_sfile = '../inst_data/SAinv_j1v3_MW.mat';
opts.SW_sfile = '../inst_data/SAinv_j1v3_SW.mat';

% time-domain FIR filter 
opts.NF_file = '../inst_data/FIR_19_Mar_2012.txt';

% NEdN principal component filter
opts.nedn_filt = '../inst_data/nedn_filt_HR.mat';

% override some early mission eng values 
if year == 2018 && 10 <= doy && doy <= 17
  % use Harris v113 values
  d1 = load('../inst_data/harris_v113')
  opts.VinstLW = d1.VinstLW; 
  opts.VinstMW = d1.VinstMW; 
  opts.VinstSW = d1.VinstSW;
  opts.cpLW = d1.cpLW;
  opts.cpMW = d1.cpMW;
  opts.cpSW = d1.cpSW;
end

% use the UW a2v4 values
a2tmp = [
   0.0119     0       0
   0.0157     0       0
   0.0152     0       0
   0.0128     0       0
   0.0268     0       0
   0.0110     0       0
   0.0091     0       0
   0.0154     0       0
   0.0079     0.0811  0
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

