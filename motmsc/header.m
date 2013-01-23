%
% NAME
%   rdr2sdr -- process RDR mat files to SDR mat files
%
% SYNOPSIS
%   [slist, msc] = rdr2sdr(flist, rdir, sdir, opts)
%
% INPUTS
%   flist  - list of RDR mat files
%   rdir   - directory for RDR input files
%   sdir   - directory for SDR output files
%   opts   - for now, everything else
%
% opts fields
%   avgdir   - directory for moving averages
%   mvspan   - span for local moving averages
%   sfileLW, MW, SW  - SRF matrix file by band
%   
% OUTPUTS
%   slist  - list of SDR mat files
%   msc    - optional output struct
%
% DISCUSSION
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%
