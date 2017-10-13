%
% NAME
%   geo_prepro -- ccast daily summary stats
%
% SYNOPSIS
%   geo_prepro(d1, d2, year)
%
% INPUTS
%   d1       - integer start day-of-year
%   d2       - integer end day-of-year
%   year     - integer preprocessing year
%
% OUTPUTS
%   allsci and allgeo files
%
% DISCUSSION
%   the geo daily summary part of the old ccast_prepro
%
% AUTHOR
%  H. Motteler, 12 Oct 2017
%

function daily_prepro(d1, d2, year)

% ccast paths
addpath ../source

% set data paths
gdir = '/asl/data/cris/sdr60';         % HDF GCRSO files
ddir = '/asl/data/cris/ccast/daily';   % matlab daily files

% add year to the paths
gdir = fullfile(gdir, sprintf('%d', year));
ddir = fullfile(ddir, sprintf('%d', year));

% loop on days of the year
for i = d1 : d2
  doy = sprintf('%03d', i);
  geo_daily(doy, gdir, ddir);
end

