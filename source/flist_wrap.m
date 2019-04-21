%
% flist_wrap - file list from current and previous directories
%
% SYNOPSIS
%   flist_wrap(fdir0, fdir1, ftype, nscan)
%
% INPUTS
%   fdir0  - directory for the previous day
%   fdir1  - directory for the current day
%
% DISCUSSION
%   validates file lists with dir2list and fixes the case where the
%   first NOAA RDR or Geo file of the day starts after the first FOR
%   1 after UTC 0:0:0

function flist = flist_wrap(fdir0, fdir1, ftype, nscan)

flist0 = dir2list(fdir0, ftype, nscan);
flist1 = dir2list(fdir1, ftype, nscan);
flist = flist1;
if ~isempty(flist0) && ~isempty(flist1)
  dt = mod(flist1(1).t1 - flist0(end).t2, 86400);
  if dt < 4
    flist = [flist0(end); flist1];
    fprintf(1, 'flist_wrap: including %s tail from previous day\n', ftype)
  end
end

