%
% opts_SDR_npp_MR - wrapper to process ccast L1a to SDR files
%
% SYNOPSIS
%   opts_SDR_npp_MR(year, doy)
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
%   this version is for low res user grid SDR from any of the sensor
%   grid res modes; edit L1a paths, inst_res, and SA invers files as
%   needed
%

function opts_SDR_npp_MR(year, doy)

% search paths
addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath /asl/packages/airs_decon/source

%-------------------
% data path options
%-------------------

cvers = 'npp';  % CrIS version
nscanSC = 45;   % scans per file

% data home directories
Lhome = '/asl/cris/ccast';  % L1a data
Shome = '/asl/cris/ccast';  % SDR data

% L1a and SDR directory names
Ldir = sprintf('L1a%02d_%s_H3', nscanSC, cvers);
Sdir = sprintf('sdr%02d_%s_MR', nscanSC, cvers);

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
opts.cvers = cvers;       % current active CrIS
opts.cal_fun = 'c5';      % calibration algorithm
opts.nlc_alg = 'NPP';     % UW NPP nonlin corr alg
opts.inst_res = 'hires3'; % npp extended res mode
opts.user_res = 'midres'; % mid resolution user grid
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1
opts.resamp = 4;          % resampling algorithm
opts.neonWL = 703.44835;  % override eng Neon value
opts.orb_period = 6090;   % orbital period (seconds)

% high-res SA inverse files
opts.LW_sfile = '../inst_data/SAinv_HR3_Pn_LW.mat';
opts.MW_sfile = '../inst_data/SAinv_HR3_Pn_MW.mat';
opts.SW_sfile = '../inst_data/SAinv_HR3_Pn_SW.mat';

% low-res SA inverse files
% opts.LW_sfile = '../inst_data/SAinv_LR_Pn_ag_LW.mat';
% opts.MW_sfile = '../inst_data/SAinv_LR_Pn_ag_MW.mat';
% opts.SW_sfile = '../inst_data/SAinv_LR_Pn_ag_SW.mat';

% time-domain FIR filter 
opts.NF_file = '../inst_data/FIR_19_Mar_2012.txt';

% UW NPP new (eng values except for UW new secret MW FOV 7)
opts.a2LW = [0.0194 0.0143 0.0161 0.0219 0.0134 0.0164 0.0146 0.0173 0.0304];
opts.a2MW = [0.0053 0.0216 0.0292 0.0121 0.0143 0.0037 0.0942 0.0456 0.0026];

% use L1a for recent N polar crossing time
opts.npole_xing = get_npole_xing(flist);

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

