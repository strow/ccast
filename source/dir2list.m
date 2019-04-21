%
% dir2list - RCRIS or GCRSO directory to file list
%
% SYNOPSIS
%   flist = dir2list(rdir, ftype, nscan)
%
% INPUTS
%   rdir   - NOAA RCRIS or GCRSO files
%   ftype  - file type, 'RCRIS' or 'GCRSO'
%   nscan  - number of scans/file, 4 or 60
%
% OUTPUT
%   rlist  - list of RCRIS or GCRSO filenames
%
% DISCUSSION
%   when duplicate start and stop times are encountered 
%   the file with the last processing code is kept
%
%   RCRIS-RNSCA_npp_d20170401_t0005487_e0013487
%   1234567890123456789012345678901234567890123
%   0        1         2         3         4
%
%   GCRSO_npp_d20170401_t2109439_e2117417
%   1234567890123456789012345678901234567890123
%   0        1         2         3         4
%

function flist = dir2list(rdir, ftype, nscan)

% position of RCRIS and GCRSO filename time strings
switch(ftype)
  case 'RCRIS', k1 = 17; k2 = 43; s1 = 'RCRIS-RNSCA_*.h5';
  case 'GCRSO', k1 = 11; k2 = 37; s1 = 'GCRSO_*.h5';
  otherwise, error('ftype must be RCRIS or GCRSO');
end

% acceptable filename time span for 4 and 60 scan files
switch(nscan)
  case  4, dt1 =  3 * 8; dt2 =  5 * 8;
  case 60, dt1 = 56 * 8; dt2 = 61 * 8;
  otherwise, error('nscan must be 4 or 60');
end

% get the initial list of files
flist = dir(fullfile(rdir, s1));

if isempty(flist)
  fprintf(1, 'dir2list: no %s files found in %s\n', ftype, rdir)
  return
end

% select files by 4 or 60 scan time span ranges
n0 = length(flist);
ix = logical(zeros(n0));
for j = 1 : n0
  % get filename start and end times
  [t1, t2] = rstr2tai(flist(j).name(k1:k2));
  flist(j).t1 = t1; flist(j).t2 = t2;

  % compare filename with expected time span
  dt = mod(t2 - t1, 86400);
  ix(j) = dt1 <= dt & dt <= dt2;
end
flist = flist(ix);
n1 = length(flist);

if n1 < n0
  fprintf(1, 'dir2list: dropping %d wrong size file(s)\n', n0 - n1)
end

% use the last value if we have duplicate start times
tlist = {};
qlist = flist;
for j = 1 : n1
  tlist{j} = flist(j).name(k1:k2);
end
[~, ix] = unique(tlist, 'last');
flist = flist(ix);
n2 = length(flist);

if n2 < n1
  fprintf(1, 'dir2list: dropping %d duplicate file(s):\n', n1 - n2)
  for j = setdiff(1:n1, ix)
%   fprintf(1, '%s\n', tlist{j})
    fprintf(1, '%s\n', qlist(j).name)
  end
end

if isempty(flist)
  fprintf(1, 'dir2list: no selected %s files in %s\n', ftype, rdir)
end

